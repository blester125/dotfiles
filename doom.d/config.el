;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq x-super-keysym 'meta) ;; Set the left super key to the meta, avoid alt clashes with i3

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brian Lester"
      user-mail-address "blester125@gmail.com")

(setq notes (concat (getenv "HOME") "/notes") ;; Where I keep all my notes
      zettelkasten (concat notes "/zettelkasten")
      lit (concat zettelkasten "/lit")
      bib (concat lit "/references.bib") ;; Where I keep my bibliographic notes
      gtd (concat notes "/gtd") ;; Where I keep todos
      org-directory notes  ;; Where my general org notes are
      org-roam-directory zettelkasten ;; Where org-roam keeps all my files
      )


(add-hook 'text-mode-hook 'auto-fill-mode)
(setq-default fill-column 120)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-Iosvkem)
(setq doom-font (font-spec :family "Input Mono" :size 14))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory notes)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented

;; Taken from flyspell.el
(defun bl/save-word ()
  (interactive)
  (let  ((current-location (point))
         (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location)))
  )

(defun bl/string-from-file (file-path)
  "Return file-path's file contet"
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)
    )
  )

;; Configuring spell checking which I def need lol
(add-hook! 'text-mode-hook 'flyspell-mode)
(add-hook! 'prog-mode-hook 'flyspell-prog-mode)
;; This is turns on super mode where things like `_' are treaded as part of a word but that is isn't working with evil mode atm
;; (add-hook! 'python-mode-hook 'superword-mode)
;; Update the value of `_' in the syntax table so evil mode commands like `w' will not stop on this symbol, lets you manipulate a whole variable
(add-hook! 'python-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))
;; use zg in normal mode to save a word to my dictonary like I do in vim
(map! :n "z g" 'bl/save-word)


;; When I open a new window switch to it
(after! evil
  (setq evil-vsplit-window-right t
        evil-split-window-below t)
  (evil-commentary-mode)  ;; Use evil comentary so things like commenting a visual selection work
  )

;; Ivy the selection library via fuzzy matching I use
(after! ivy
  (setq ivy-count-format "(%d/%d) ") ;; Have ivy show the index and count
  (setq ivy-use-virtual-buffers "recentf") ;; Have ivy include recently opened files in the switch buffer menu
  (setq ivy-wrap t) ;; When you select past the start or end of the completetion list wrap around
  )

;; Ignore the __pycache__ (as well as auto saves and backups) when searching for file
(after! counsel
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)\\|\\(?:__pycache__\\)")
  )

;; Org mode is the reason I switched to emacs
(after! org
  (setq org-log-done 'time) ;; When I mark something as done save the time it was marked
  (map! :leader
        :prefix "n"
        "c" #'org-capture) ;; Capture notes into org mode with SPC n c
  )

;; A Zettelkasten in org mode, the reason I switched
(after! org-roam
  (map! :leader
        :prefix "r"
        :desc "open org-roam backlink panel" "l" #'org-roam
        :desc "Insert new org-roam note" "i" #'org-roam-insert
        :desc "Switch org-roam buffers" "b" #'org-roam-switch-to-buffer
        :desc "Find an org-roam file" "f" #'org-roam-find-file
        :desc "Show the org-roam graph" "g" #'org-roam-show-graph
        :desc "Use a capture to add a new org-roam note" "c" #'org-roam-capture
        )
  )

;; this seems to be an eager load?
(use-package! org-journal
  :config
  (setq
        org-journal-dir org-roam-directory
        org-journal-date-prefix "#+title: "
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-data-format "%A, %d %B %Y"
        org-journal-enable-agenda-integration t
        )
)

;; A daily collection of fleeting notes
(after! org-journal
  (map! :leader
        :prefix "r"
        :desc "Create a new note for today" "j" #'org-journal-new-entry
        )
  )

(set-file-template! "\\.org$" :ignore t)

;; Find and take notes on bibliographic entries
(use-package ivy-bibtex
  :bind
  ("C-x C-b" . ivy-bibtex)
  :config
  (setq
   bibtex-completion-notes-path lit
   bibtex-completion-bibliography bib
   bibtex-completion-pdf-field "file"
   bibtex-completion-pdf-symbol "⌘"
   bibtex-completion-notes-symbol "✎"
   ivy-bibtex-default-action 'ivy-bibtex-edit-notes ;; When you select a biblographic entry open the notes on it, not sure how to do a different command tho
   bibtex-completion-notes-template-multiple-files
   (concat
    "#+title: ${title}\n"
    "#+roam_key: cite:${=key=}\n\n"
    ":PROPERTIES:\n"
    ":Custom_ID: ${=key=}\n"
    ;; ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
    ":AUTHOR: ${author-abbrev}\n"
    ":JOURNAL: ${journal}\n"
    ":BOOKTITLE: %{booktitle}\n"
    ":DATE: ${date}\n"
    ":YEAR: ${year}\n"
    ":DOT: ${doi}\n"
    ":URL: ${url}\n"
    ":END:\n\n"
    "* TODO Notes\n\n"
   )
  )
)

(after! ivy-bibtex
  (map! :leader
        :prefix "r"
        :desc "Get notes on a biblographic entry" "b" #'ivy-bibtex)
  )

(use-package org-ref
  :ensure t
  :config
  (setq
    org-ref-bibliography-notes lit
    org-ref-default-bibliograhy bib
    )
  )
