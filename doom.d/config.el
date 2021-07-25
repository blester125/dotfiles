;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(when WORK (load (concat doom-private-dir "work-config.el")))
(load (concat doom-private-dir "faces.el"))

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq x-super-keysym 'meta) ;; Set the left super key to the meta, avoid alt clashes with i3
(setq which-key-idle-delay 0.5) ;; Show me help quicker lol.

;; Some functionality uses this to identify you, e.g. PGP configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brian Lester"
      user-mail-address "blester125@gmail.com")

(defvar notes (concat (getenv "HOME") "/notes/") "Where I keep all of my org files.")
(defvar zettelkasten (concat notes "zettelkasten/") "Where I keep all of my notes.")
(defvar lit (concat zettelkasten "lit/") "Where notes on papers (or anything with a bib reference) live.")
(defvar bib (concat lit "references.bib") "Where I keep my large bibliography, in BibTex.")

(setq org-directory notes  ;; Where my general org notes are
      org-roam-directory zettelkasten ;; Where org-roam keeps all my files
      org-roam-db-location (concat (getenv "HOME") "/.org-roam.db"))

(setq-default fill-column 120)
;; Change the fill-column depending on if you are programming or just typing.
(setq-hook! 'text-mode-hook fill-column 120)
(setq-hook! 'prog-mode-hook fill-column 80)
(setq-hook! 'prog-mode-hook #'display-fill-column-indicator-mode)

;; The symbol used when you have an org header closed.
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

(defun bl/save-word ()
  "Add a word to your personal dictionary so it doesn't get marked as an error in the future.

  Taken from flyspell.el"
  (interactive)
  (let  ((current-location (point))
         (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location)))
  )

;; use zg in normal mode to save a word to my dictonary like I do in vim
(map! :n "z g" 'bl/save-word)

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

;; Configuring spell checking which I def need lol
(add-hook! 'text-mode-hook 'flyspell-mode)
(add-hook! 'prog-mode-hook 'flyspell-prog-mode)

;; This is turns on superword mode where things like `_' are treaded as part of a word but that is isn't working with evil mode atm
;; (add-hook! 'python-mode-hook 'superword-mode)

;; Update the value of `_' in the syntax table so evil mode commands like `w' will not stop on this symbol, lets you manipulate a whole variable
(add-hook! 'python-mode-hook (modify-syntax-entry ?_ "w"))

;; When I open a new window switch to it
(after! evil
  (setq evil-vsplit-window-right t  ;; Open vertical splits to the right of the current window.
        evil-split-window-below t)  ;; Open horizontal splits below the current window.
  ;; Use evil commentary so things like commenting a visual selection work.
  (evil-commentary-mode))

;; Ivy the selection library via fuzzy matching I use
(after! ivy
  (setq ivy-count-format "(%d/%d) ") ;; Have ivy show the index and count
  (setq ivy-use-virtual-buffers "recentf") ;; Have ivy include recently opened files in the switch buffer menu
  (setq ivy-wrap t) ;; When you select past the start or end of the completetion list wrap around
  ;; When using the ivy-minibuffer have shift-space just enter a space, it used to call a function that would wipe the buffer.
  (define-key ivy-minibuffer-map (kbd "S-SPC") (lambda () (interactive) (insert " "))))

;; Ignore the __pycache__ (as well as auto saves and backups) when searching for file
(after! counsel
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)\\|\\(?:__pycache__\\)")
  ;; Add our insert roam link from counsel-rg search.
  (ivy-add-actions 'counsel-rg '(("r" bl/ivy-insert-org-roam-link "Insert Org-Roam link."))))

;; Org mode is the reason I switched to emacs
(after! org
  (setq org-log-done 'time) ;; When I mark something as done save the time it was marked
  (map! :leader
        :prefix "n"
        "c" #'org-capture) ;; Capture notes into org mode with SPC n c
  (map! :leader
        :prefix ("m" . "org-mode")
        :desc "Open my global todo list" "T" #'org-todo-list)
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
  (setq org-priority-default ?F)
  ;; Set colors for priority levels
  (setq org-priority-faces '((?A . error)
                             (?B . warning)
                             (?C . rising)
                             (?D . chill)
                             (?E . success)))
  (setq org-priority-get-priority-function #'bl/org-inherited-priority)
  ;; Highlight the word NOWORK in org-agenda. It doesn't use font-lock so I had
  ;; to use a hook like this. Also I don't know why I couldn't use the DOOM
  ;; emacs add-hook! for this but it that case it wouldn't work.
  (add-hook 'org-agenda-finalize-hook
    (lambda ()
      (highlight-regexp "NOWORK" 'NOWORK-face))))

(use-package! ox
  :after org
  :config
  ;; Make sure each org file has the CSS file added to it.
  (defvar org--css-location "https://gongzhitaao.org/orgcss/org.css" "The location where the CSS stylesheet we use for org-mode html exports lives.")
  ;; Use hook to add a css header to the file before exporting it.
  (add-hook! 'org-export-before-parsing-hook #'bl/org--add-css-header)
  ;; The directory where exports will live so they aren't littered around our
  ;; zettelkasten.
  (defvar org--export-directory (concat org-roam-directory "export/") "Where exported org mode files will appear.")
  ;; Use hook to make sure any image links are copied over into the export.
  (add-hook! 'org-export-before-parsing-hook 'bl/org-export--export-images) ;; Don't bite compile because we check variables.
  ;; Add a function that makes sure the output file name of an export will be
  ;; the absolute path.
  (advice-add 'org-export-output-file-name :filter-return 'file-truename)
  ;; Add a function that runs after org html export that moves the from the
  ;; default export directory (the same one the file is in) into the export
  ;; directory.
  (advice-add 'org-html-export-to-html :filter-return 'bl/org-export--move-output)
  (setq org-export-with-toc 'nil)
  (setq org-html-htmlize-output-type 'css)
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
    (rename-file filename dest 't)
    dest))


;; Set the characters that different priorities are displayed as.
(after! org-fancy-priorities
  ;; :hook ((org-mode . org-fancy-priorities-mode)
  ;;        (evil-org-agenda-mode . org-fancy-priorities-mode))
  (setq org-fancy-priorities-list '((?A . "⚑")
                                    (?B . "🔥") ;; They don't support emojis so this looks different in the actual list.
                                    (?C . "⬆")
                                    (?D . "❄")
                                    (?E . "■"))))

;; Highlight the word NOWORK in org-mode.
(font-lock-add-keywords 'org-mode
                        '(("NOWORK" . 'NOWORK-face)))

(defun bl/org-roam--counsel-rg (&optional INITIAL-INPUT)
  "Full text search with counsel-rg (using ripgrep) specific to searching my notes."
  (interactive)
  ;; Only search org files in the zettelkasten. We also set the prompt to be more informative.
  ;; Note: It uses smart casing search. This means when your search uses lowercase
  ;; it is case-insensitive, but adding an upper case makes it case-sensative
  (counsel-rg INITIAL-INPUT org-roam-directory "--glob **/*.org" "org-roam search: "))

(defun bl/ivy-insert-org-roam-link (candidate)
  "Insert an org-roam link based on the selected file from search. Assumes the candidates are in the format `file-name:...'

  Note: This function doesn't support adding new files on the fly.
  "
  (interactive)
  ;; Make things like insert go into the caller buffer instead of the minibuffer.
  (with-ivy-window
    (let* ((filename (car (split-string candidate ":")))
           ;; Load the note you found into a temp buffer so that org-roam can extract the title.
           (slug (with-temp-buffer
                   (insert-file-contents filename)
                   (car (org-roam--extract-titles-title)))))
      (insert (format "[[file:%s][%s]]" filename slug)))))

;; A Zettelkasten in org mode, the reason I switched
(after! org-roam
  (map! :leader
        :prefix ("r" . "roam")
        :desc "Open org-roam backlink panel" "l" #'org-roam
        :desc "Insert a new org-roam link" "i" #'org-roam-insert
        :desc "Insert a new org-roam link, create with template if missing" "I" #'org-roam-insert-immediate
        :desc "Switch org-roam buffers" "b" #'org-roam-switch-to-buffer
        :desc "Find an org-roam file, create if not found" "f" #'org-roam-find-file
        :desc "Show the org-roam graph" "g" #'org-roam-graph-show
        :desc "Use a capture to add a new org-roam note" "c" #'org-roam-capture
        :desc "Open the current journal" "j" #'bl/org-journal-find-location
        :desc "Search notes" "s" #'bl/org-roam--counsel-rg)
  ;; The default text that is populated in a new org-roam note.
  (setq org-roam-capture-templates
        (quote (("d" "default" plain (function org-roam--capture-get-point)
                 "%?"
                 :file-name "%<%Y%m%d%H%M%S>-${slug}"
                 :head "#+title: ${title}\n#+startup: latexpreview\n\n"
                 :unnarrowed t))))
  (defvar org-roam--backup-directory (concat notes "backups/") "A location where note backups are saved.")
  (defvar org-roam--private-tag "private" "A roam tag that marks a note as private, not for export.")
  (defvar org-roam--todo-markers '("todo") "A roam tag that marks a file as needing to be parsed for TODOs. The first item in this list will automatically be added to any file that has a TODO.")
  (defvar org-roam--agenda-markers '("agenda") "A roam tag that marks a file as containing agenda items, regardless of it has TODOs.")
  ;; Any file that contains one of the tags above will automatically be searched
  ;; when calling `org-todo-list' or `org-agenda'.
  (defvar org-roam-find-file--ignore-tags (append org-roam--todo-markers org-roam--agenda-markers '("private")) "A list of tags that should not be displated with searching.")
  ;; Look for TODOs and update the roam_tags when you open a roam file.
  (add-hook! 'org-roam-file-setup-hook #'bl/roam-tags-update-todo)
  ;; Look for TODOs and update the roam tags when you save a file. Would like to
  ;; find a more specialized hook.
  (add-hook! 'before-save-hook #'bl/roam-tags-update-todo)
  ;; Query the Org-Roam db for files with TODO/agenda tasks before loading the
  ;; org-agenda or todo list.
  (advice-add 'org-agenda :before #'bl/update-agenda-files)
  (advice-add 'org-todo-list :before #'bl/update-agenda-files)
  ;; Use my custom function which removes some tags (like TODO) instead of the
  ;; default when turning a note into a string.
  (advice-add 'org-roam--add-tag-string :override #'bl/org-roam--add-tag-string))

;; TODO(brianlester): Right now this will open the multiple windows where you
;; can see a preview of the journal file being changed. I would like to remove
;; that in the future
(defun bl/org-journal-find-location (&optional search)
  (interactive)
  (let ((search (or search "^\*[^*]*$")))
    ;; Open today's journal, but specify a non-nil prefix argument in order to
    ;; inhibit inserting the heading; org-capture will insert the heading.
    (org-journal-new-entry t)
    ;; Position point on the journal's last top-level heading so that
    ;; org-capture will add the new entry as a child entry. First we go to the
    ;; end of the file with point-max
    (goto-char (point-max))
    ;; then we search backwards for the first line that has a match of starting
    ;; with a single *, the second character block say one of more anything but
    ;; a * this will eliminate find a sub heading. This is based on the
    ;; assumption that each day has a heading and all the notes you will capture
    ;; on that day should be sub headings of that day.
    (search-backward-regexp search)
    ;; The version of this function I found on the internet used `point-min' to
    ;; jump to the beginning of the file which assumed that the first heading
    ;; lived there. That is fine for some daily notes but when you use
    ;; org-capture for weekly/monthly it breaks. It also breaks if you have a
    ;; header in the file.
  ))

(defun work/org-journal-find-location ()
  "Find my monthly work journal."
  (let ((org-journal-dir (bl/getenv "WORK_NOTEBOOK" "~/dev/work/notebooks/blester"))
        (org-journal-file-format "%Y-%m.org")
        (org-journal-file-type 'monthly))
        (bl/org-journal-find-location))
  )

;; TODO: When there is a header in the file the new entries don't next properly.
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
        org-journal-file-type 'daily
        org-journal-file-header 'bl/org-journal-file-header-func
        org-journal-find-file 'find-file
        org-journal-carryover-items "")
  (add-to-list 'org-capture-templates '("w" "Work entry" entry (function work/org-journal-find-location)
                                      "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?"))
  (add-to-list 'org-capture-templates '("j" "Journal entry" entry (function bl/org-journal-find-location)
                                      "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?"))
  (map! :leader
        :prefix ("j" . "journal")
        :desc "Previous Journal Entry" "h" #'org-journal-previous-entry
        :desc "Next Journal Entry" "l" #'org-journal-next-entry
        :desc "Plain Text Search in the Journal" "s" #'org-journal-search)
)

(set-file-template! "\\.org$" :ignore t)

(defvar lit-note-template (concat "#+title: ${title}\n"
                                  "#+roam_key: cite:${citekey}\n"
                                  "#+startup: latexpreview\n\n"
                                  "#+caption: Bibliographic Information\n"
                                  "| Field | Value |\n"
                                  "|-------+-------|\n"
                                  "| custom_id | ${citekey} |\n"
                                  "| author | ${author-abbrev} |\n"
                                  "| journal | ${journal} |\n"
                                  "| booktitle | ${booktitle} |\n"
                                  "| date | ${date} |\n"
                                  "| year | ${year} |\n"
                                  "| doi | ${doi} |\n"
                                  "| url | ${url} |\n\n"
                                  "* Notes\n") "The template for creating a new Litature Note.")


;; Find and take notes on bibliographic entries, Seems to be an eager load right now
(use-package! ivy-bibtex
  :after org-ref
  :config
  ;; Create a ivy version of my cite key creation function
  (ivy-bibtex-ivify-action org-ref-insert-key-at-point ivy-bibtex-insert-cite-key)
  (setq
   bibtex-completion-notes-path lit
   bibtex-completion-bibliography bib
   bibtex-completion-pdf-field "file"
   bibtex-completion-pdf-symbol "⌘"
   bibtex-completion-notes-symbol "✎"
   ;; When you select a biblographic entry insert a cite link. Use C-o to get a
   ;; menu of actions, then e will open the note file.
   ivy-bibtex-default-action 'ivy-bibtex-insert-cite-key
   bibtex-completion-notes-template-multiple-files lit-note-template
  )
  (map! :leader
        :prefix ("r" . "roam")
        :desc "Get notes on a biblographic entry" "r" #'ivy-bibtex)
  ;; Add an ivy action that inserts my version of cite lengths.
  ;; Access extra actions with C-o and then pick an option.
  (ivy-add-actions
   'ivy-bibtex
   '(("c" ivy-bibtex-insert-cite-key "Insert a cite link")))
)

(use-package! org-ref
   :init
   (setq org-ref-completion-library 'org-ref-ivy-cite)
   :config
   (setq
     org-ref-default-bibliography (list bib)
     org-ref-notes-directory lit
     org-ref-notes-function 'orb-edit-notes
     bibtex-completion-bibliography bib
     bibtex-completion-notes-path lit
     org-ref-bibliography-entry-format
        '(("article" . "%a, <a href=\"%U\">%t</a>, <i>%j</i>, <b>%v(%n)</b>, %p (%y). <a href=\"http://dx.doi.org/%D\">doi</a>.")
          ("book" . "%a, <a href=\"%U\">%t</a>, %u (%y).")
          ("techreport" . "%a, <a href=\"%U\">%t</a>, %i, %u (%y).")
          ("proceedings" . "%e, <a href=\"%U\">%t</a> in %S, %u (%y).")
          ("inproceedings" . "%a, <a href=\"%U\">%t</a>, %p, in %b, edited by %e, %u (%y)"))
   )
   (defvar org-ref--bibliography-style "authordate1" "The org ref bibliography format, only works in LaTeX?")
   ;; Add a bibliography link to files that have cite links.
   (add-hook! 'org-export-before-parsing-hook #'bl/org-ref--add-bibilography-link)
   ;; Make sure we don't byte complie this function (`#'), we need to read the
   ;; value of `default-directory' which might change.
   (add-hook! 'org-export-before-parsing-hook 'bl/org-export--add-ref-note-links)
   )

(use-package! yankpad
  :config
  (setq yankpad-file (concat doom-private-dir "yankpad.org"))
  (map! :leader
        :desc "Snippits with Yankpad"
        "y" #'yankpad-insert))

;; Virtually wrap lines at 80 characters.
(use-package! visual-fill-column
  :hook
  (visual-line-mode . visual-fill-column-mode))

(custom-set-faces!
  '((org-block markdown-code-face) :background nil))

(use-package! org-roam-bibtex
  :after org-roam
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :config
  (setq org-roam-completion-everywhere 'nil)
  (setq orb-insert-interface 'ivy-bibtex)
  (setq orb-note-actions-interface 'ivy)
  (setq orb-preformat-keywords
        '("citekey" "title" "url" "file" "author-or-editor" "keywords" "ref" "author-abbrev" "journal" "booktitle" "date" "year" "doi"))
  (setq orb-templates
        `(("r" "ref" plain (function org-roam-capture--get-point)
           ""
           :file-name "lit/${citekey}"
           ;; :head "#+title: ${title}\n#+roam_key: cite:${citekey}\n#+startup: latexpreview\n\n:properties:\n:properties:\n:custom_id: ${citekey}\n:author: ${author-abbrev}\n:journal: ${journal}\n:booktitle: ${booktitle}\n:date: ${date}\n:year: ${year}\n:doi: ${doi}\n:url: ${url}\n:end:\n\n* Notes\n"
           :head ,lit-note-template
           :unnarrowed t
           ))))

;; Speed up agenda over my roam files by only searching ones that are marked
;; with a #+roam_tags: todo
(defun bl/todo-file-p ()
  "Return non-nil if the current buffer has any TODO entry."
  (org-element-map
      (org-element-parse-buffer 'headline)
      'headline
    (lambda (h)
      (eq (org-element-property :todo-type h)
          'todo))
    nil 'first-match))

(defun bl/roam-tags-update-todo (&optional marker)
  "Update the TODO roam tag in a buffer. Adds a roam tag with the value of `marker'."
  (unless marker (setq marker (car org-roam--todo-markers)))
  (when (and (not (active-minibuffer-window))
             (org-roam--org-file-p buffer-file-name))
    (let* ((file (buffer-file-name (buffer-base-buffer)))
           ;; (all-tags (org-roam--extract-tags file))
           (prop-tags (org-roam--extract-tags-prop file))
           (tags prop-tags))
      (if (bl/todo-file-p)
          (setq tags (seq-uniq (cons marker tags)))
        (setq tags (remove marker tags)))
      (unless (equal prop-tags tags)
        (org-roam--set-global-prop
         "roam_tags"
         (combine-and-quote-strings tags))))))

(defun bl/like-query (str)
  "Format a string into a like db query that checks if str is a substring."
  (concat "%\"" str "\"%"))

(defun bl/find-tagged-files (tag)
  "Find all roam-db files tagged with `tag'"
  (seq-map
   #'car ;; The db returns tuples for rows so grab the first item from each tuple.
   (org-roam-db-query
    [:select file
     :from tags
     :where (like tags $r1)] (bl/like-query tag))))

(defun bl/find-roam-todo-agenda-files (&optional markers)
  "Return a list of org-roam files containing TODO entries."
  (unless markers (setq markers (append org-roam--todo-markers org-roam--agenda-markers)))
  (delete-dups (flatten-tree (seq-map #'bl/find-tagged-files markers))))

(defun bl/update-agenda-files (&rest _)
  "Update the value of `org-agenda-files'."
  (interactive)
  (setq org-agenda-files (bl/find-roam-todo-agenda-files)))

(defun bl/org-roam--add-tag-string (str tags)
  "Add TAGS to STR.

Depending on the value of `org-roam-file-completion-tag-position', this function
prepends TAGS to STR, appends TAGS to STR or omits TAGS from STR.

Any tags in the list values of `org-roam-find-file--ignore-tags' will not be
added to the string."
  (interactive)
  (let* ((tags (seq-remove (lambda (elt) (member elt org-roam-find-file--ignore-tags)) tags)))
    (pcase org-roam-file-completion-tag-position
      ('prepend (concat
                 (when tags (propertize (format "(%s) " (s-join org-roam-tag-separator tags))
                                        'face 'org-roam-tag))
                 str))
      ('append (concat
                str
                (when tags (propertize (format " (%s)" (s-join org-roam-tag-separator tags))
                                       'face 'org-roam-tag))))
      ('omit str))))

;; It isn't a perfect match but use python highlighting when editing gin config files.
(add-to-list 'auto-mode-alist '("\\.gin$" . python-mode))

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

;; Keybinding for monthly and yearly agenda views.
(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :m "y" 'org-agenda-year-view
      :m "m" 'org-agenda-month-view)

;; For fancy js-reveal presentations
(use-package! ox-reveal
  :after ox)

(defun bl/org--add-css-header (backend)
  "Add a CSS header to each org file as you export it"
  (ignore backend)
  (goto-char (point-min))
  (insert (format "#+html_head: <link rel=\"stylesheet\" type=\"text/css\" href=\"%s\"/>\n" org--css-location)))

(defun bl/org--link-info (link)
  "Parse a link into a property list."
  (let ((link-path (org-element-property :path link))
        (link-type (org-element-property :type link))
        ;; Get the end of the actual link, without the following blanks.
        (link-end (- (org-element-property :end link)
                     (org-element-property :post-blank link))))
    (list :type link-type :path link-path :end link-end)))

(defun bl/org--get-links-from-buffer ()
  "Get all links in an org buffer."
  (interactive)
  (org-element-map (org-element-parse-buffer) 'link 'bl/org--link-info))

(defun bl/org-ref--split-link (link)
  "Split an org-ref link with multiple parts (paperA,paperB,...) into multiple links."
  (let* ((refs (org-ref-split-and-strip-string (plist-get link :path))))
     (seq-map (lambda (r) (plist-put (copy-tree link) :path r)) refs)
  ))

(defun bl/org-ref--get-cite-links-from-buffer ()
  "Filter down to only the cite links, splitting multiple citation links.

Note: This requires parsing the current buffer, it is slower than querying the
org roam cache, but it works for non-org-roam files and it gives the locations
of the link in the buffer."
  (interactive)
  (let* ((cite-links (seq-remove (lambda (e) (not (equal (plist-get e :type) "cite"))) (bl/org--get-links-from-buffer))))
    (apply #'append (seq-map #'bl/org-ref--split-link cite-links))))

(defun bl/org-ref--add-bibilography-link (backend)
  "If cite links appear in an org file, add a bibliography link so it shows up in export.

We need to parse the buffer for this because we don't have access to the filename."
  (ignore backend)
  (when (bl/org-ref--get-cite-links-from-buffer)
      (goto-char (point-max))
      (insert (concat "bibliography:" (car org-ref-default-bibliography) "\n"))
      (insert (concat "bibliographystyle:" org-ref--bibliography-style "\n"))))

(defun org-html-export-to-html-filename (filename &optional async subtreep visible-only body-only ext-plist)
  "Export an org mode file to html via filename."
  (interactive)
  (with-temp-buffer
    (let* ((fullname (file-truename filename))
           (export-name (concat (file-name-sans-extension filename) ".html")))
      (message "Exporting: %s to %s" fullname export-name)
      (insert-file-contents fullname)
      (goto-char (point-min))
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
           (message "%s filed to export" fullname)
           (message "%s" (error-message-string err))))))))

(defun -org-html-export-to-html-filename-recursive (filename &optional async subtreep visible-only body-only ext-plist exported)
  "Export an org file and all files it links too. Exported set is used to avoid circular exports."
  (interactive)
  (message "Exported already: %s" exported)
  (let ((fullname (file-truename filename))
        (exported-file 'nil))
    (unless (member fullname exported)
      (push fullname exported)
      (message "Recursively exporting: %s" fullname async subtreep visible-only body-only ext-plist)
      ;; We read the file in again to find the links because it is was easy, this
      ;; should be updated to use the org roam db. We should also filter based on
      ;; some org tags.
      (let* ((links (bl/org-roam--get-outbound-links-with-notes-over-cites fullname))
             (file-links (seq-remove (lambda (l) (not (equal (plist-get l :type) "file"))) links))
             (org-links (seq-remove (lambda (l) (not (equal (file-name-extension (plist-get l :path)) "org"))) file-links)))
        (message "Org Links to follow: %s" org-links)
        (message "All file links: %s" file-links)
        (message "All links: %s" links)
        (dolist (org-link org-links)
          (setq exported (nth 1 (-org-html-export-to-html-filename-recursive (plist-get org-link :path) async subtreep visible-only body-only ext-plist exported))))
        (setq exported-file (org-html-export-to-html-filename filename async subtreep visible-only body-only ext-plist))))
    (list exported-file exported)))

(defun bl/org-export--all-notes (&optional include-private)
  "Export all notes to html.

If &optional `include-private' is non-nil, include notes marked with a 'private'
tag. The value for the private tag is defined by `org-roam--private-tag'."
  (interactive)
  (let ((exported '())
        (notes (bl/org-roam--list-notes include-private)))
    (dolist (note notes)
      ;; Don't re-export things.
      (unless (member note exported)
        ;; Update our set of exported files with all the files exported from this
        ;; recursive export expansion.
        (let* ((results (-org-html-export-to-html-filename-recursive note))
               (exported-files (nth 1 results)))
          (setq exported (append exported exported-files)))))))

(defun org-html-export-to-html-filename-recursive (filename &optional async subtreep visible-only body-only ext-plist)
  "Wrapper around recursive export for cleaner interface."
  (nth 0 (-org-html-export-to-html-filename-recursive filename async subtreep visible-only body-only ext-plist)))

(defun org-html-export-to-html-recursive (&optional async subtreep visible-only body-only ext-plist)
  "A wrapper around by function that converts from a buffer export to a filename based one."
  (let ((filename (buffer-file-name)))
    (org-html-export-to-html-filename-recursive filename async subtreep visible-only body-only ext-plist)))

(defun bl/org-roam--get-notes-from-ref (ref)
  "Find the note file associated with `ref' return nil if notes do not exist."
  (car (car (org-roam-db-query [:select file :from refs :where (= ref $s1)] ref))))

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

(defun bl/org-export--add-ref-note-links (backend)
  "Add links to notes from any cite link that has a note.

We need to use the buffer based parsing so that we have access to the cite-link
locations."
  (interactive)
  (ignore backend)
  (let* ((cite-links (bl/org-ref--get-cite-links-from-buffer))
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

(defun bl/image-link-p (path)
  "Check if a path most likely links to an image.

Checks is the link is in a /images/ subdir or ends with a commong image file extension."
  (if (or (not (null (string-match-p (regexp-quote "/images/") path)))
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
    (seq-mapn (lambda (src dst) (copy-file src dst 't)) image-locs image-export-locs)))

(defun bl/org-roam--get-outbound-cite-links (filename)
  "Find all cite-links in a file by querying the org-roam db."
  (org-roam-db-update-file filename)
  (when-let* ((links (org-roam-db-query
                      [:select :distinct dest
                       :from links
                       :where (and (= type "cite") (= source $s1))] filename))
              (links (seq-map (lambda (p) (list :path (car p) :type "cite")) links)))
    (apply #'append (seq-map 'bl/org-ref--split-link links))
    ))

(defun bl/org-roam--list-notes (&optional include-private)
  "Get the names of all the notes in the zettelkasten

If &optional `include-private' is non-nil, then fetch all notes, even ones with
'private' tags. The value for the private tag is set with `org-roam--private-tag'

Returns a list of note file names."
  (org-roam-db-update)
  (let ((notes (if include-private
                   (org-roam-db-query [:select :distinct file :from files])
                   (org-roam-db-query [:select :distinct files:file
                                       :from files
                                       :left :outer :join tags :on (= files:file tags:file)
                                       :where (or (is tags:tags 'nil)
                                                  (not-like tags:tags $r1))] (bl/like-query org-roam--private-tag)))))
    (seq-map 'car notes)))

(defun bl/org-roam--get-outbound-links (filename &optional include-private)
  "Find all cite-links in a file by querying the org-roam db.

If &optional `include-private' is non-nil, then fetch all notes, even ones with
'private' tags. The value for the private tag is set with `org-roam--private-tag'

Returns a list of link plists with attributes `:path' and `:type'
"
  (org-roam-db-update-file filename) ;; Make sure DB information is up to date.
  (when-let* ((links (if include-private
                         (org-roam-db-query [:select :distinct [dest type]
                                             :from links
                                             :where (= source $s1)] filename)
                       (org-roam-db-query [:select :distinct [links:dest links:type]
                                           :from links
                                           ;; Join the with the tags table so get access to all the
                                           ;; tags applied to the destination file of the link,
                                           :left :outer :join tags :on (= links:dest tags:file)
                                           :where (and
                                                   ;; Only get outbound links from us.
                                                   (= source $s1)
                                                   ;; Only get links where the target has no tags or where it
                                                   ;; doesn't have the private tag.
                                                   (or (is tags:tags 'nil)
                                                       (not-like tags:tags $r2)))] filename (bl/like-query org-roam--private-tag))))
              ;; Turn our link results into plists.
              (links (seq-map (lambda (l) (list :path (car l) :type (nth 1 l))) links)))
    ;; A cite link should never be private.
    ;; We split links in the form cite:paper1,paper2... into multiple links. We also wrap
    ;; non-cite-links in a list so they don't get pulled part in the apply #'append call.
    (apply #'append (seq-map (lambda (l) (if (equal (plist-get l :type) "cite") (bl/org-ref--split-link l) (list l))) links))
    ))

(defun bl/org-roam--file-private-p (filename)
  "Return t if the filename is a private file, 'nil otherwise."
  (org-roam-db-update-file filename) ;; Make sure DB information is up to date.
  (let ((private (org-roam-db-query [:select file
                                     :from tags
                                     :where (and (= file $s1)
                                                 (like tags $r2))] filename (bl/like-query org-roam--private-tag))))
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
            (when-let ((note-loc (bl/org-roam--get-notes-from-ref path)))
              (if (or include-private (not (bl/org-roam--file-private-p note-loc)))
                (add-to-list 'result (list :path note-loc :type "file"))))
            ;; Add all other links.
          (add-to-list 'result link)))))
  result)

(defun bl/create-parent-directories (path)
  "Create partent directories for path is they don't already exist."
  (unless (file-exists-p path)
    (let ((dir (file-name-directory path)))
      (unless (file-exists-p dir)
        (make-directory dir 't)))))

(defun bl/org-export--clear-export (&optional directory)
  "Clear out the export directory. Recreate it empty afterwards."
  (interactive)
  (unless directory (setq directory org--export-directory))
  (if (file-exists-p directory)
      (if (y-or-n-p (format "Delete: '%s'?" directory))
          (delete-directory directory 't))))

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
(run-at-time "02:30am" 'nil 'bl/org-roam--backup-notes)

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
  (unless (file-exists-p org--export-directory)
    (make-directory org--export-directory 't)
    (make-directory (concat org--export-directory "lit") 't)
    (make-directory (concat org--export-directory "images") 't))
  (unless (file-exists-p org-roam--backup-directory)
    (make-directory org-roam--backup-directory 't)))
