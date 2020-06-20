;; .emacs.d/init.el

;; Basic Customization
(setq x-super-keysym 'meta) ;; Set the left super key to be the meta key, otherwise I have to use alt which doesn't play nice with i3
(setq default-directory (concat (getenv "HOME") "/"))
(setq inhibit-startup-message 't) ;; Hide the splash screen
(setq initial-scratch-message ";; Emacs Scratch\n\n")
(setq focus-follows-mouse 'f)
(setq mouse-autoselect-window 'f)
(add-hook 'before-save-hook 'whitespace-cleanup)

(setq-default tab-width 4)
(setq python-indent-offset 4)

(add-hook 'text-mode-hook 'flyspell-mode) ;; Setup spell check minor mode in any text mode subclass
(add-hook 'prog-mode-hook 'flyspell-prog-mode)  ;; Setup spell check for comments in any programming model subclass
(add-hook 'text-mode-hook 'auto-fill-mode) ;; Setup any text mode to do a hard wrap
(setq-default fill-column 120) ;; Set this hard wrap to be at 120 lines

;; Enables baisc packaging support
(require 'package)

;; Adds the Melpa archive to the list of repos
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

;; Initialize the package infrastructure
(package-initialize)

;; If use-package isn't installed install it
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; make sure we have use-package setup
(eval-when-compile
  (require 'use-package))

;; Like sensible vim
(use-package better-defaults
  :ensure t)

;; Setup Vim controls
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config (evil-mode 1))

;; (use-package evil-collection
;;   :after evil
;;   :ensure t
;;   :custom (evil-collection-setup-minibuffer t)
;;   :init
;;   (evil-collection-init)
;; )

;; Like vim-commentary, allows for gcc to comment a line
(use-package evil-commentary
  :ensure t
  :config
  (evil-commentary-mode))

;; This gives relative line numbers when in evil command mode (with the current line
;; being the global number. In insert mode the line numbers are global
(use-package nlinum-relative
  :ensure t
  :config
  (nlinum-relative-setup-evil)
  (add-hook 'prog-mode-hook 'nlinum-relative-mode)
  (add-hook 'text-mode-hook 'nlinum-relative-mode))

;; Helm is a fuzzy matcher
(use-package helm
  :ensure t
  :bind
  ("C-x C-f" . helm-find-files) ;; Bind the file finding functionality to the open version
  :config
  (helm-mode 1)
  (setq
   helm-split-window-in-side-p t ;; Open helm butter inside current window
   helm-move-to-line-cycle-in-source t ;; Loop through the list
   helm-ff-file-name-history-use-recetnf t
   helm-echo-input-in-header-line t)
  ;; (push '("Find file other window `C-c o'" . helm-find-files-other-window) helm-find-files-actions)
  ;; (delete-dups helm-find-files-actions)
)


;; ;; blacken python code
;; (use-package blacken
;;   :ensure t
;;   :config
;;   (setq blacken-allow-py36 't)
;;   (setq blacken-line-length 120))

;; (use-package conda
;;  :ensure t
;;  :config
;;  (conda-env-initialize-interactive-shells)
;;  (conda-env-initialize-eshell)
;;  (conda-env-autoactivate-mode t))


;; ;; Git integration
;; (use-package magit
;;   :ensure t
;;   :bind ("C-x g" . magit-status))

;; Look like ubuntu terminals
(use-package ubuntu-theme
  :ensure t
  :config (load-theme 'ubuntu t))


;; Set up Markdown coloring
(use-package markdown-mode
  :ensure t
  :config
  ;; Highlight code within code fences in markdown files
  (setq markdown-fontify-code-blocks-natively 't))

;; Set up Yaml updates
(use-package yaml-mode
  :ensure t
  :config
  ;; Set yaml mode for .yml and .yaml
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))
  ;; Have \n do both the new line and the indentation like it does in python mode
  (add-hook 'yaml-mode-hook
            '(lambda ()
               (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

;; Better json highlighting
(use-package json-mode
  :ensure t)

;; Org Mode for TODOs
(use-package org
  :ensure t
  :config
  (setq org-hide-leading-stars t)
  (setq org-startup-folded nil)
  ;; (setq org-ellipsis "⤵")
)

(use-package org-superstar
  :ensure t
  :hook
  (org-mode . org-superstar-mode)
)

;; A Zettelkasten implementation and the while reason I am trying out Emacs
(use-package org-roam
  :ensure t
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory (concat (getenv "HOME") "/notes/zettelkasten"))
  :bind
  (:map org-roam-mode-map
        (("C-c n l" . org-roam)
         ("C-c n f" . org-roam-find-file)
         ("C-c n g" . org-roamshow-graph))
        :map org-mode-map
        (("C-c n i" . org-roam-insert)))
  )

(use-package helm-bibtex
  :ensure t
  :bind
  ("C-x C-b" . helm-bibtex)
  :config
  (setq
   bibtex-completion-notes-path (concat (getenv "HOME") "/notes/research/")
   bibtex-completion-bibliography (concat (getenv "HOME") "/notes/research/references.bib")
   bibtex-completion-pdf-field "file"
   bibtex-completion-notes-template-multiple-files
   (concat
    "#+title: ${title}\n"
    "#+roam_key: cite:${=key=}\n\n"
    "* TODO Notes\n\n"
    ":PROPERTIES:\n"
    ":Custom_ID: ${=key=}\n"
    ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
    ":AUTHOR: ${author-abbrev}\n"
    ":JOURNAL: ${journaltitle}\n"
    ":DATE: ${date}\n"
    ":YEAR: ${year}\n"
    ":DOT: ${doi}\n"
    ":URL: ${url}\n"
    ":END:\n\n"
   )
  )
  (helm-delete-action-from-source "Edit notes" helm-source-bibtex)
  (helm-add-action-to-source "Edit notes" 'helm-bibtex-edit-notes helm-source-bibtex 0)
)

(use-package org-ref
  :ensure t
  :config
  (setq
    org-ref-bibliography-notes (concat (getenv "HOME") "/notes/research/")
    org-ref-default-bibliograhy (concat (getenv "HOME") "/notes/research/references.bib")
    )
  )


; (use-package org-roam-bibtex
;   :after (org-roam)
;   :hook (org-roam-mode . org-roam-bibtex-mode)
;   :config
;   (setq org-roam-bibtex-preformat-keywords
;   '("=key=" "title" "url" "file" "author-or-editor" "keywords"))
;   (setq orb-templates
;     '(("r" "ref" plain (function org-roam-capture--get-point)
;        ""
;        :file-name "${slug}"
;        :head "#+TITLE: ${=key=}: ${title}\n#+ROAM_KEY: ${ref}

;  - tags ::
;  - keywords :: ${keywords}

;  \n* ${title}\n  :PROPERTIES:\n  :Custom_ID: ${=key=}\n  :URL: ${url}\n  :AUTHOR: ${author-or-editor}\n  :NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n  :NOTER_PAGE: \n  :END:\n\n"

;         :unnarrowed t))))

;; my_packages contains a list of package names
;;(defvar my_packages
;;  '(better-defaults ;; like sensable-vim
;;    evil            ;; vim mode
;;    elpy            ;; Emacs List Python Enviornment
;;    blacken         ;; Use Black to auto format code
;;    flycheck        ;; On the fly syntax checking
;;    org             ;; Org-mode for TODOs
;;    org-roam        ;; Org-Roam a Zettelkasten implementation and the whole reason I am trying out Emacs
;;    )
;;  )



;; Development Setup
;; Enable elpy
;;(elpy-enable)

;; Enable Flycheck
;;(when (require 'flycheck nil t)
;;  (setq elpy-modules (delq 'elpy-modules-flymake elpy-modules))
;;  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; User-Defined init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (helm-bibtex helm json-mode magit material-theme better-defaults))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
