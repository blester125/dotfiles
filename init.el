;; .emacs.d/init.el

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
  :config (evil-mode 1))

(use-package evil-nerd-commenter
  :ensure t)

;; blacken python code
(use-package blacken
  :ensure t
  :config
  (setq blacken-allow-py36 't)
  (setq blacken-line-length 120))

;; Git integration
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; Look like ubuntu terminals
(use-package ubuntu-theme
  :ensure t
  :config (load-theme 'ubuntu t))

(use-package flyspell
  :ensure t)

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
(use-package org)
;; A Zettelkasten implementation and the while reason I am trying out Emacs
(use-package org-roam)

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

;; Basic Customization
(setq inhibit-startup-message t) ;; Hide the splash screen
(global-linum-mode t) ;; Enable line numbers
(setq-default tab-width 4)
(setq python-indent-offset 4)

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'proj-mode-hook 'flyspell-prog-mode)
(add-hook 'text-mode-hook 'auto-fill-mode)
(setq-default fill-column 120)

(setq display-line-numbers 'relative
      display-line-numbers-current-absolute t)

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
 '(package-selected-packages (quote (json-mode magit material-theme better-defaults))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
