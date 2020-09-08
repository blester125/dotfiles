;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq x-super-keysym 'meta) ;; Set the left super key to the meta, avoid alt clashes with i3

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brian Lester"
      user-mail-address "blester125@gmail.com")

(setq notes (concat (getenv "HOME") "/notes/") ;; Where I keep all my notes
      zettelkasten (concat notes "zettelkasten/")
      lit (concat zettelkasten "lit/")
      bib (concat lit "references.bib") ;; Where I keep my bibliographic notes
      gtd (concat zettelkasten "gtd/") ;; Where I keep todos
      inbox (concat gtd "inbox.org")
      journal (concat zettelkasten "journal/") ;; Where I keep daily journals
      org-directory notes  ;; Where my general org notes are
      org-roam-directory zettelkasten ;; Where org-roam keeps all my files
      org-roam-db-location (concat (getenv "HOME") "/.org-roam.db")
      )


;; (add-hook 'text-mode-hook 'auto-fill-mode)
(setq-default fill-column 120)

(setq org-ellipsis " ⤵")

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

;; Get an environment variable with a default value
(defun bl/getenv (variable default &optional frame)
  (let ((env (getenv variable frame))) ;; Proxy to getenv to get the var and save it into env
    (if (not (null env)) ;; check if the value was nil
        env ;; If the value was not nil evaluate the variable (note the lack of () because this is a variable not a function)
      default  ;; Otherwise eval the default. Lisp will return the last value eval, there is no return statement
      ))
  )

;; Configuring spell checking which I def need lol
(add-hook! 'text-mode-hook 'flyspell-mode)
(add-hook! 'prog-mode-hook 'flyspell-prog-mode)

;; This is turns on superword mode where things like `_' are treaded as part of a word but that is isn't working with evil mode atm
;; (add-hook! 'python-mode-hook 'superword-mode)

;; Update the value of `_' in the syntax table so evil mode commands like `w' will not stop on this symbol, lets you manipulate a whole variable
(add-hook! 'python-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))
;; use zg in normal mode to save a word to my dictonary like I do in vim
(map! :n "z g" 'bl/save-word)

;; When I open a new window switch to it
(after! evil
  (setq evil-vsplit-window-right t
        evil-split-window-below t)
  (evil-commentary-mode)  ;; Use evil commentary so things like commenting a visual selection work
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
  (map! :leader
        :prefix "m"
        "y" #'org-toggle-checkbox)
  (setq org-capture-templates
        '(("i" "Inbox entry" entry (file+headline inbox "Tasks")
           "* TODO %i%?")
          ("I" "Linked Inbox entry" entry (file+headline inbox "Tasks")
           "* TODO %?\n %i\n %a")
          )
        )
  (setq org-src-fontify-natively t)
  (require 'ox-reveal)
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

;; Right now this will open the multiple windows where you can see a preview of the journal file being changed. I would like to remove that in the future
(defun bl/org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  ;; Position point on the journal's last top-level heading so that org-capture
  ;; will add the new entry as a child entry.
  ;; First we go to the end of the file with point-max
  (goto-char (point-max))
  ;; then we search backwards for the first line that has a match of starting with a single *, the second character block say one of more
  ;; anything but a * this will eliminate find a sub heading. This is based on the assumption that each day has a heading and all the
  ;; notes you will capture on that day should be sub headings of that day.
  (search-backward-regexp "^\*[^*]*$")
  ;; The version of this function I found on the internet used `point-min' to jump to the beginning of the file which assumed
  ;; that the first heading lived there. That is fine for some daily notes but when you use org-capture for weekly/monthly it
  ;; breaks. It also breaks if you have a header in the file.
  )

;; This is the same as the above but we use let to override specific values to turn it from a daily journal into a monthly one that save somewhere else
(defun work/org-journal-find-location ()
  (let ((org-journal-dir (bl/getenv "WORK_NOTEBOOK" "~/dev/work/notebooks/blester"))
        (org-journal-file-format "%Y-%m.org")
        (org-journal-file-type 'monthly))
        (bl/org-journal-find-location))
  )

;; For some reason when I have a header insserted into the file the new entiries don't nest properly, TODO
(defun bl/org-journal-file-header-func (time)
  "Custom function to create journal header."
  (concat
    (pcase org-journal-file-type
      (`daily (concat "#+title: " (format-time-string org-journal-date-format time) "\n#+startup: showeverything\n\n"))
      (`weekly "#+title: Weekly Journal\n#+startup: folded\n\n")
      (`monthly (concat "#+title: " (format-time-string "%B" time) " Journal\n#+startup: folded\n\n"))
      (`yearly "#+title: Yearly Journal\n#+startup: folded\n\n")))
  )

;; A daily journal in org model that I access via org-capture
(use-package! org-journal
  :after (org-capture org)
  :config
  (setq
        org-journal-dir org-roam-directory
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-date-format "%A, %d %B %Y"
        org-journal-enable-agenda-integration t
        org-journal-file-type 'daily
        org-journal-file-header 'bl/org-journal-file-header-func
      )
  (add-to-list 'org-capture-templates '("w" "Work entry" entry (function work/org-journal-find-location)
                                      "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?"))
  (add-to-list 'org-capture-templates '("j" "Journal entry" entry (function bl/org-journal-find-location)
                                      "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?"))
)

(set-file-template! "\\.org$" :ignore t)

;; Find and take notes on bibliographic entries, Seems to be an eager load right now
(use-package! ivy-bibtex
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
    ":BOOKTITLE: ${booktitle}\n"
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
       :desc "Get notes on a biblographic entry" "r" #'ivy-bibtex)
 )

;; (use-package! org-ref
;;   :config
;;   (setq
;;     org-ref-bibliography-notes lit
;;     org-ref-default-bibliograhy bib
;;     )
;;   )

;; (use-package! elpy
;;   :defer t
;;   :init
;;   (advice-add 'python-mode :before 'elpy-enable)
;;   )

(use-package! visual-fill-column
  :hook
  (visual-line-mode . visual-fill-column-mode)
  )

(custom-set-faces!
  '((org-block markdown-code-face) :background nil))
