;; -*- lexical-binding: t; -*-

;;; initial setup
;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t ;; Always ensures that a package is installed
      use-package-enable-imenu-support t
      package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
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
  (setq evil-collection-mode-list '(dired ibuffer magit corfu vertico consult))
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
  ((prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
   (prog-mode . display-line-numbers-mode))
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
  :ensure nil ; already comes with emacs
  :demand t
  :hook (text-mode . variable-pitch-mode)
  :config
  (modus-themes-load-theme 'modus-operandi)
  (if (not (eq system-type 'darwin))
      (add-to-list 'default-frame-alist '(undecorated . t)))

  (set-face-attribute 'default nil
					  :font "Iosevka Nerd Font"
					  :height 130
					  :weight 'medium)
  (set-face-attribute 'variable-pitch nil :font "sans")
  (setq modus-themes-mixed-fonts t))


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
  (setq project--list
        (let ((work-dir (expand-file-name "~/Workspace/")))
          (mapcar (lambda (path) (list (abbreviate-file-name path)))
                  (process-lines "fd" "\.git$"
                                 "--prune"
                                 "--absolute-path"
                                 "--unrestricted"
                                 "--type=d"
                                 "--max-depth=3"
                                 (concat "--base-directory=" work-dir)
                                 "--format={//}")))))

(use-package compile
  :custom
  (compilation-scroll-output t)
  (compilation-always-kill t)
  :config
  (defun colorize-compilation ()
    (require 'ansi-color)
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook #'colorize-compilation))

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
    		   `(java-mode . ("jdtls-with-lombok" "-data" "/tmp/jdtls"))))


(use-package treesit-auto
  :config
  (treesit-auto-add-to-auto-mode-alist 'all))

(use-package yasnippet-snippets
  :diminish yas-minor-mode
  :hook (prog-mode . yas-minor-mode))


;;; Text document languages
(use-package markdown-ts-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config (use-package edit-indirect))


;;; Nix
(use-package nix-ts-mode
  :diminish nix-prettify-mode
  :mode "\\.nix\\'"
  :config 
  (nix-prettify-global-mode))

;;; Zig
(use-package zig-ts-mode
  :mode "\\.zig\\'"
  :config 
  (if (>= emacs-major-version 28)
	  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
	(progn
	  (defun colorize-compilation-buffer ()
		(let ((inhibit-read-only t))
		  (ansi-color-apply-on-region compilation-filter-start (point))))
	  (add-hook 'compilation-filter-hook 'colorize-compilation-buffer)))
  )

;;; Clojure setup
(use-package cider)

(use-package eat
  :config
  (eat-eshell-mode)
  (eat-eshell-visual-command-mode))

(use-package magit
  :commands magit-status)

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(use-package corfu
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
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
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode)
  :config
  (evil-define-key 'insert 'corfu-map (kbd "C-y") #'corfu-complete))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

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

;;; Org-mode
(use-package org
  :delight org-indent-mode
  :hook ((org-mode	              . org-indent-mode)
         (org-babel-after-execute . org-redisplay-inline-images))
  :bind (("C-c y" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :custom
  (org-directory  "~/Workspace/debling/orgfiles/")
  (org-default-notes-file	(concat org-directory "notes.org"))
  (org-agenda-files       (mapc (lambda (s) (concat org-directory s)) '("email.org" "todo.org" "roam/daily/")))
  (org-export-with-smart-quotes t)
  (org-capture-templates '(("p" "TODO - Personal" entry (file+headline (concat org-directory "todo.org") "Personal")
                            "* TODO [#B] %?\n%U" :clock-in t :clock-resume t :empty-lines 1)
                           ("w" "TODO - Work" entry (file+headline (concat org-directory "todo.org") "Work")
                            "* TODO [#B] %?\n%U" :clock-in t :clock-resume t :empty-lines 1)
                           ("u" "TODO - Uni" entry (file+headline (concat org-directory "todo.org") "University")
                            "* TODO [#B] %?\n%U" :clock-in t :clock-resume t :empty-lines 1)
                           ("n" "Note" entry (file (concat org-directory "notes.org"))
                            "* %? :NOTE:\n%U\n%a\n" :empty-lines 1)
                           ("j" "Journal" entry (file+datetree (concat org-directory "jornal.org"))
                            "* %?\n%U\n" :clock-resume t)))
  (org-plantuml-exec-mode 'plantuml)
  (org-confirm-babel-evaluate nil)
  :config
  (require 'ol-man) ; org-link support for manpages
  (org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp . t)
                                                           (java . t)
                                                           (python . t)
                                                           (plantuml . t)))
  )

(use-package org-cliplink
  :after org
  :config
  (evil-define-key 'normal org-mode-map (kbd "SPC l c") 'org-cliplink))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

;; (use-package org-excalidraw
;;   :config
;;   (org-excalidraw-directory (concat org-directory "~/org/excalidraw")))

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
 --
 *Denilson*
 /One Emacs to rule them all/
 #+end_signature")
  )
                                        ; (org-msg-mode)

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
	  mu4e-attachment-dir "~/Downloads/mail-attachments"
	  mu4e-notification-support t
	  sendmail-program (executable-find "msmtp")
	  send-mail-function 'sendmail-send-it
	  message-send-mail-function 'sendmail-send-it
	  message-kill-buffer-on-exit t

      mu4e-read-option-use-builtin nil
      mu4e-completing-read-function 'completing-read)

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
			    (message-signature . "
Denilson dos Santos Ebling
CTO
Zeit Soluções em Inteligência Artificial LTDA. | https://zeit.com.br
Av. Roraima 1000, prédio 2, sala 22
(55) 99645-5313")
			    ))))

(require 'mu4e-icalendar)
(mu4e-icalendar-setup)
(setq gnus-icalendar-org-capture-file (concat org-directory "calendar.org"))
(setq gnus-icalendar-org-capture-headline '("Email"))
(gnus-icalendar-org-setup)

(add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

(setq mu4e-bookmarks 
      '((:name "Unread messages" :query "flag:unread AND NOT flag:trashed " :key 117)
        (:name "Today's messages" :query "date:today..now AND NOT flag:trashed" :key 116)
        (:name "Last 7 days" :query "date:7d..now AND NOT flag:trashed" :hide-unread t :key 119)
        (:name "Messages with images" :query "mime:image/* AND NOT flag:trashed" :key 112)))

(mu4e 't)

(setq erc-hide-list '("JOIN" "PART" "QUIT"))

;;; Setup gc back
;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
