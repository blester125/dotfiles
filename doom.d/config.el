;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(load (concat doom-private-dir "faces.el"))

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq x-super-keysym 'meta) ;; Set the left super key to the meta, avoid alt clashes with i3
(setq which-key-idle-delay 0.5) ;; Show me help quicker lol.

;; Disable `describe-gnu-project' because it opens a web-browser, I never actually
;; want to see it, and it takes forever.
(map! :map doom-leader-map "h g" 'nil)
(map! :map ehelp-map "g" 'nil)

(map! :leader
      :prefix ("i" . "insert")
      :desc "Insert an em-dash (—)" :nv "m" (cmd! (insert-char #x002014))
      :desc "Insert a shrug (¯\\_(ツ)_/¯)" :nv "S" (cmd! (insert "¯\\_(ツ)_/¯")))

;; Some functionality uses this to identify you, e.g. PGP configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brian Lester"
      user-mail-address "blester125@gmail.com")

(defvar notes (concat (getenv "HOME") "/notes/") "Where I keep all of my org files.")
(defvar zettelkasten (concat notes "zettelkasten/") "Where I keep all of my notes.")
(defvar lit (concat zettelkasten "lit/") "Where notes on papers (or anything with a bib reference) live.")
(defvar bib (concat lit "references.bib") "Where I keep my large bibliography, in BibTex.")
(defvar images (concat zettelkasten "images/") "Where I keep images from my notes.")

(setq org-directory notes  ;; Where my general org notes are
      org-roam-directory zettelkasten ;; Where org-roam keeps all my files
      org-roam-db-location (concat (getenv "HOME") "/.org-roam.db")
      org-roam-file-exclude-regexp "\\.stversions")

(setq-default fill-column 120)
;; Change the fill-column depending on if you are programming or just typing.
(setq-hook! 'text-mode-hook fill-column 120)
(setq-hook! 'prog-mode-hook fill-column 80)
(add-hook! 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Virtually wrap lines at `fill-column' characters.
(use-package! visual-fill-column
  :hook
  (visual-line-mode . visual-fill-column-mode))

;; compat-string-width is used by some packages but is missing.
(defun compat-string-width (STRING &optional FROM TO)
  (string-width STRING FROM TO))

;; The symbol used when you have an org header closed.
(setq org-ellipsis " ↴")
(setq projectile-project-search-path `(,(concat (getenv "HOME") "/dev")))

;; Font Settings
(defvar mono-font "Input Mono" "The font to use for fixed-width fonts.")
(defvar mono-size 24 "The size of the fixed-width font.")
(defvar pitch-font "ETBembo" "The font to use for pitched fonts.")
(defvar pitch-size 26 "The size of the pitched font.")

(when WORK
  (setq mono-size 12)
  (setq pitch-size 16))
(when LAPPY
  (setq mono-size 12)
  (setq pitch-size 14))

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
(setq doom-font (font-spec :family mono-font :size mono-size)
      doom-variable-pitch-font (font-spec :family pitch-font :size pitch-size))

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

;; It isn't a perfect match but use python highlighting when editing gin config files.
(add-to-list 'auto-mode-alist '("\\.gin$" . python-mode))

(defun bl/string-from-file (file-path)
  "Return file-path's file content as a string."
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)))

(defun bl/getenv (variable default &optional frame)
  "Get an environment variable with a default value."
  (let ((env (getenv variable frame))) ;; Proxy to getenv to get the var and save it into env
    (if (not (null env)) ;; check if the value was nil
        env ;; If the value was not nil evaluate the variable (note the lack of () because this is a variable not a function)
      ;; Otherwise eval the default. Lisp will return the last value eval, there is no return statement
      default)))

;; Update the value of `_' in the syntax table so evil mode commands like `w' will not stop on this symbol, lets you manipulate a whole variable
(add-hook! 'python-mode-hook (modify-syntax-entry ?_ "w"))

;; When I open a new window switch to it
(after! evil
  (setq evil-vsplit-window-right t  ;; Open vertical splits to the right of the current window.
        evil-split-window-below t)  ;; Open horizontal splits below the current window.
  ;; Use evil commentary so things like commenting a visual selection work.
  (evil-commentary-mode)
  (map! :m "<end>" 'evil-end-of-line-or-visual-line)
  ;; Save with `:W' too because I am heavy on shift
  (evil-ex-define-cmd "W[RITE]" 'evil-write))

;; Ivy the selection library used by org-roam
(after! ivy
  (setq ivy-count-format "(%d/%d) ") ;; Have ivy show the index and count
  (setq ivy-use-virtual-buffers "recentf") ;; Have ivy include recently opened files in the switch buffer menu
  (setq ivy-wrap t) ;; When you select past the start or end of the completetion list wrap around
  ;; When using the ivy-minibuffer have shift-space just enter a space, it used to call a function that would wipe the buffer.
  (map! :map ivy-minibuffer-map "S-SPC" (lambda () (interactive) (insert " "))))

;; Ignore the __pycache__ (as well as auto saves and backups) when searching for file
(after! counsel
  (setq counsel-rg-base-command '("rg" "--max-columns" "240" "--max-columns-preview" "--with-filename" "--no-heading" "--line-number" "--color" "never" "%s"))
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)\\|\\(?:__pycache__\\)")
  ;; Add our insert roam link from counsel-rg search.
  (ivy-add-actions 'counsel-rg '(("r" bl/ivy-insert-org-roam-link "Insert Org-Roam link."))))

(defun bl/org-insert-downcased-property-drawer ()
  "Downcase the :PROPERTIES: and :END: markers of a property drawer. To be used as advice after calling `org-insert-property-drawer'"
  (let* ((drawer (org-get-property-block))
         (beg (car drawer))
         (end (cdr drawer)))
    (downcase-region (- beg (length ":PROPERTIES:")) beg)
    (downcase-region end (+ end (length ":END:")))))

(defun bl/downcase-propertry-drawer (&optional beg force)
  "Downcase all properties and end markers of a property drawer.

If &optional `beg' is supplied, downcase the property drawer associated with this subtree/file.
If &optional `force' is supplied, create the drawer if it does not exist."
  (interactive)
  (let* ((drawer (org-get-property-block beg force))
         (beg (car drawer))
         (end (cdr drawer))
         (properties (org-entry-properties beg)))
    (downcase-region (- beg (length ":PROPERTIES:")) beg)
    (downcase-region end (+ end (length ":END:")))
    (dolist (property (map-keys properties))
      (goto-char beg)
      (when (search-forward-regexp (format ":%s:" property) end 't 1)
        (replace-match (format ":%s:" (downcase property)) 't)))))


(defun bl/org-inherited-priority (header)
  "Search parent headings to allow of inheritence of priority."
  (cond
   ;; Priority cookie in this heading
   ((string-match org-priority-regexp header)
    (* 1000 (- org-priority-lowest (org-priority-to-value (match-string 2 header)))))
   ;; No priority cookite by we are a top level header
   ((not (org-up-heading-safe))
    (* 1000 (- org-priority-lowest org-priority-default)))
   ;; Look for the parent's priority
   (t
    (bl/org-inherited-priority (org-get-heading)))))

;; Org mode is the reason I switched to emacs
(after! org
  (setq org-log-done 'time) ;; When I mark something as done save the time it was marked
  (map! :leader
        :prefix "n"
        "c" #'org-capture) ;; Capture notes into org mode with SPC n c
  (map! :leader
        :prefix ("m" . "org-mode")
        :desc "Insert an inline TODO" "T" #'org-inlinetask-insert-task ;; Insert a TODO that doesn't trigger nesting.
        :desc "Insert an empty property drawer" "O" (lambda () (interactive) (org-insert-property-drawer)))
  ;; Insert a zero-width space to separate markup from punctuation
  (map! :map org-mode-map
        :nie "C-M-SPC" (cmd! (insert "\u200B")))
  (appendq! +ligatures-extra-symbols
            `(:em_dash       "—"
              :list_property "∷"
              :begin_quote   "❝"
              :end_quote     "❞"
              :caption       "☰"
              :results       "🠶"
              :ellipses      "…"))
  (set-ligatures! 'org-mode
    :merge t
    :em_dash       "---"
    :list_property "::"
    :caption       "#+caption:"
    :results       "#+RESULTS:"
    :ellipsis      "...")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t)
     (shell . t)
     (scheme . t)
     (dot . t)
     (prolog . t)))
  (setq org-src-fontify-natively 't)  ;; Use syntax highlighting for code blocks.
  ;; The available TODO states, the ones after the "|" are considered finished.
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAIT(w!)" "BLOCKED(b!)" "|" "DONE(d)" "KILL(k)")
          (sequence "[ ](T)" "[/](C)" "|" "[X](D)")))
  ;; Faces to color specific TODO states.
  (setq org-todo-keyword-faces
        '(("WAIT" . +org-todo-onhold)
          ("BLOCKED" . +org-todo-cancel)
          ("KILL" . +org-todo-cancel)))
  ;; Set the range of priority levels from A -> F.
  (setq org-priority-lowest ?F)
  (setq org-priority-default ?F) ;; Headlines without priorities are lowest at F
  ;; Set colors for priority levels
  (setq org-priority-faces '((?A . error)
                             (?B . warning)
                             (?C . rising)
                             (?D . chill)
                             (?E . success)))
  ;; Headlines without priorities inherit their parents, helps grouping subtasks
  ;; without needing to add priorities to all of them.
  (setq org-priority-get-priority-function #'bl/org-inherited-priority)
  (advice-add 'org-insert-property-drawer :after-while 'bl/org-insert-downcased-property-drawer)
  ;; Highlight the word NOWORK in org-agenda. It doesn't use font-lock so I had
  ;; to use a hook like this. Also I don't know why I couldn't use the DOOM
  ;; emacs add-hook! for this but it that case it wouldn't work.
  (add-hook 'org-agenda-finalize-hook
    (lambda ()
      (highlight-regexp "NOWORK" 'NOWORK-face)))
  ;; When you have a heading where the text is `~~' make it invisible, this lets
  ;; you write what looks like non hierarchical org.
  (add-to-list 'font-lock-extra-managed-props 'invisible)
  (font-lock-add-keywords 'org-mode
                          (list '("NOWORK" . 'NOWORK-face)
                                '("^\*+ ~~$" 0 (progn
                                                 (add-text-properties (match-beginning 0)
                                                                      (match-end 0)
                                                                      '(invisible t)))))))


(use-package! org-inlinetask
  :after org
  :config
  (setq org-inlinetask-default-state "TODO"
        org-inlinetask-min-level 10)
  (face-spec-set 'org-inlinetask '((t :inherit outline-8)) 'face-defface-spec)
  (font-lock-add-keywords 'org-mode
                          (list `(,(format "^\\*\\{%d\\}[^*]" org-inlinetask-min-level) 0
                                  (progn
                                    (add-text-properties (match-beginning 0)
                                                         (- (match-end 0) 3)
                                                         '(invisible t)))))))

(use-package! graphviz-dot-mode
  :after org)

;; Keybinding for monthly and yearly agenda views.
(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :m "y" 'org-agenda-year-view
      :m "m" 'org-agenda-month-view)

(defun bl/toggle-debug-css ()
  "Toggle between using the local custom-org.css file and the remote one."
  (interactive)
  (let* ((custom-css-base-url "https://gitcdn.link/cdn/blester125/dotfiles/master/")
         (custom-css-rel-path "doom.d/custom-org.css")
         (custom-css-url (concat custom-css-base-url custom-css-rel-path))
         (custom-css-path (concat (getenv "HOME") "/dotfiles/" custom-css-rel-path)))
    (let ((to-add 'nil)
          (to-remove 'nul))
      (if (seq-contains-p org--css-locations custom-css-url)
          (setq to-add custom-css-path to-remove custom-css-url)
        (setq to-add custom-css-url to-remove custom-css-path))
      (message "Removing %s and adding %s to CSS location lists." to-remove to-add)
      (setq org--css-locations
            (append (seq-remove (lambda (u) (string-equal u to-remove)) org--css-locations)
                    (list to-add))))))

;; Exporting org files to other formats.
(use-package! ox
  :after org
  :config
  (defvar org--css-locations '("https://gongzhitaao.org/orgcss/org.css"
                               "https://edwardtufte.github.io/et-book/et-book.css"
                               "https://gitcdn.link/cdn/blester125/dotfiles/master/doom.d/custom-org.css")
    "The location where the CSS stylesheet we use for org-mode html exports lives.")
  ;; Use hook to add a css header to the file before exporting it.
  (add-hook! 'org-export-before-parsing-hook #'bl/org--add-css-header)
  ;; The directory where exports will live so they aren't littered around our
  ;; zettelkasten.
  (defvar org--export-directory (concat notes "export/") "Where exported org mode files will appear.")
  ;; Use hook to make sure any image files that are linked to are copied over
  ;; into the export directory.
  (add-hook! 'org-export-before-parsing-hook 'bl/org-export--export-images) ;; Don't bite compile because we check variables.
  ;; Add a function that makes sure the output file name of an export will be
  ;; the absolute path.
  (advice-add 'org-export-output-file-name :filter-return 'file-truename)
  ;; Add a function that runs after org html export that moves the from the
  ;; default export directory (the same one the file is in) into the export
  ;; directory.
  (advice-add 'org-html-export-to-html :filter-return 'bl/org-export--move-output)
  ;; Override the priority html transcoding to turn priority cookies into their
  ;; fancy values.
  (advice-add 'org-html--priority :override 'bl/org-html--priority)
  ;; Don't create a table of contents.
  (setq org-export-with-toc 'nil)
  ;; Don't crash on a broken link.
  (setq org-export-with-broken-links 'mark)
  ;; Use CSS classes/ids to style, not inline style attributes.
  (setq org-html-htmlize-output-type 'css)
  ;; Include priorities in the export
  (setq org-export-with-priority 't)
  ;; Don't include the large `<style></style>' tags in the header as they can
  ;; conflict with our actual style sheet.
  (setq org-html-style-default 'nil)
  (setq org-html-head-include-default-style 'nil)
  (setq org-export-headline-levels 7)
  ;; Create a derived backend based on the html backend so we can add new export
  ;; options to the menu, under the html selector.
  (org-export-define-derived-backend 'html-roam 'html
    :menu-entry
    '(?h 2
         ((?r "Recursive HTML Export." org-html-export-to-html-recursive)
          (?R "Recursive HTML Export and Open."
              (lambda (a s v b)
                (if a (org-html-export-to-html-recursive t s v b)
                  (org-open-file (org-html-export-to-html-recursive nil s v b)))))))))

(defun bl/org-export--move-output (filename &optional base-dir export-dir)
  "When exporting, move the resulting file from `filename' to the `export-dir'

If &optional `base-dir' is specified it is the directory where we expect all
files to live, this lets us export to the same same directory structure. If not
provided it defaults to `org-roam-directory'

If &optional `export-dir' is specified it is the location of the output files,
the result will be a directory structure in `export-dir' the matches the
structure in `base-dir'. If not specified it defaults to `org--export-directory'"
  (unless base-dir (setq base-dir org-roam-directory))
  (unless export-dir (setq export-dir org--export-directory))
  (unless (file-exists-p export-dir)
    (make-directory export-dir))
  (let ((dest (concat export-dir (string-remove-prefix base-dir filename))))
    (message "Moving exported file from %s to %s" filename dest)
    (bl/create-parent-directories dest)
    (rename-file filename dest 't)
    dest))

(defun bl/image-link-p (path)
  "Check if a path most likely links to an image.

Checks is the link is in a /images/ subdir or ends with a commong image file extension."
  (if (or (not (null (string-match-p (regexp-quote "images/") path)))
          (seq-some (lambda (ext) (string-suffix-p ext path)) image-file-name-extensions))
      't))

(defun bl/org-export--export-images (backend)
  "Copy any image that in linked in an exported file to the export images location."
  (ignore backend)
  (let* ((links (bl/org--get-links-from-buffer))
         (image-links (seq-filter (lambda (l) (bl/image-link-p (plist-get l :path))) links))
         ;; We only need to move image files, an image link to the web will work fine.
         (file-image-links (seq-filter (lambda (l) (equal (plist-get l :type) "file")) image-links))
         (image-locs (seq-map (lambda (l) (file-truename (plist-get l :path))) file-image-links))
         (image-export-locs (seq-map (lambda (l) (concat org--export-directory (string-remove-prefix org-roam-directory l))) image-locs)))
    (seq-mapn (lambda (src dst) (bl/create-parent-directories dst) (copy-file src dst 't)) image-locs image-export-locs)))

(defun bl/org--add-css-header (backend)
  "Add a CSS header to each org file as you export it"
  (ignore backend)
  (goto-char (bl/org-end-of-property-drawer (point-min)))
  (newline)
  (seq-map
   (lambda (loc)
     (insert
      (format "#+html_head: <link rel=\"stylesheet\" type=\"text/css\" href=\"%s\"/>\n" loc)))
   org--css-locations))

;; Set the characters that different priorities are displayed as.
(after! org-fancy-priorities
  (setq org-fancy-priorities-list '((?A . "⚑")
                                    (?B . "🔥") ;; They don't support emojis so this looks different in the actual list.
                                    (?C . "⬆")
                                    (?D . "❄")
                                    (?E . "■"))))

(defun bl/org-html--priority (priority info)
  "Replace priority with the fancy symbol for it when exporting."
  (ignore info)
  (and priority
       (format "<span class=\"priority\">%s</span>"
               (org-fancy-priorities-get-value (char-to-string priority)))))

;; This package lets us drag images into emacs where they are inserted at point
;; (where you left your cursor, not where you drag it to). It also supports
;; getting images from a screen shot or you clipboard.
(use-package! org-download
  :after org
  :config
  (setq-default org-download-image-dir images)
  (setq org-download-timestamp "%Y%m%d%H%M%S-")
  (setq org-download-image-org-width 300)
  (setq org-download-image-html-width 500)
  (map! :leader
        (:prefix ("m" . "org-mode")
         (:prefix ("v" . "Paste Images")
          :desc "Insert image from screenshot" "s" 'org-download-screenshot
          :desc "Insert image from clipboard" "c" 'org-download-clipboard))))

(use-package! org-fc
  :after org
  :config
  (setq org-fc-directories `(,(concat zettelkasten "flash_cards")))
  (map! :leader
        (:prefix ("l" . "learning")
         :desc "Review flash cards." "r" 'org-fc-review
         (:prefix ("c" . "create")
          :desc "Create a normal card." "n" 'org-fc-type-normal-init
          :desc "Create a cloze card." "c" 'org-fc-type-cloze-init))))

(defun org-roam-node-insert-immediate (arg &rest args)
  "Insert a node link, creating the node (without human input) if it doesn't exists."
  (interactive "P")
  (let ((args (cons arg args))
        ;; Grab the first template and add the `:immediate-finish t' argument.
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun bl/org-roam-force-full-rebuild ()
  "When new notes files with new org-ids get added, reparse and rebuild to include them."
  (interactive)
  (if (y-or-n-p-with-timeout "Rebuilding the org-roam db and org-id cache can be slow, continue? " 10 'nil)
    (progn
      (message "Rebuilding Org-roam db and org-id cache")
      (delete-file org-roam-db-location)
      (org-id-update-id-locations)
      (org-roam-db-clear-all)
      (org-roam-db-sync)
      (org-roam-update-org-id-locations)
      (org-roam-db-sync))
    (message "Skipping rebuild, goodbye")))

(defun bl/org-roam-light-rebuild ()
  (interactive)
  (org-id-update-id-locations)
  (org-roam-db-sync)
  (org-roam-update-org-id-locations)
  (org-roam-db-sync))

;; A Zettelkasten in org mode, the reason I switched
(use-package! org-roam
  :config
  (setq +org-roam-auto-backlinks-buffer 'nil)
  (map! :leader
        (:prefix ("r" . "roam")
         :desc "Open org-roam backlink panel" "l" #'org-roam-buffer-toggle
         :desc "(i)nsert a new org-roam link" "i" #'org-roam-node-insert
         :desc "(I)nsert a new org-roam link, create with template if missing" "I" #'org-roam-node-insert-immediate
         :desc "(f)ind an org-roam file, create if not found" "f" #'org-roam-node-find
         :desc "Show the org-roam (g)raph" "g" #'org-roam-graph
         :desc "(c)apture a new org-roam note" "c" #'org-roam-capture
         :desc "(s)earch notes" "s" 'bl/org-roam--counsel-rg
         :desc "(n)ew Node by converting an org headline" "n" (lambda () (interactive) (org-id-get-create)(save-buffer))
         (:prefix ("b" . "re(b)uild")
          :desc "re(b)uild org roam db to capture new org-ids" "b" #'bl/org-roam-force-full-rebuild
          :desc "light-weight re(f)resh of org-roam and org-ids" "f" #'bl/org-roam-light-rebuild)
         (:prefix ("r" . "research")
          :desc "(c)ite a bibliographic entry" "c" 'org-cite-insert
          :desc "open (n)otes on a bibliographic entry" "n" 'citar-open-notes
          :desc "(s)earch notes on bibliographic entries" "s" 'bl/org-roam-lit--counsel-rg
          :desc "re(f)resh BibTeX (run when refs.bib is updated)" "f" 'citar-refresh
          :desc "copy (b)ibliographic entry" "b" 'bl/citar-copy-bibtex
          :desc "insert (B)ibliographic entry" "B" 'citar-insert-bibtex
          :desc "copy (r)eference for bibliographic entry" "r" 'citar-copy-reference
          :desc "(o)pen link for a bibliographic entry" "o" 'citar-open
          :desc "open (l)ink for a bibliographic entry" "l" 'citar-open-link)
         (:prefix ("a" . "add")
          :desc "Add a (t)ag to the node" "t" 'org-roam-tag-add
          :desc "Add a (r)ef to the node" "r" 'org-roam-ref-add
          :desc "Add an (a)lias to the node" "a" 'org-roam-alias-add)
         (:prefix ("d" . "delete")
          :desc "Remove a (t)ag from the node" "t" 'org-roam-tag-remove
          :desc "Remove a (r)ef from the node" "r" 'org-roam-ref-remove
          :desc "Remove an (a)lias from the node" "a" 'org-roam-alias-remove)))
  ;; The default text that is populated in a new org-roam note. We define a single
  ;; template so we don't have to select between them.
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+startup: latexpreview inlineimages\n\n")
           :unnarrowed t)))
  ;; A method that counts the number of backlinks a node has. Need to be defined
  ;; after org-roam is loaded to have access to this `org-roam-node' thing.
  (cl-defmethod org-roam-node-backlinkscount ((node org-roam-node))
    (let* ((count (caar (org-roam-db-query [:select (funcall count source)
                                            :from links
                                            :where (and (= dest $s1)
                                                        (= type "id"))]
                                           (org-roam-node-id node)))))
      (propertize (format "[%d]" count) 'face 'shadow)))
  ;; Stop trying to make everything I type a note.
  (setq org-roam-completion-everywhere 'nil)
  (defvar org-roam--backup-directory (concat notes "backups/") "A location where note backups are saved.")
  (defvar org-roam--private-tag "private" "A roam tag that marks a note as private, not for export.")
  ;; Set the tag value that org uses to decide if a subtree should be skipped during export.
  (setq org-export-exclude-tags (list org-roam--private-tag))
  (defvar org-roam--todo-markers '("todo") "A roam tag that marks a file as needing to be parsed for TODOs. The first item in this list will automatically be added to any file that has a TODO.")
  (defvar org-roam--agenda-markers '("agenda") "A roam tag that marks a file as containing agenda items, regardless of it has TODOs.")
  ;; Any file that contains one of the tags above will automatically be searched
  ;; when calling `org-todo-list' or `org-agenda'.
  (defvar org-roam-find-file--ignore-tags (append org-roam--todo-markers org-roam--agenda-markers '("private")) "A list of tags that should not be displated with searching.")
  ;; The formatting string for nodes in the search, shows headline nesting, tags,
  ;; and the backlink count.
  (setq org-roam-node-display-template "${doom-hierarchy:*} ${doom-tags:15} ${backlinkscount:6}")
  ;; Removed from V2: Look for TODOs and update the roam_tags when you open a
  ;; roam file. Updating the todo tags always causes a modification to the file,
  ;; even if we don't change state (for example we already has the todo tag and
  ;; we currently have a TODO item). This causes recursive exporting to ask for
  ;; human input on if a modified buffer should be killed, which we need to avoid.
  ;; (add-hook! 'org-roam-find-file-hook 'bl/org-tags-update-todo)
  ;; Instead we add this as a saving hook when the roam file is loaded. This
  ;; avoids running the hook on non-roam files.
  (add-hook! 'org-roam-find-file-hook (add-hook! 'before-save-hook :local 'bl/org-tags-update-todo))
  ;; Query the Org-Roam db for files with TODO/agenda tasks before loading the
  ;; org-agenda or todo list.
  (advice-add 'org-agenda :before #'bl/update-agenda-files)
  (advice-add 'org-todo-list :before #'bl/update-agenda-files)
  ;; Use my custom function which removes some tags (like TODO) when searching for nodes.
  (advice-add 'org-roam-node-doom-tags :filter-return 'bl/org-roam-node-doom-tags)
  ;; Stop org-roam from prepending # to my tags, looks bad.
  (setq org-roam-node-template-prefixes (delete '("doom-tags" . "#") org-roam-node-template-prefixes))
  ;; Convert the doom hierarchy formatting to my better looking one.
  (advice-add 'org-roam-node-doom-hierarchy :filter-return 'bl/org-roam-node-doom-hierarchy)
  (setq org-roam-dailies-directory "journal/")
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %<%H:%M> %^{title}\n%i%?"
           ;; By setting `olp' (OutLine Path) we can have all entries be
           ;; inserted after that path. This lets us keep a top level header and
           ;; have journal entries be second level, which is consistent with old
           ;; notes, and just nicer to look at.
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%A, %d %B %Y>\n#+setup: latexpreview inlineimages\n#+filetags: :journal:\n"
                                  ("Journal")))))
  ;; Hacks to deal with goto triggering a template fill.
  (defvar bl/blank-org-roam-dailies-capture-templates
        '(("d" "default" entry
           ""
           ;; By setting `olp' (OutLine Path) we can have all entries be
           ;; inserted after that path. This lets us keep a top level header and
           ;; have journal entries be second level, which is consistent with old
           ;; notes, and just nicer to look at.
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%A, %d %B %Y>\n#+setup: latexpreview inlineimages\n#+filetags: :journal:\n"
                                  ("Journal"))))
        "A version of the daily template with nothing to fill as a goto hack")
  (defun bl/org-roam-dailies-goto-template-patch (fun &rest args)
    (let ((org-roam-dailies-capture-templates bl/blank-org-roam-dailies-capture-templates))
      (apply fun args)))
  (advice-add 'org-roam-dailies-goto-today :around 'bl/org-roam-dailies-goto-template-patch)
  (advice-add 'org-roam-dailies-goto-yesterday :around 'bl/org-roam-dailies-goto-template-patch)
  (advice-add 'org-roam-dailies-goto-tomorrow :around 'bl/org-roam-dailies-goto-template-patch)
  (advice-add 'org-roam-dailies-goto-date :around 'bl/org-roam-dailies-goto-template-patch)

  (map! :leader
        :prefix ("j" . "journal")
        :desc "Capture a new entry for today's note" "c" 'org-roam-dailies-capture-today
        :desc "Open the note for today" "j" 'org-roam-dailies-goto-today
        :desc "Move to the previous note" "h" 'org-roam-dailies-goto-previous-note
        :desc "Move to the next note" "l" 'org-roam-dailies-goto-next-note
        :desc "Search in the journal" "s" 'bl/org-roam-dailies--counsel-rg
        :desc "Capture a new entry for the note at `date'" "d" 'org-roam-dailies-capture-date
        :desc "Open the note for `date'" "D" 'org-roam-dailies-goto-date
        :desc "Capture a new entry for yesterday's note" "y" 'org-roam-dailies-capture-yesterday
        :desc "Open the note for yesterday" "Y" 'org-roam-dailies-goto-yesterday
        :desc "Capture a new entry for tomorrow's note" "t" 'org-roam-dailies-capture-tomorrow
        :desc "Open the note for tomorrow" "T" 'org-roam-dailies-goto-tomorrow)
  ;; I can't stand how org-roam leave your point at the beginning of the link
  ;; when you insert a new one. Override with the `org-with-point-at' removed.
  (defun bl/org-roam-capture--finalize-insert-link ()
    "Insert a link to ID into the buffer where Org-capture was called.
     ID is the Org id of the newly captured content.
     This function is to be called in the Org-capture finalization process."
    (when-let* ((mkr (org-roam-capture--get :call-location))
                (buf (marker-buffer mkr)))
    (with-current-buffer buf
      (when-let ((region (org-roam-capture--get :region)))
        (org-roam-unshield-region (car region) (cdr region))
        (delete-region (car region) (cdr region))
        (set-marker (car region) nil)
        (set-marker (cdr region) nil))
      (insert (org-link-make-string (concat "id:" (org-roam-capture--get :id))
                                    (org-roam-capture--get :link-description))))))

  (advice-add 'org-roam-capture--finalize-insert-link :override 'bl/org-roam-capture--finalize-insert-link)
  (advice-add 'org-roam-node-read--to-candidate :override 'bl/org-roam-node-read--to-candidate))

(defun bl/org-roam-node-read--to-candidate (node template)
  "Return a minibuffer completion candidate given NODE.
TEMPLATE is the processed template used to format the entry."
  (let ((candidate-main (org-roam-node--format-entry
                         template
                         node
                         (1- (frame-width)))))
    (cons (propertize candidate-main 'node node) node)))

(defun bl/org-roam-node-doom-tags (tags)
  "Remove ignored tags from the roam search formatting.

Removes any tag in tags (which is formatted as an org tag string) that are present
in `org-roam-find-file--ignore-tags'

Applies the `shadow' face as a property, like the default doom-tags does."
  (when tags
    ;; Remove dups in-case the directory tag inference is the same as explicit tags.
    (let ((tags (delete-dups (seq-remove (lambda (elt) (member elt org-roam-find-file--ignore-tags)) tags))))
      (propertize (org-make-tag-string tags) 'face 'shadow))))

(defun bl/org-roam-node-doom-hierarchy (hierarchy)
  "Flip the doom hierarchy of nodes so the child heading is first."
  (let ((splitter " → ")
        (joiner (propertize " « " 'face 'shadow)))
    (string-join (reverse (split-string-and-unquote hierarchy splitter)) joiner)))

(defun bl/org-roam--counsel-rg (&optional INITIAL-INPUT)
  "Full text search with counsel-rg (using ripgrep) specific to searching my notes."
  (interactive)
  ;; Only search org files in the zettelkasten. We also set the prompt to be more informative.
  ;; Note: It uses smart casing search. This means when your search uses lowercase
  ;; it is case-insensitive, but adding an upper case makes it case-sensative
  ;; (counsel-rg INITIAL-INPUT org-roam-directory "--type org" "org-roam search: "))
  ;; TODO: Update the settings with `consult-ripgrep-command'
  (consult-ripgrep org-roam-directory))

(defun bl/org-roam-dailies--counsel-rg (&optional INITIAL-INPUT)
  "Full text search with counsel-rg (using ripgrep) specific to searching my journal."
  (interactive)
  ;; Only search org files in the zettelkasten. We also set the prompt to be more informative.
  ;; Note: It uses smart casing search. This means when your search uses lowercase
  ;; it is case-insensitive, but adding an upper case makes it case-sensative
  ;; (counsel-rg INITIAL-INPUT (expand-file-name org-roam-dailies-directory org-roam-directory) "--type org" "org-roam-journal search: "))
  (consult-ripgrep (expand-file-name org-roam-dailies-directory)))

(defun bl/org-roam-lit--counsel-rg (&optional INITIAL-INPUT)
  "Full text search with counsel-rg (using ripgrep) specific to searching my journal."
  (interactive)
  ;; Only search org files in the zettelkasten. We also set the prompt to be more informative.
  ;; Note: It uses smart casing search. This means when your search uses lowercase
  ;; it is case-insensitive, but adding an upper case makes it case-sensative
  ;; (counsel-rg INITIAL-INPUT lit "--type org" "org-roam-lit search: "))
  (consult-ripgrep lit))

(defvar bl/org-roam-create-closest-node-from-search ""
  "When inserting an org-roam link from a `rg' search, create a node on the closet headline. When nil, use the first org-roam node you find.")

(defun bl/ivy-insert-org-roam-link (candidate)
  "Insert an org-roam link based on the selected file from search.

Assumes the candidates are in the format `file-name:line-number:...'. Currently
this function uses (or creates) the org node for the closest headline. Can be
edited to instead just use the enclosing org-roam node, creating one at the
top-level is there are none in the file."
  (interactive)
  ;; Make things like insert go into the caller buffer instead of the minibuffer.
  (with-ivy-window
    (pcase-let* ((`(,filename, line-number) (split-string candidate ":"))
                 ;; Switch to the buffer of the file from the search and find/create
                 ;; the nearest org-roam node.
                 (id (with-current-buffer (find-file-noselect filename)
                     (save-excursion
                       (goto-char (point-min))
                       ;; Jump forward to the line the match was on.
                       (forward-line (string-to-number line-number))
                       (if bl/org-roam-create-closest-node-from-search
                           ;; This `let' will create a new org-roam node for the
                           ;; nearest headline.
                           (let ((id (org-id-get-create)))
                             ;; Save the file and update the db in case we had to
                             ;; create a new node.
                             (save-buffer)
                             (org-roam-db-update-file filename)
                             id)
                         ;; This `let' will use the nearest org-roam node, creating
                         ;; one if there is none in the file.
                         (let ((node (org-roam-node-at-point)))
                           ;; Save the file and update the db in case we had to
                           ;; create a new node.
                           (save-buffer)
                           (org-roam-db-update-file filename)
                           (org-roam-node-id node))))))
                 ;; Get node information from the id, will pull db which is why
                 ;; we saved the file after (possibly) making an org-roam node.
                 (node (org-roam-node-from-id id))
                 (title (org-roam-node-title node)))
      ;; Create and insert a id link.
      (insert org-make-link-string (concat "id:" id) title))))

;; Don't include template text when created a org file from scratch, it doesn't
;; happen often and there isn't a real need.
(set-file-template! "\\.org$" :ignore t)

;; Override the default themes awful background for markdown code block backgrounds.
(custom-set-faces!
  '((org-block markdown-code-face) :background nil))

;; Citation Related settings
;; TODO can we update this template to remove things that don't get filled in?
(defvar lit-note-template (concat ":properties:\n"
                                  ":author: ${author-abbrev}\n"
                                  ":journal: ${journal}\n"
                                  ":booktitle: ${booktitle}\n"
                                  ":date: ${date}\n"
                                  ":year: ${year}\n"
                                  ":doi: ${doi}\n"
                                  ":url: ${url}\n"
                                  ":roam_refs: @${=key=}\n"
                                  ":end:\n"
                                  "#+title: ${title}\n"
                                  "#+setup: latexpreview inlineimages\n"
                                  "#+category: Lit\n\n")
"The template for creating a new Literature Note.")

(use-package! oc
  :after org
  :config
  (setq org-cite-csl-styles-dir (concat notes "csl-styles"))
  (setq org-cite-global-bibliography (list bib)))

(custom-set-faces!
  '(org-cite :foreground "DarkSeaGreen4")
  '(org-cite-key :foreground "forest green"))

(use-package! oc-csl
  :after oc
  :config
  ;; Setup my HTML export to use my modified ACL style.
  (setq org-cite-export-processors '((html csl "association-for-computational-linguistics.csl")
                                     (latex biblatex)
                                     (t basic))))

;; Used to manage finding csl files?
(use-package! citeproc
  :after oc-csl)

(defun bl/citar-copy-bibtex (keys-entries)
  "Copy bibliographic entry associated with the KEYS-ENTRIES.
With prefix, rebuild the cache before offering candidates."
  (interactive (list (citar-select-refs
                      :rebuild-cache current-prefix-arg)))
  (dolist (key (citar--extract-keys keys-entries))
    (bl/citar--copy-bibtex key)))

(defun bl/citar--copy-bibtex (key)
  "Copy the bibtex entry for KEY."
  (let* ((bibtex-files
          (seq-concatenate 'list citar-bibliography (citar--local-files-to-cache)))
         (entry
          (with-temp-buffer
            (bibtex-set-dialect)
            (dolist (bib-file bibtex-files)
              (insert-file-contents bib-file))
            (bibtex-find-entry key)
            (let ((beg (bibtex-beginning-of-entry))
                  (end (bibtex-end-of-entry)))
              (buffer-substring-no-properties beg end)))))
    (unless (equal entry "")
      (kill-new entry)
      (message "Copied: %s" entry))))

(use-package! citar
  :after oc
  :config
  (setq citar-bibliography (list bib))
  (setq citar-notes-paths (list lit))
  ;; Update the icons for entries in the citar search
  (setq citar-symbols
    `((file ,(all-the-icons-faicon "file-o" :face 'all-the-icons-green :v-adjust -0.1) . " ")
      (note ,(all-the-icons-material "speaker_notes" :face 'all-the-icons-blue :v-adjust -0.3) . " ")
      (link ,(all-the-icons-octicon "link" :face 'all-the-icons-orange :v-adjust 0.01) . " ")))
  (setq citar-symbol-separator "  ")
  (setq citar-at-point-function 'embark-act)
  (setq citar-templates
    '((main . "${date year issued:4}  ${author editor:40}      ${title:*}")
      (suffix . "          ${=key= id:15}    ${=type=:12}    ${tags keywords:*}")
      (preview . "${author editor} (${year issued date}) ${title}, ${journal journaltitle publisher container-title collection-title}.\n")
      (note . "Notes on ${author editor}, ${title}")))
  ;; Add my copy bibtex action to embark menu on an org-cite link.
  (setq citar-citation-map
    (let ((map (make-sparse-keymap)))
      (set-keymap-parent map citar-citation-map)
      (define-key map (kbd "b") #'bl/citar-copy-bibtex)
      map))
  (setq citar-map
    (let ((map (make-sparse-keymap)))
      (set-keymap-parent map citar-map)
      (define-key map (kbd "b") #'bl/citar-copy-bibtex)
      map))
  ;; Add print bibliography directives to org files that have citations in them.
  (add-hook! 'org-export-before-parsing-hook #'bl/org-cite--add-bibliography-link))
  ;; Make sure we don't byte complie this function (`#'), we need to read the
  ;; value of `default-directory' which might change.
  ;; (add-hook! 'org-export-before-parsing-hook 'bl/org-export--add-ref-note-links)

;; Created to wrap 'orb-edit-note
(defun bl/orb-templates (fun &rest args)
  "Update org roam capture templates to just be the orb ones for orb calls."
  (let ((org-roam-capture-templates orb-capture-templates))
    (apply fun args)))

(use-package! org-roam-bibtex
  :after org-roam
  :config
  (require 'citar)
  (setq orb-roam-ref-format 'org-cite)
  (setq bibtex-completion-bibliography bib)
  ;; Open notes and populate them with the orb templates.
  (setq citar-open-note-function 'orb-citar-edit-note)
  (setq orb-preformat-keywords
        '("citekey" "title" "url" "file" "author-or-editor" "keywords" "ref"
          "author-abbrev" "journal" "booktitle" "date" "year" "doi" "=key="))
  (defvar orb-capture-templates `(("r" "bibliography note template" plain "%?"
                                   :target (file+head "lit/${citekey}.org"
                                                      ,lit-note-template)
                                   :unnarrowed t)) "Capture when making a lit note")
  (advice-add 'orb-edit-note :around 'bl/orb-templates)
  (advice-add 'citar-create-note :override 'orb-edit-note))

(defun ref-exists-p (citekey)
  "Check that CITEKEY exists in any of the bibs in `bibtex-completion-bibliography'."
  (if citekey
      ;; Ignore warning when we can't find the key.
      (let ((warning-suppress-types '((:warning))))
        (bibtex-completion-get-entry citekey))))

(defun bl/org-cite--add-bibliography-link (backend)
  "If cite links appear in an org file, add markup to create a bibliography on export.

We need to parse the buffer for this because we don't have access to the filename.

The BACKEND argument is ignored.

Adds and extra headline (and css it make it invisible) before the bibliography
so it is not hidden by the final headline being private."
  ;; Get the top level org-roam node and see if it has a :ROAM_REFS:
  (save-excursion
    (goto-char (point-min))
    (let* ((node (org-roam-node-at-point))
           ;; TODO Handle cases where there are multiple :ROAM_REFS:
           (ref (when node (car (org-roam-node-refs node))))
           (ref-lookup (ref-exists-p ref)))
      ;; Add a bibliography if we have cite links in the buffer or if the
      ;; :ROAM_REF: is a cite-link
      (when (or ref-lookup
                (bl/org-cite--get-citation-keys-from-buffer))
          (goto-char (point-max))
          (newline)
          ;; Add a new headline (which makes sure the bibliography is visible even if
          ;; the last headline is private). Set the `HTML_CONTAINER_CLASS' property
          ;; for this headling, this will cause the parent of the h2 tag (representing
          ;; this headline) to have and extra class. We set this class to BIBLIOGRAPHY
          ;; so the headline will be styled with display: none;
          (insert "* Bibliography \n:PROPERTIES:\n:HTML_CONTAINER_CLASS: BIBLIOGRAPHY\n:END:\n")
          (insert "#+print_bibliography: :numbered t\n")
          (when (equal backend 'html)
              (insert "* \n:PROPERTIES:\n:HTML_CONTAINER_CLASS: SELFLINK\n:END:\n")
              ;; If the :ROAM_REFS: is present, add a new secret citelink (which is
              ;; hidden with CSS) for it. This will force the bibliography to contain a
              ;; reference to this paper (that the note is on). It will also trigger a
              ;; bibliography if there are no other citelinks on the page.
              (if ref-lookup (insert (format "[cite:@%s]\n" ref))))))))

;; Several of the next functions are designed to speed up agenda/todo collection
;; over my roam files by only searching ones that are marked with a
;; `#+filetags: :todo:'
(defun bl/todo-file-p ()
  "Return non-nil if the current buffer has any TODO entry."
  (org-element-map
      (org-element-parse-buffer 'headline)
      'headline
    (lambda (h)
      (eq (org-element-property :todo-type h)
          'todo))
    nil 'first-match))

(defun bl/org-tags-update-todo (&optional marker)
  "Update the TODO tags in a buffer by adding a tag with the value of MARKER."
  (unless marker (setq marker (car org-roam--todo-markers)))
  (when (and (not (active-minibuffer-window))
             (org-roam-file-p buffer-file-name))
    (save-excursion
      ;; Jump to the start of the file so the marker is always added to filetags.
      (goto-char (point-min))
      (if (bl/todo-file-p)
          (org-roam-tag-add (list marker))
        (condition-case err
            (org-roam-tag-remove (list marker))
          (error
           (message "Failed to remove tag %s, no tag to remove" marker)))))))

(defun bl/like-query (str)
  "Format STR into a db 'like' query that checks if str is a substring."
  (concat "%\"" str "\"%"))

(defun bl/find-tagged-files (tag)
  "Find all roam-db files tagged with TAG."
  (seq-map
   #'car ;; The db returns tuples for rows so grab the first item from each tuple.
   (org-roam-db-query
    [:select :distinct nodes:file
     :from nodes
     :left :outer :join tags :on (= tags:node-id nodes:id)
     :where (like tags:tag $r1)] (bl/like-query tag))))

(defun bl/find-roam-todo-agenda-files (&optional markers)
  "Return a list of org-roam files containing TODO entries."
  (unless markers (setq markers (append org-roam--todo-markers org-roam--agenda-markers)))
  (delete-dups (flatten-tree (seq-map #'bl/find-tagged-files markers))))

(defun bl/update-agenda-files (&rest _)
  "Update the value of `org-agenda-files'."
  (interactive)
  (if (boundp 'org-gcal-org-file)
      (setq org-agenda-files (append (list org-gcal-org-file) (bl/find-roam-todo-agenda-files)))
    (setq org-agenda-files (bl/find-roam-todo-agenda-files))))

;; Several of the next functions are used to recursively export files and follow
;; their links. Results in the export of a connected component in the graph. Use
;; a cache of exported files to avoid infinite loops.
(defun bl/org--link-info (link)
  "Parse a link into a property list."
  (let ((link-path (org-element-property :path link))
        (link-type (org-element-property :type link))
        (link-desc (when-let ((start (org-element-property :contents-begin link))
                              (end (org-element-property :contents-end link)))
                     (buffer-substring start end)))
        (link-start (org-element-property :begin link))
        ;; Get the end of the actual link, without the following blanks.
        (link-end (- (org-element-property :end link)
                     (org-element-property :post-blank link))))
    (list :type link-type
          :path link-path
          :description link-desc
          :start link-start
          :end link-end)))

(defun bl/org--get-links-from-buffer ()
  "Get all links in an org buffer."
  (interactive)
  (org-element-map (org-element-parse-buffer) 'link 'bl/org--link-info))

(defun bl/org-ref--split-link (link)
  "Split an org-ref link with multiple parts (paperA,paperB,...) into multiple links."
  (let* ((refs (org-ref-split-and-strip-string (plist-get link :path))))
     (seq-map (lambda (r) (plist-put (copy-tree link) :path r)) refs)
  ))

(defun bl/org-end-of-property-drawer (&optional point)
  "Find the end of a property draw at `point'.

This is the actual end of the drawer, not the body. It is safe to insert text
at the returned point. I normally call `(newline)' before inserting."
  (unless point (setq point (point)))
  (pcase-let ((`(,beg . ,end) (org-get-property-block point)))
    (ignore beg)
    (if end
        (+ end (length ":end:"))
      point)))

(defun bl/org-cite--get-citation-keys-from-buffer ()
  "Get all citation keys from the current buffer."
  (interactive)
  (let ((refs (org-element-map (org-element-parse-buffer) 'citation-reference (lambda (x) x))))
    (seq-map (lambda (r) (org-element-property :key r)) refs)))

(defun org-html-export-to-html-filename (filename &optional async subtreep visible-only body-only ext-plist)
  "Export an org mode file to html via filename."
  (interactive)
  ;; Create a temp buffer and dump the org contents into it.
  (with-temp-buffer
    (let* ((fullname (file-truename filename))
           (export-name (concat (file-name-sans-extension filename) ".html")))
      (message "Exporting: %s to %s" fullname export-name)
      (insert-file-contents fullname)
      (goto-char (bl/org-end-of-property-drawer (point-min)))
      (newline)
      ;; ox-html want the name of the buffer to turn it into a `.html' file, but
      ;; the temp-buffer doesn't have a name. Instead we insert a org option to
      ;; set the exported name directly in the buffer. ox-html will happily use
      ;; this name without checking the buffer name or asking us for a name.
      (insert (format "#+EXPORT_FILE_NAME: %s\n" export-name))
      ;; Set the default-directory to the directory of the org-file filename for
      ;; this export call. Theses means that when our hook to add ref links
      ;; tries to turn the absolute names from org-roam into relative they will
      ;; be relative to this file. Otherwise you end up with
      ;; `.../lit/lit/note.html' links when you export a lit note.
      (let ((default-directory (file-name-directory filename)))
        ;; If there is an error in exporting, log it and move on instead of
        ;; crashing.
        (condition-case err
            (org-html-export-to-html async subtreep visible-only body-only ext-plist)
          (error
           (message "%s failed to export" fullname)
           (message "%s" (error-message-string err))))))))

(defun bl/org-roam--id-link-to-file (link)
  "Convert a roam ID link into a file link."
  (list :path (caar (org-roam-db-query [:select :distinct nodes:file
                                        :from nodes
                                        :where (= nodes:id $s1)] (plist-get link :path)))
        :type "file"))

(defun -org-html-export-to-html-filename-recursive (filename &optional async subtreep visible-only body-only ext-plist exported)
  "Export an org file and all the files it links too.

Exports a connected component of your note graph via depth first search. Exported
files are kept in a set to avoid circular exports.

Returns a list where the `car' is the name of the resulting export for this file
and the `cdr' is the set of files already exported."
  (interactive)
  (message "Exported already: %s" exported)
  (let ((fullname (file-truename filename))
        (exported-file 'nil))
    ;; Only export if we have not exported in the past.
    (unless (member fullname exported)
      ;; Add ourselves to the exported set.
      (push fullname exported)
      (message "Recursively exporting: %s" fullname async subtreep visible-only body-only ext-plist)
      ;; We read the file in again to find the links because it is was easy, this
      ;; should be updated to use the org roam db. We should also filter based on
      ;; some org tags.
      (let* ((links (bl/org-roam--get-outbound-links-with-notes-over-cites fullname))
             ;; These are the translation of all outbound id links to files that need to be exported.
             (id-links (seq-remove (lambda (l) (not (equal (plist-get l :type) "id"))) links))
             (roam-links (delete-dups (seq-map 'bl/org-roam--id-link-to-file id-links)))
             ;; These are any note links that were inferred from cite links and inserted as file links.
             (file-links (seq-remove (lambda (l) (not (equal (plist-get l :type) "file"))) links))
             ;; This makes sure they are org files and not things like images.
             (org-links (seq-remove (lambda (l) (not (equal (file-name-extension (plist-get l :path)) "org"))) file-links))
             ;; Merge any files I need to follow.
             (org-links (append roam-links org-links)))
        (message "Roam id links to follow: %s" roam-links)
        (message "Org Links to follow: %s" org-links)
        (message "All file links: %s" file-links)
        (message "All links: %s" links)
        (dolist (org-link org-links)
          ;; Recursively export each of the links. Save the returned set of files
          ;; that have already been exported.
          (setq exported (nth 1 (-org-html-export-to-html-filename-recursive (plist-get org-link :path) async subtreep visible-only body-only ext-plist exported))))
        ;; Export actually export our self.
        (setq exported-file (org-html-export-to-html-filename filename async subtreep visible-only body-only ext-plist))))
    (list exported-file exported)))

(defun org-html-export-to-html-filename-recursive (filename &optional async subtreep visible-only body-only ext-plist)
  "Wrapper around recursive export for cleaner interface."
  (nth 0 (-org-html-export-to-html-filename-recursive filename async subtreep visible-only body-only ext-plist)))

(defun org-html-export-to-html-recursive (&optional async subtreep visible-only body-only ext-plist)
  "A wrapper around by function that converts from a buffer export to a filename based one.

This is what we use to access it from the `org-export' menu (SPC m e h)."
  (let ((filename (buffer-file-name)))
    (org-html-export-to-html-filename-recursive filename async subtreep visible-only body-only ext-plist)))

(defun bl/org-roam--build-index-file (filename &optional include-private dir-name)
  "Create an index file linking to all notes.

Save the index file to `${dir-name}{filename}'. If `inculde-private' is true links
to private notes will be included.

The index is sorted in Alphabetical order, with normal notes coming first and lit
notes coming after."
  (unless dir-name (setq dir-name org-roam-dictionary))
  ;; Create a new file to insert into.
  (with-temp-file (concat dir-name filename)
    ;; Insert a title and the general notes headline.
    (insert "#+title: Index\n")
    (insert "* Notes\n")
    ;; Get the files that have notes and all the nodes themselves, include the
    ;; following information `id', `title', `level', `pos', and `file'.
    (let ((notes (bl/org-roam--list-note-files include-private))
          (nodes (if include-private
                     (org-roam-db-query [:select :distinct [nodes:id nodes:title nodes:level nodes:pos nodes:file]
                                         :from nodes])
                   (org-roam-db-query [:select :distinct [nodes:id nodes:title nodes:level nodes:pos nodes:file]
                                       :from nodes
                                       :left :outer :join tags :on (= nodes:id tags:node-id)
                                       :where (or (is tags:tag 'nil)
                                                  (not-like tags:tag $r1))]
                                      (bl/like-query org-roam--private-tag)))))
        ;; We need to set the hash table :test to `equal' because we are using
        ;; string keys and the default :test would check item identity instead
        ;; of item value when given keys. So `gethash' would always return `nil'
        (let ((file-to-node (make-hash-table :size (length notes) :test 'equal))
              (title-to-file (make-hash-table :size (length notes) :test 'equal))
              (titles)
              (note-section 't))
          ;; Build a mapping from file name to the nodes in the file
          (dolist (node nodes)
            ;; Destructure the node into parts for ease of use.
            (pcase-let* ((`(,id ,title ,level ,pos ,file) node)
                         ;; Get any nodes already associated with this file
                         (value (gethash file file-to-node))
                         ;; Add new file
                         (with-node (append value (list (list :title title :id id :level level :pos pos)))))
              ;; Add to hash table
              (puthash file with-node file-to-node)
              ;; `level=0' implies the node is the top-level filenode so its
              ;; title is the title of the file, save that and build a list of
              ;; titles.
              (when (= level 0)
                (puthash title file title-to-file)
                (setq titles (append titles (list title))))))
          (dolist (title (sort (sort titles #'string>) ;; Sort title alphabetically
                         ;; Sort titles so lit files come after the normal nodes.
                         (lambda (a b)
                           "Return t if a should sort before b"
                           (let ((lit-a (string-match-p "lit/" (gethash a title-to-file)))
                                 (lit-b (string-match-p "lit/" (gethash b title-to-file))))
                             (cond
                              ((and lit-a lit-b) 't)
                              ((and (not lit-a) (not lit-b)) 't)
                              ((and (not lit-a) lit-b) 't)
                              ((and lit-a (not lit-b)) 'nil))))))
            (let ((file (gethash title title-to-file)))
              ;; When we hit the first lit note, add a lit header. We check if
              ;; we are still in the note section to short circuit and not have
              ;; to check file strings.
              (if (and note-section (string-match-p "lit/" file))
                  (progn
                    (insert "* Lit\n")
                    (setq note-section 'nil)))
              ;; Sort nodes based on their position in the file, so we always
              ;; have the links in the same order as they appear in the file.
              (dolist (node (sort (gethash file file-to-node)
                                  (lambda (a b) (if (< (plist-get a :pos) (plist-get b :pos))
                                                    't
                                                  'nil)))) ;; sort by :pos
                ;; Add a link to the node.
                (insert (format "%s [[id:%s][%s]]\n"
                                ;; Set the heading to 2 + the level. The level
                                ;; starts at `0' so add 1 so that everything has
                                ;; at least one header, and add another to
                                ;; account for the `Note' and `Lit' headers we
                                ;; already have as top-level headers.
                                (make-string (+ (plist-get node :level) 2) ?*)
                                (plist-get node :id)
                                (plist-get node :title))))))))))

(defun bl/org-export--all-notes (&optional include-private)
  "Export all notes to html.

If &optional `include-private' is non-nil, include notes marked with a 'private'
tag. The value for the private tag is defined by `org-roam--private-tag'.

Creates and exports an `index.html' that has links to all the nodes. Note: the
created index.org is removed so it doesn't accidentally become an org-roam node
and mess things up."
  (interactive)
  (let ((exported '())
        (notes (bl/org-roam--list-note-files include-private)))
    (dolist (note notes)
      ;; Don't re-export things.
      (unless (member note exported)
        ;; Update our set of exported files with all the files exported from this
        ;; recursive export expansion.
        (let* ((results (-org-html-export-to-html-filename-recursive note))
               (exported-files (nth 1 results)))
          (setq exported (append exported exported-files)))))
    (bl/org-roam--build-index-file "index.org" include-private org-roam-directory)
    (let ((exported (org-html-export-to-html-filename (concat org-roam-directory "index.org"))))
      (delete-file (concat org-roam-directory "index.org"))
      exported)))

(defun bl/org-export--all-notes-and-open (&optional include-private)
  "Export all notes to html and open the index file."
  (interactive)
  (org-open-file (bl/org-export--all-notes include-private)))

;; The next few functions are about munging cite links to create and add links
;; to their actual notes during export.
(defun bl/org-roam--get-notes-from-ref (ref)
  "Find the note file associated with `ref' return nil if notes do not exist."
  (caar (org-roam-db-query [:select :distinct nodes:file
                            :from nodes
                            :left :outer :join refs :on (= refs:node-id nodes:id)
                            :where (= refs:ref $s1)] ref)))

(defun bl/org-ref--make-note-link (note-loc &optional description superscript)
  "Turn a note location into insertable link text.

If &optional `description' is provided use that as the link text, otherwise the
text will be '(notes)'.

If &optional `superscript' is non-nil, the link will be a inserted such that it
exports to a superscript.
"
  (unless description (setq description "(notes)"))
  (let ((link (format "[[file:%s][%s]]" note-loc description)))
    (if superscript
        (format "^{%s}" link)
        link)))

;; TODO Update to work with org-cite links
(defun bl/org-export--add-ref-note-links (backend)
  "Add links to notes from any cite link that has a note.

We need to use the buffer based parsing so that we have access to the cite-link
locations."
  (interactive)
  (ignore backend)
  (let* ((cite-links (bl/org-cite--get-citation-keys-from-buffer))
         ;; How many characters we have already inserted into the buffer,
         ;; shifting where the ends are now.
         (offset 0))
    (dolist (cite-link cite-links)
      (when-let* ((note-loc (bl/org-roam--get-notes-from-ref (plist-get cite-link :path)))
                  (note-rel (file-relative-name note-loc))
                  (note-link (bl/org-ref--make-note-link note-rel 'nil 't))
                  (start (plist-get cite-link :end)))
        (unless (bl/org-roam--file-private-p note-loc)
          (goto-char (+ offset start))
          (insert note-link)
          (setq offset (+ offset (length note-link))))))))

(defun bl/org-roam--get-outbound-cite-links (filename)
  "Find all cite-links in a file by querying the org-roam db."
  (org-roam-db-update-file filename)
  (when-let* ((links (org-roam-db-query
                      [:select :distinct links:dest
                       :from links
                       :left :outer :join nodes :on (= links:source nodes:id)
                       :where (and (= links:type "cite")
                                   (= nodes:file $s1))] filename))
              (links (seq-map (lambda (p) (list :path (car p) :type "cite")) links)))
    (apply #'append (seq-map 'bl/org-ref--split-link links))))

(defun bl/org-roam--list-note-files (&optional include-private)
  "Get the names of all the notes in the zettelkasten

If &optional `include-private' is non-nil, then fetch all notes, even ones with
'private' tags. The value for the private tag is set with `org-roam--private-tag'

Returns a list of note file names."
  (let ((notes (if include-private
                   (org-roam-db-query [:select :distinct file :from files])
                 (org-roam-db-query [:select :distinct files:file
                                     :from files
                                     :left :outer :join nodes :on (= files:file nodes:file)
                                     :left :outer :join tags :on (= nodes:id tags:node-id)
                                     :where (or (is tags:tag 'nil)
                                                (not-like tags:tag $r1))] (bl/like-query org-roam--private-tag)))))
    (seq-map 'car notes)))

(defun bl/org-roam--get-outbound-links (filename &optional include-private)
  "Find all links in a file by querying the org-roam db.

If &optional `include-private' is non-nil, then fetch all notes, even ones with
'private' tags. The value for the private tag is set with `org-roam--private-tag'

Returns a list of link plists with attributes `:path' and `:type'
"
  (org-roam-db-update-file filename) ;; Make sure DB information is up to date.
  (when-let* ((links (if include-private
                         (org-roam-db-query [:select :distinct [links:dest links:type]
                                             :from links
                                             :left :outer :join nodes :on (= links:source nodes:id)
                                             :where (= nodes:file $s1)] filename)
                       (org-roam-db-query [:select :distinct [links:dest links:type]
                                           :from links
                                           :left :outer :join nodes :on (= links:source nodes:id)
                                           :left :outer :join tags :on (= links:dest tags:node-id)
                                           :where (and (= nodes:file $s1)
                                                       (or (is tags:tag 'nil)
                                                           (not-like tags:tag $r2)))] filename (bl/like-query org-roam--private-tag))))

              ;; Turn our link results into plists.
              (links (seq-map (lambda (l) (list :path (car l) :type (nth 1 l))) links)))
    ;; A cite link should never be private.
    ;; We split links in the form cite:paper1,paper2... into multiple links. We also wrap
    ;; non-cite-links in a list so they don't get pulled part in the apply #'append call.
    (apply #'append (seq-map (lambda (l) (if (equal (plist-get l :type) "cite") (bl/org-ref--split-link l) (list l))) links))))

;; Works for V2
(defun bl/org-roam--file-private-p (filename)
  "Return t if the filename is a private file, 'nil otherwise.

Only files with a top level `filetags'=:private: are considered private files.
A file with private nodes is still public."
  (org-roam-db-update-file filename) ;; Make sure DB information is up to date.
  (let ((private (org-roam-db-query [:select :distinct [nodes:id tags:tag]
                                     :from nodes
                                     :left :outer :join tags :on (= nodes:id tags:node-id)
                                     :where (and
                                             (= nodes:file $s1)
                                             (like tags:tag $r2)
                                             (= nodes:level 0))]
                                    filename (bl/like-query org-roam--private-tag))))
    (if private
        't
      'nil)))

(defun bl/org-roam--get-outbound-links-with-notes-over-cites (filename &optional include-private)
  "Get all links in a file, but replace cite links with a link to their notes file.

Finds all links in the buffer for `filename'. If &optional `include-private' is
non-nil then even links to notes that have 'private' as a roam tag will be
included in the return.

Returns a list of file plists with `:path' and `:type' attributes.
"
  (setq-local result '())
  (when-let ((links (bl/org-roam--get-outbound-links filename include-private)))
    (dolist (link links)
      (let ((type (plist-get link :type))
            (path (plist-get link :path)))
        (if (equal type "cite")
            ;; If we are a cite link and there is a note for it, add that. (Omit
            ;; if the note is private).
            (let ((note-loc (bl/org-roam--get-notes-from-ref path)))
              (if note-loc
                  (if (or include-private (not (bl/org-roam--file-private-p note-loc)))
                      (add-to-list 'result (list :path note-loc :type "file")))
                (add-to-list 'result link)))
            ;; Add all other links.
          (add-to-list 'result link)))))
  result)

(defun bl/org-export--clear-export (&optional directory)
  "Clear out the export directory. Recreate it empty afterwards."
  (interactive)
  (unless directory (setq directory org--export-directory))
  (if (file-exists-p directory)
      (if (y-or-n-p (format "Delete: '%s'?" directory))
          (delete-directory directory 't))))

(defun bl/create-parent-directories (path)
  "Create partent directories for path is they don't already exist."
  (unless (file-exists-p path)
    (let ((dir (file-name-directory path)))
      (unless (file-exists-p dir)
        (make-directory dir 't)))))

(defun bl/org-roam--backup-notes (&optional directory)
  "Backup all my notes to a gzipped tarball.

If &optional `directory' is set, back ups are saved there. The default location
is set by `org-roam--backup-directory'.

Backups are saved in `%Y%m%d%H%M%S.tar.gz' files."
  (interactive)
  (unless directory (setq directory org-roam--backup-directory))
  (let* ((timestamp (org-format-time-string "%Y%m%d%H%M%S"))
         (backup-dir (concat directory timestamp "/"))
         (files (directory-files-recursively org-roam-directory ".*"))
         (files (seq-remove (lambda (f) (string-match-p org--export-directory f)) files)))
    (dolist (file files)
      (let* ((relative (string-remove-prefix org-roam-directory file))
             (dest (concat backup-dir relative)))
        (bl/create-parent-directories dest)
        (copy-file file dest 't 't 't 't)))
    (let ((default-directory directory))
      (if (= (call-process "tar" 'nil 'nil 'nil "-czvf" (concat timestamp ".tar.gz") timestamp) 0)
          (delete-directory backup-dir 't)))))

;; Setup a backup
;; (run-at-time "02:30am" 'nil 'bl/org-roam--backup-notes)

(defun bl/prepare-file-system-for-notes ()
  "Setup directory structure for note taking.

Note: This assumes things like org-roam and org-export have been loaded and
their special variables defined. This is fine because we don't expect this
function to be run often, just when you are initializing a new computer.
  "
  (interactive)
  ;; We store the lit dir as a subdir of these other directories so we could
  ;; just to a mkdir with -p but might not always so we explicitly create each
  ;; directory.
  (unless (file-exists-p notes)
    (make-directory notes 't))
  (unless (file-exists-p zettelkasten)
    (make-directory zettelkasten 't))
  (unless (file-exists-p lit)
    (make-directory lit 't))
  (unless (file-exists-p (concat org--export-directory org-roam-dailies-directory))
    (make-directory (concat org--export-directory org-roam-dailies-directory)) 't)
  (unless (file-exists-p org--export-directory)
    (make-directory org--export-directory 't)
    (make-directory (concat org--export-directory "lit") 't)
    (make-directory (concat org--export-directory "images") 't))
    (make-directory (concat org--export-directory org-roam-dailies-directory) 't)
  (unless (file-exists-p org-roam--backup-directory)
    (make-directory org-roam--backup-directory 't)))

;; TODO: Avoid links showing up if they link to something private.

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  ;; :hook (org-roam . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme 't
        org-roam-ui-follow 't
        org-roam-ui-update-on-save 't
        org-roam-ui-open-on-start 't
        org-roam-ui-find-ref-title 't))

(defun get-json-config-value (key file)
  "Read `key' from json stored in `file'"
  (cdr (assoc key (json-read-file file))))

(use-package! json
  :after-call get-json-config-value)

(use-package! org-gcal
  :after org
  :config
  (defvar org-gcal-cred-file (concat (getenv "HOME") "/Documents/Secrets/gcal-secrets.json"))
  (defvar org-gcal-org-file (concat notes "g-cal.org"))
  (setq org-gcal-recurring-events-mode 'nested)
  (when (file-exists-p org-gcal-cred-file)
    (setq org-gcal-client-id (get-json-config-value 'org-gcal-client-id org-gcal-cred-file)
          org-gcal-client-secret (get-json-config-value 'org-gcal-client-secret org-gcal-cred-file)
          org-gcal-file-alist `((,(get-json-config-value 'calendar-id org-gcal-cred-file) . ,org-gcal-org-file)))))

(use-package! mixed-pitch
  ;; Hooking org-roam-bibtex-mode is the easiest way to get mixed pitch in the
  ;; roam backlink buffer lol.
  :hook ((org-mode evil-org-mode org-roam-bibtex-mode markdown-mode) . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height 't))

(after! doom-modeline
  (setq doom-modeline-hud 't
        doom-modeline-icon 't
        doom-modeline-major-mode-icon 't
        doom-modeline-major-mode-color-icon 't)
  ;; Org-pomodoro is the only thing I have that writes to the global-mode-string
  ;; so set it to always display, even when the width of emacs is smaller than
  ;; the fill-column (often happen emacs snapped to edge).
  (doom-modeline-def-segment misc-info
    (when (doom-modeline--active)
      '("" mode-line-misc-info))))

(after! org-pomodoro
  (setq org-pomodoro-keep-killed-pomodoro-time 't
        org-pomodoro-clock-break 't
        org-pomodoro-length 50
        org-pomodoro-short-break-length 10
        org-pomodoro-long-break-length 40
        org-pomodoro-long-break-frequency 4)
  (add-hook! 'org-clock-in-hook (setq global-mode-string (delete 'org-mode-line-string global-mode-string))))

(use-package! org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

(setq +ligatures-extras-in-modes '('not 'python-mode))

(setq magic-mode-alist 'nil)

(when WORK (load (concat doom-private-dir "work-config.el")))
