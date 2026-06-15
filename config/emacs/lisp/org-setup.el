;; -*- lexical-binding: t; -*-

(require 'org)

;; Global Document Resolution Setting
(setopt doc-view-resolution 400)

;; Custom hooks
(add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)

;; Key Bindings (Global)
(keymap-global-set "C-c y" #'org-store-link)
(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c c" #'org-capture)

;; Custom Variables Configuration
(setq org-directory (expand-file-name "~/Workspace/debling/orgfiles/")
      org-default-notes-file (concat org-directory "notes.org")
      org-agenda-files (mapcar (lambda (s) (concat org-directory s)) '("calendar.org" "todo.org"))
      org-export-with-smart-quotes t
org-capture-templates 
      `(("p" "TODO - Personal" entry (file+headline ,(concat org-directory "todo.org") "Personal")
         "* TODO [#B] %?\n%U" :empty-lines 1)
        ("w" "TODO - Work" entry (file+headline ,(concat org-directory "todo.org") "Work")
         "* TODO [#B] %?\n%U" :empty-lines 1)
        ("u" "TODO - Uni" entry (file+headline ,(concat org-directory "todo.org") "University")
         "* TODO [#B] %?\n%U" :empty-lines 1)
        ("r" "RABapp related")
        ("rr" "Code Review" entry (file ,(concat org-directory "todo.org"))
         "* TODO Review of RAB-%? :@rabapp:codereview:\n%U"
         :clock-in t
         :empty-lines 2)))

(setq org-confirm-babel-evaluate nil)
(setq org-tag-alist '(("@personal" . ?p) ("@zeit" . ?z) ("@rabapp" . ?r)))

;; Edit settings
(setq org-catch-invisible-edits 'show-and-error
      org-special-ctrl-a/e t
      org-insert-heading-respect-content t)

;; Org styling, hide markup etc.
(setq org-hide-emphasis-markers t)
(setq org-pretty-entities t)
(setq org-agenda-tags-column 0)
(setq org-ellipsis "…")

;; Initialization runtime execution commands
(require 'ol-man) ; org-link support for manpages
(org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp . t)
                                                         (java . t)
                                                         (shell . t)
                                                         (python . t)
                                                         (plantuml . t)))

(require 'org-cliplink)
(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map (kbd "SPC l p") 'org-cliplink))


(require 'org-roam)
;; Key Bindings (Global Room Shortcuts)
(keymap-global-set "C-c n l" #'org-roam-buffer-toggle)
(keymap-global-set "C-c n f" #'org-roam-node-find)
(keymap-global-set "C-c n g" #'org-roam-graph)
(keymap-global-set "C-c n i" #'org-roam-node-insert)
(keymap-global-set "C-c n c" #'org-roam-capture)
(keymap-global-set "C-c n j" #'org-roam-dailies-capture-today)

;; Configuration Layout variables
(setq org-roam-directory (expand-file-name (concat org-directory "/roam")))
(setq org-roam-completion-everywhere t)
(setq org-roam-dailies-capture-templates 
      '(("d" "default" entry "* %?\n%U\n"
         :target (file+head "%<%Y-%m-%d>.org" "#+filetags: needs_review daily_notes\n#+title: %<%Y-%m-%d>\n\n"))))

(setq org-roam-node-display-template (concat "${title} " (propertize "${tags:80}" 'face 'org-tag)))

;; Automatically engage synchronization service
(org-roam-db-autosync-mode)

(require 'org-alert)

(provide 'org-setup)
