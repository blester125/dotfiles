;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq x-super-keysym 'meta) ;; Set the left super key to the meta, avoid alt clashes with i3

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brian Lester"
      user-mail-address "blester125@gmail.com")

; (add-hook 'text-mode-hook 'flyspell-mode)
;; (add-hook 'prog-mode-hook 'flyspell-prog-mode)

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
(setq doom-theme 'doom-vibrant)
(setq doom-font (font-spec :family "Input Mono" :size 14))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

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

;; Take from flyspell.el
(defun bl/save-word ()
  (interactive)
  (let  ((current-location (point))
         (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location)))
  )

;; Configuring spell checking which I def need lol
(add-hook! 'text-mode-hook 'flyspell-mode)
(add-hook! 'prog-mode-hook 'flyspell-prog-mode)
(map! :n "z g" 'bl/save-word)


;; When I open a new window switch to it
(after! evil
  (setq evil-vsplit-window-right t
        evil-split-window-below t))

(after! ivy
  (setq ivy-count-format "(%d/%d) ") ;; Have ivy show the index and count
  (setq ivy-use-virtual-buffers "recentf") ;; Have ivy include recently opened files in the switch buffer menu
  (setq ivy-wrap t) ;; When you select past the start or end of the completetion list wrap around
  )

;; Ignore the __pycache__ (as well as auto saves and backups) when searching for file
(after! counsel
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)\\|\\(?:__pycache__\\)")
  )
