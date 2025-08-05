;; -*- lexical-binding: t; -*-

;;; initial setup
;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t ;; Always ensures that a package is installed
      use-package-enable-imenu-support t
      native-comp-async-report-warnings-errors nil
      package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

;;; Evil mode
(use-package evil
  :init ;; Execute code Before a package is loaded
  (evil-mode)
  :config ;; Execute code After a package is loaded
  (evil-set-initial-state 'eat-mode 'insert) ;; Set initial state in eat terminal to insert mode
  :custom ;; Customization of package custom variables
  (evil-want-keybinding nil)    ;; Disable evil bindings in other modes (It's not consistent and not good)
  (evil-want-C-u-scroll t)      ;; Set C-u to scroll up
  (evil-want-C-i-jump nil)      ;; Disables C-i jump
  (evil-undo-system 'undo-redo) ;; C-r to redo
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
  ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil)))
(use-package evil-collection
  :diminish evil-collection-unimpaired-mode
  :after evil
  :config
  ;; Setting where to use evil-collection
  (setq evil-collection-mode-list '(dired ibuffer magit corfu vertico consult cider))
  (evil-collection-init))

(use-package general
  :config
  (general-evil-setup)
  ;; Set up 'SPC' as the leader key
  (general-create-definer start/leader-keys
    :states '(normal insert visual motion emacs)
    :keymaps 'override
    :prefix "SPC"           ;; Set leader key
    :global-prefix "C-SPC") ;; Set global leader key

  (start/leader-keys
    "." '(find-file :wk "Find file")
    "TAB" '(comment-line :wk "Comment lines")
    "m" '(mu4e :wk "Projectile command map"))

  (start/leader-keys
    "p" '(:ignore t :wk "Project.el")
    "p p" '(project-switch-project :wk "Switch project")
    "p e" '(project-eshell :wk "Project Eshell")
    "p f" '(project-find-file :wk "Project find-file"))

  (defun debling/compile-project-or-file ()
    (declare (interactive-only compile)
             (interactive-only project-compile))
    (interactive)
    (if (project-current)
        (call-interactively #'project-compile)
      (call-interactively #'compile)))

  (defun debling/recompile-project-or-file ()
    (declare (interactive-only compile)
             (interactive-only project-compile))
    (interactive)
    (if (project-current)
        (call-interactively #'project-recompile)
      (call-interactively #'recompile)))

  (start/leader-keys
    "c" '(:ignore t :wk "Compile")
    "c c" '(debling/compile-project-or-file :wk "Compile current project or file")
    "c r" '(debling/recompile-project-or-file :wk "REcompile current project or ile"))

  (start/leader-keys
    "f" '(:ignore t :wk "Find")
    "f c" '((lambda () (interactive) (find-file "~/Workspace/debling/nix-dotfiles/config/emacs/init.el")) :wk "Edit emacs config")
    "f r" '(consult-recent-file :wk "Recent files")
    "f f" '(consult-fd :wk "Fd search for files")
    "f g" '(consult-ripgrep :wk "Ripgrep search in files")
    "f l" '(consult-line :wk "Find line")
    "f i" '(consult-imenu :wk "Imenu buffer locations"))

  (start/leader-keys
    "b" '(:ignore t :wk "Buffer Bookmarks")
    "b b" '(consult-buffer :wk "Switch buffer")
    "b k" '(kill-current-buffer :wk "Kill this buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b j" '(consult-bookmark :wk "Bookmark jump"))

  (start/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))

  (start/leader-keys
    "e" '(:ignore t :wk "Eglot Evaluate")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e f" '(eglot-format :wk "Eglot Format")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  (start/leader-keys
    "g" '(:ignore t :wk "Git")
    "g g" '(magit-status :wk "Magit status"))

  (start/leader-keys
    "h" '(:ignore t :wk "Help") ;; To get more help use C-h commands (describe variable, function, etc.)
    "h q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
    "h r" '((lambda () (interactive)
              (load-file "~/.config/emacs/init.el"))
            :wk "Reload Emacs config"))

  (start/leader-keys
    "s" '(:ignore t :wk "Show")
    "s e" '(eat :wk "Eat terminal"))

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")))

(use-package emacs
  :bind
  ("C-+" . text-scale-increase)
  ("C--" . text-scale-decrease)
  ("<C-wheel-up>" . text-scale-increase)
  ("<C-wheel-down>" . text-scale-decrease)
  :diminish eldoc-mode hs-minor-mode
  :custom
  (frame-resize-pixelwise t)
  (create-lockfiles nil)

  (use-short-answers t)
  (menu-bar-mode nil)         ;; Disable the menu bar
  (scroll-bar-mode nil)       ;; Disable the scroll bar
  (tool-bar-mode nil)         ;; Disable the tool bar
  (inhibit-startup-screen t)  ;; Disable welcome screen

  (delete-selection-mode t)   ;; Select text and delete it by typing.
  (electric-indent-mode nil)  ;; Turn off the weird indenting that Emacs does by default.
  ;; (electric-pair-mode nil)      ;; Turns on automatic parens pairing

  (blink-cursor-mode nil)     ;; Don't blink cursor
  (global-auto-revert-mode t) ;; Automatically reload file and show changes if the file has changed

  ;;(dired-kill-when-opening-new-dired-buffer t) ;; Dired don't create new buffer
  ;;(recentf-mode t) ;; Enable recent file mode

  ;;(global-visual-line-mode t)           ;; Enable truncated lines
  (display-line-numbers-type 'relative) ;; Relative line numbers

  (mouse-wheel-progressive-speed nil) ;; Disable progressive speed when scrolling
  (scroll-conservatively 10) ;; Smooth scrolling
  (scroll-margin 5)

  (tab-width 4)
  (indent-tabs-mode nil)

  (make-backup-files nil) ;; Stop creating ~ backup files
  (auto-save-default nil) ;; Stop creating # auto save files
  :hook
  (prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
  (prog-mode . display-line-numbers-mode)
  (text-mode . flymake-mode)
  (prog-mode . flymake-mode)
  (prog-mode . editorconfig-mode)
  (text-mode . editorconfig-mode)
  (before-save . delete-trailing-whitespace)
  :config
  ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  :bind (
         ([escape] . keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
         )
  ;; Fix general.el leader key not working instantly in messages buffer with evil mode
  :ghook ('after-init-hook
          (lambda (&rest _)
            (when-let ((messages-buffer (get-buffer "*Messages*")))
              (with-current-buffer messages-buffer
                (evil-normalize-keymaps))))
          nil nil t)
  )

(use-package server
  :ensure nil
  :defer 1
  :custom (server-client-instructions nil)
  :config (unless (server-running-p)
            (server-start)))

(use-package modus-themes
  :demand t
  ;:hook (text-mode . variable-pitch-mode)
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  ;; From the section "Make the mode line borderless", and the fringe transparent
  (modus-themes-common-palette-overrides '((border-mode-line-active   unspecified)
                                           (border-mode-line-inactive unspecified)
                                           (bg-line-number-inactive   unspecified)
                                           (bg-line-number-active     unspecified)))
  (modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi-tinted))
  :config
  (modus-themes-load-theme 'modus-operandi-tinted)

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle)

  (add-to-list 'default-frame-alist '(undecorated . t))

  (if (eq system-type 'darwin)
      (set-face-attribute 'default      nil :height 160 :family "Iosevka Nerd Font")
    (set-face-attribute 'default        nil :height 120 :family "Iosevka Nerd Font" :weight 'medium))
  (set-face-attribute 'variable-pitch nil :family "Sans Serif")
  (set-face-attribute 'fixed-pitch    nil :family (face-attribute 'default :family)))

(use-package spacious-padding
  :custom
  (spacious-padding-widths '(:internal-border-width 12
                             :header-line-width 4
                             :mode-line-width 2
                             :tab-width 4
                             :right-divider-width 30
                             :scroll-bar-width 8
                             :fringe-width 8))
  :config
  (spacious-padding-mode 1))


(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package project
  :custom
  (xref-search-program 'ripgrep)
  (project--list
        (let ((work-dir (expand-file-name "~/Workspace/")))
          (mapcar (lambda (path) (list (abbreviate-file-name path)))
                  (process-lines "fd" "\.git$"
                                 "--prune"
                                 "--absolute-path"
                                 "--unrestricted"
                                 "--type=d"
                                 "--max-depth=3"
                                 (concat "--base-directory=" work-dir)
                                 "--format={//}/")))))

(use-package compile
  :custom
  (compilation-scroll-output t)
  (compilation-always-kill t)
  (compilation-auto-jump-to-first-error nil)
  :config
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
  (add-hook 'compilation-filter-hook 'ansi-osc-compilation-filter))

;; (use-package flymake-languagetool
;;   :ensure t
;;   :hook ((text-mode       . flymake-languagetool-load)
;;          (latex-mode      . flymake-languagetool-load)
;;          (org-mode        . flymake-languagetool-load)
;;          (markdown-mode   . flymake-languagetool-load))
;;   :init
;;   ;; If using Premium Version provide the following information
;;   (setopt flymake-languagetool-server-jar nil
;;           flymake-languagetool-url "https://api.languagetoolplus.com"
;;           flymake-languagetool-api-username "d.ebling8@gmail.com"
;;           flymake-languagetool-api-key (string-trim (shell-command-to-string "rbw get 'Langtool API Key'"))))

(use-package eglot
  :ensure nil ;; Don't install eglot because it's now built-in
  :hook ((c-mode c++-mode ;; Autostart lsp servers for a given mode
                                        ; java-mode
                                        ; nix-mode
                                        ;
                 )
         . eglot-ensure)
  :custom
  ;; Good default
  (eglot-events-buffer-size 0) ;; No event buffers (Lsp server logs)
  (eglot-autoshutdown t);; Shutdown unused servers.
  (eglot-report-progress nil) ;; Disable lsp server logs (Don't show lsp messages at the bottom, java)
  ;; Manual lsp servers
  :config
  (add-to-list 'eglot-server-programs
               `(java-mode . ("jdtls-with-lombok" "-data" "/tmp/jdtls")))
  (evil-define-key 'normal 'eglot-mode-map (kbd "gra") #'eglot-code-actions))


(use-package treesit-auto
  :config
  (treesit-auto-add-to-auto-mode-alist 'all))

(use-package yasnippet-snippets
  :diminish yas-minor-mode
  :hook (prog-mode . yas-minor-mode))


;;; Text document languages
(use-package ledger-mode
  :custom
  ((ledger-binary-path "hledger")
   (ledger-mode-should-check-version nil)
   (ledger-report-auto-width nil)
   (ledger-report-links-in-register nil)
   (ledger-report-native-highlighting-arguments '("--color=always")))
  :mode ("\\.hledger\\'" "\\.ledger\\'"))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
         ("C-c C-e" . markdown-do)))

(use-package direnv)

(use-package geiser
  :ensure geiser-guile)

;;; Nix
(use-package nix-ts-mode
  :diminish nix-prettify-mode
  :mode "\\.nix\\'"
  :config
  (nix-prettify-global-mode))

;;; Zig
(use-package zig-ts-mode
  :mode "\\.zig\\'")

(use-package kotlin-ts-mode
  :mode "\\.kt\\'")

;;; Clojure setup
(use-package cider)

(use-package eat
  :config
  (eat-eshell-mode)
  (eat-eshell-visual-command-mode))

(use-package magit
  :commands magit-status)


(use-package corfu
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popupinfo delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)
  (corfu-auto t)
  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  (tab-always-indent 'nil)
  :bind (:map corfu-map ("RET" . nil))
  :init
  (global-corfu-mode)
  :config
  (evil-define-key 'insert 'corfu-map (kbd "C-y") #'corfu-complete))

(use-package cape
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  ;; The functions that are added later will be the first in the list
  (add-to-list 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  (add-to-list 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-to-list 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-to-list 'completion-at-point-functions #'cape-keyword) ;; Keyword/Snipet completion
  (add-to-list 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  (add-to-list 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  (add-to-list 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  (add-to-list 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

(use-package icomplete
  :custom
  (icomplete-compute-delay 0)
  :config
  (fido-vertical-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))


(savehist-mode) ;; Enables save history mode

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (setq consult-async-min-input 1
        consult-async-input-debounce 0.1)
  :config)

(use-package diminish)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init
  (which-key-mode 1)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display, because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)) ;; Fixes which-key window slipping out in Emacs Daemon


(use-package plantuml-mode
  :custom
  (plantuml-exec-mode 'executable)
  )

(use-package flyspell
  :delight
  :hook (text-mode . flyspell-mode)
  :bind ("<f8>" . toggle-dictionary)
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary "en_US")
  :config
  (defun toggle-dictionary()
    (interactive)
    (let* ((dic ispell-current-dictionary)
           (change (if (string= dic "pt_BR") "en_US" "pt_BR")))
      (ispell-change-dictionary change)
      (flyspell-buffer)
      (message "Dictionary switched from %s to %s" dic change)))
  (defun flyspell-buffer-after-pdict-save (&rest _)
    (flyspell-buffer))
  (advice-add 'ispell-pdict-save :after #'flyspell-buffer-after-pdict-save))

;;; Org-mode
(use-package org
  ; disable org indent for org-modern
  ;:delight org-indent-mode
  :hook (;(org-mode               . org-indent-mode)
         (org-babel-after-execute . org-redisplay-inline-images))
  :bind (("C-c y" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :custom
  (org-directory  (expand-file-name "~/Workspace/debling/orgfiles/"))
  (org-default-notes-file	(concat org-directory "notes.org"))
  (org-agenda-files       (mapc (lambda (s) (concat org-directory s)) '("calendar.org" "todo.org")))
  (org-export-with-smart-quotes t)
  (org-capture-templates `(("p" "TODO - Personal" entry (file+headline ,(concat org-directory "todo.org") "Personal")
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
  (org-plantuml-exec-mode 'plantuml)
  (org-confirm-babel-evaluate nil)
  (org-tag-alist '(("@personal" . ?p) ("@zeit" . ?z) ("@rabapp" . ?r)))

 ;; Edit settings
 (org-auto-align-tags nil)
 (org-tags-column 0)
 (org-catch-invisible-edits 'show-and-error)
 (org-special-ctrl-a/e t)
 (org-insert-heading-respect-content t)

 ;; Org styling, hide markup etc.
 (org-hide-emphasis-markers t)
 (org-pretty-entities t)
 (org-agenda-tags-column 0)
 (org-ellipsis "…")
  :config
  (require 'ol-man) ; org-link support for manpages
  (org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp . t)
                                                           (java . t)
                                                           (shell . t)
                                                           (python . t)
                                                           (plantuml . t)))
  ;
)

(use-package org-modern
  :after org
  :custom
  (org-modern-hide-stars nil)
  :config
  (global-org-modern-mode))

(use-package org-cliplink
  :after org
  :config
  (evil-define-key 'normal org-mode-map (kbd "SPC l c") 'org-cliplink))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

(use-package org-excalidraw
  :vc (:url "https://github.com/wdavew/org-excalidraw.git"
       :rev :newest)
  :custom
  (org-excalidraw-directory (concat org-directory "excalidraw")))

(use-package org-roam
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :custom
  (org-roam-directory (expand-file-name (concat org-directory "/roam")))
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates '(("d" "default" entry "* %?\n%U\n"
                                         :target (file+head "%<%Y-%m-%d>.org" "#+filetags: needs_review daily_notes\n#+title: %<%Y-%m-%d>\n\n"))))

  (org-roam-node-display-template (concat "${title} " (propertize "${tags:80}" 'face 'org-tag)))
  :config
  (org-roam-db-autosync-mode))

(use-package org-roam-ui :after org-roam)

(use-package elfeed
  :custom
  (elfeed-feeds '("http://nullprogram.com/feed/"
                  "https://planet.emacslife.com/atom.xml"
                  "https://cestlaz.zamansky.net/rss.xml"
                  "https://lukesmith.xyz/index.xml"
                  "http://www.finep.gov.br/component/ninjarsssyndicator/?feed_id=1&format=raw")))


;;; EMAIL
(use-package org-msg
 :custom
 (org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t")
 (org-msg-startup "hidestars indent inlineimages")
 (org-msg-greeting-fmt "\nHi%s,\n\n")
 (org-msg-greeting-name-limit 3)
 (org-msg-default-alternatives '((new		. (text html))
                                   (reply-to-html	. (text html))
                                   (reply-to-text	. (text))))
   (org-msg-convert-citation t)
   (org-msg-signature "
 Regards,

 #+begin_signature
 Denilson dos Santos Ebling
 CTO
 Zeit Soluções em Inteligência Artificial LTDA. | https://zeit.com.br
 Av. Roraima 1000, prédio 2, sala 22
 +55 (55) 99645-5313
 #+end_signature")
)

(setopt doc-view-resolution 400)
(use-package org-alert
  :custom
  (alert-default-style 'osx-notifier))

(require 'mu4e)
(setq user-full-name "Denilson S. Ebling"
      ;; ask for context if no context matches
      mu4e-compose-context-policy 'ask
      ;; ask for context if no context matches
      mu4e-context-policy 'pick-first
      ;; use mu4e for e-mail in emacs
      mail-user-agent 'mu4e-user-agent
      mu4e-get-mail-command "mbsync -a"
      mu4e-update-interval 600
      mu4e-change-filenames-when-moving t
      ;; use 'fancy' non-ascii characters in various places in mu4e
      mu4e-use-fancy-chars t
      ;; save attachment to my desktop (this can also be a function)
      ;; TODO: auto create this directory
      mu4e-attachment-dir "~/Downloads/mail-attachments"
      mu4e-notification-support t
      mu4e-sent-messages-behavior (lambda () (if (string= (message-sendmail-envelope-from) "d.ebling8@gmail.com") 'delete 'sent))
      sendmail-program (executable-find "msmtp")
      message-sendmail-f-is-evil t
      send-mail-function 'message-send-mail-with-sendmail
      message-send-mail-function 'message-send-mail-with-sendmail
      message-kill-buffer-on-exit t
      ;; by default mu4e uses ido, setting this to use the emacs
      ;; default, which in my case is setted to fido-mode
      mu4e-read-option-use-builtin nil
      mu4e-completing-read-function 'completing-read
      mu4e-mu-allow-temp-file t
)

(setq mu4e-contexts
      (list
       (make-mu4e-context
        :name "gmail"
        :enter-func (lambda () (mu4e-message "Enter gmail context"))
        :leave-func (lambda () (mu4e-message "Leave gmail context"))
        :match-func
        (lambda (msg)
          (when msg
            (mu4e-message-contact-field-matches msg :to "d.ebling8@gmail.com")))
        :vars '((user-mail-address . "d.ebling8@gmail.com" )
                (mu4e-drafts-folder . "/personal/[Gmail]/Drafts")
                (mu4e-refile-folder . "/personal/[Gmail]/Archive")
                (mu4e-sent-folder . "/personal/[Gmail]/Sent Mail")
                (mu4e-trash-folder . "/personal/[Gmail]/Trash")
                ;; don't save message to Sent Messages, Gmail/IMAP takes care of this
                (mu4e-sent-messages-behavior . delete)
                (message-sendmail-extra-arguments . ("-a" "personal"))))
       (make-mu4e-context
        :name "zeit"
        :enter-func (lambda () (mu4e-message "Enter zeit context"))
        :leave-func (lambda () (mu4e-message "Leave zeit context"))
        :match-func
        (lambda (msg)
          (when msg
            (mu4e-message-contact-field-matches msg :to "denilson@zeit.com.br")))
        :vars '((user-mail-address . "denilson@zeit.com.br")
                (mu4e-drafts-folder . "/zeit/Drafts")
                (mu4e-refile-folder . "/zeit/Archive")
                (mu4e-sent-folder . "/zeit/Sent")
                (mu4e-trash-folder . "/zeit/Trash")
                (mu4e-sent-messages-behavior . sent)
                (message-sendmail-extra-arguments . ("-a" "zeit"))
                (message-signature .
"Denilson dos Santos Ebling
CTO
Zeit Soluções em Inteligência Artificial LTDA. | https://zeit.com.br
Av. Roraima 1000, prédio 2, sala 22
+55 (55) 99645-5313")
                ))))

(require 'mu4e-icalendar)
(mu4e-icalendar-setup)
(setq gnus-icalendar-org-capture-file (concat org-directory "calendar.org"))
(setq gnus-icalendar-org-capture-headline '("Email"))
(gnus-icalendar-org-setup)

(add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

(setq mu4e-bookmarks
      '((:name "Unread messages"      :query "flag:unread AND NOT flag:trashed " :key 117)
        (:name "Today's messages"     :query "date:today..now AND NOT flag:trashed" :key 116)
        (:name "Last 7 days"          :query "date:7d..now AND NOT flag:trashed" :hide-unread t :key 119)
        (:name "Messages with images" :query "mime:image/* AND NOT flag:trashed" :key 112)))

(mu4e 't)


(use-package erc
  :custom
  (erc-autojoin-channels-alist '(("irc.libera.chat" "#emacs")
                                 ("irc.oftc.net" "#home-manager")))
  (erc-autojoin-timing 'ident)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 22)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-threshold-time 43200)
  (erc-prompt-for-nickserv-password nil)
  (erc-server-reconnect-attempts 5)
  (erc-server-reconnect-timeout 3)
  (erc-track-exclude-types '("JOIN" "MODE" "NICK" "PART" "QUIT"
                             "324" "329" "332" "333" "353" "477"))
  :config
  (add-to-list 'erc-modules 'notifications)
  (add-to-list 'erc-modules 'spelling)
  (erc-services-mode 1)
  (erc-update-modules))

(use-package erc-hl-nicks
  :after erc)

(use-package erc-image
  :after erc)


(use-package whitespace
  :hook (after-init . global-whitespace-mode)
  :custom
  (whitespace-style '(face tabs trailing space-before-tab indentation
                           tab-mark empty space-after-tab missing-newline-at-eof)))


(setopt sql-connection-alist
      '(("rabapp-db"
         (sql-product 'postgres)
         (sql-server "localhost")
         (sql-user "rabapp")
         (sql-password "rabapp")
         (sql-database "rabapp_db")
         (sql-port 5435))))


(defun dse/dired-open-external ()
  (interactive)
  ;; adapted from https://www.reddit.com/r/emacs/comments/cgbpvl/comment/hzgqae0/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  (let ((process-connection-type nil)
        (curr-file (dired-get-file-for-visit)))
    (start-process
     "" nil shell-file-name
     shell-command-switch
     (format "nohup 1>/dev/null 2>/dev/null xdg-open %s"
             (shell-quote-argument curr-file)))))

(evil-define-key 'normal dired-mode-map (kbd "o") #'dse/dired-open-external)

;;; Setup gc back
;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
