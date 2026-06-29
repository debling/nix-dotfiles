;;; -*- lexical-binding: t; -*-
;;; packages are installed using nix

(setopt inhibit-startup-screen t
        ;create-lockfiles nil
        make-backup-files nil
        auto-save-default nil
        display-line-numbers-type 'relative
        blink-cursor-mode nil
        indent-tabs-mode nil
        scroll-conservatively 10 ;; Smooth scrolling
        scroll-margin 5
        tab-width 4
        mode-line-collapse-minor-modes t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
;(add-hook 'text-mode-hook #'display-line-numbers-mode)
(add-hook 'makefile-mode-hook (lambda () (setopt indent-tabs-mode t)))
(add-hook 'before-save-hook  #'delete-trailing-whitespace)
(savehist-mode 1)
(global-auto-revert-mode t) ;; Automatically reload file and show changes if the file has changed

; fix for emacs not finding git/ls and other when doing a tramp ssh
; into a nixos machine
(with-eval-after-load 'tramp
  (setopt tramp-use-connection-share nil)
          ;magit-tramp-pipe-stty-settings 'pty)
  ; (connection-local-set-profile-variables 'remote-direct-async '((tramp-direct-async-process . t)))
  ; (connection-local-set-profiles '((:application tramp)) 'remote-direct-async)
  ; (customize-set-variable 'tramp-connection-asynchronous-processes t)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  ; (with-eval-after-load 'compile
    ; (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options))
    )

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

; Theme/UI setup
(setopt doom-gruvbox-dark-variant "hard")

(require 'doom-themes)
(load-theme 'doom-gruvbox t)

(let ((frame (selected-frame)))
  (unless (display-graphic-p frame)
    (set-face-attribute 'default frame :background "unspecified-bg")))

; (add-hook 'text-mode-hook #'variable-pitch-mode)
(add-to-list 'default-frame-alist '(internal-border-width . 10))
(add-to-list 'default-frame-alist '(undecorated . t))
(set-face-attribute 'default        nil :height 120 :family "Iosevka Nerd Font")
(set-face-attribute 'variable-pitch nil :family "Sans Serif")
(set-face-attribute 'fixed-pitch    nil :family (face-attribute 'default :family))
(require 'which-key)
(which-key-mode 1)

(setopt whitespace-style '(face tabs trailing space-before-tab indentation
                                tab-mark empty space-after-tab missing-newline-at-eof))
(global-whitespace-mode)

; compilation mode setup
(setopt compilation-scroll-output t
        compilation-always-kill t)
      ; compilation-auto-jump-to-first-error nil)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(add-hook 'compilation-filter-hook 'ansi-osc-compilation-filter)

(setopt evil-want-keybinding    nil
        evil-want-C-u-scroll    t
        evil-want-C-i-jump      t
        evil-undo-system        'undo-redo
        org-return-follows-link t)
(require 'evil)
(evil-define-key 'normal 'global
  (kbd "SPC f f") #'find-file
  (kbd "SPC m") #'mu4e

  (kbd "SPC p p") #'project-switch-project
  (kbd "SPC p e") #'project-eshell
  (kbd "SPC p f") #'project-find-file

  (kbd "SPC c c") #'debling/compile-project-or-file
  (kbd "SPC c r") #'debling/recompile-project-or-file

  (kbd "SPC b k") #'kill-current-buffer
  (kbd "SPC b b") #'ibuffer

  (kbd "SPC g g") #'magit-status)

(evil-mode 1)

(require 'evil-collection)
(evil-collection-init)

(require 'magit)

(setq completion-styles '(basic flex))
(fido-vertical-mode 1)
(setopt xref-show-definitions-function #'xref-show-definitions-completing-read
        xref-show-xrefs-function       #'xref-show-definitions-completing-read
        xref-search-program             'ripgrep)

; (project--list
;       (let ((work-dir (expand-file-name "~/Workspace/")))
;         (mapcar (lambda (path) (list (abbreviate-file-name path)))
;                 (process-lines "fd" "\.git$"
;                                "--prune"
;                                "--absolute-path"
;                                "--unrestricted"
;                                "--type=d"
;                                "--max-depth=3"
;                                (concat "--base-directory=" work-dir)
;                                "--format={//}/")))))

;(require 'eat)
;(eat-eshell-mode)
;(eat-eshell-visual-command-mode)

(setq treesit-font-lock-level 3)

(add-to-list 'auto-mode-alist '("\\.py\\'"   . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.zig\\'"  . zig-ts-mode))
(add-to-list 'auto-mode-alist '("\\.java\\'" . java-ts-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-ts-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'"  . css-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'"   . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"  . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.go\\'"   . go-ts-mode))
(add-to-list 'auto-mode-alist '("\\.nix\\'"  . (lambda () (require 'nix-ts-mode) (nix-ts-mode))))
(add-to-list 'auto-mode-alist '("\\.md\\'"   . (lambda () (require 'markdown-ts-mode) (markdown-ts-mode))))

(with-eval-after-load 'sql
  (setopt sql-product 'postgres)
  (add-to-list 'sql-postgres-login-params '(port :default 5432)))

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

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

(require 'flyspell)
(add-hook 'text-mode-hook #'flyspell-mode)
;"<f8>" . toggle-dictionary)
(setopt ispell-program-name "hunspell"
        ispell-dictionary "en_US")
(defun toggle-dictionary()
  (interactive)
  (let* ((dic ispell-current-dictionary)
         (change (if (string= dic "pt_BR") "en_US" "pt_BR")))
    (ispell-change-dictionary change)
    (flyspell-buffer)
    (message "Dictionary switched from %s to %s" dic change)))

(defun flyspell-buffer-after-pdict-save (&rest _)
  (flyspell-buffer))
(advice-add 'ispell-pdict-save :after #'flyspell-buffer-after-pdict-save)

(require 'hl-todo)
(setopt hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold)))
(add-hook 'prog-mode-hook #'hl-todo-mode)

(when (string= (system-name) "x1-carbon")
  (require 'org-setup)
  (require 'mu4e-setup))
