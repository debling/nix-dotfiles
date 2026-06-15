;; -*- lexical-binding: t; -*-

;; 1. Maximize memory threshold during startup to prevent garbage collection slowdowns
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; 2. Restore normal memory thresholds immediately after Emacs finishes booting
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024) ; 16MB standard overhead
                  gc-cons-percentage 0.1)))

;; 3. Prevent UI element generation to stop startup window flickering
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; 4. Stop Emacs from automatically activating package systems before init.el runs
(setq package-enable-at-startup nil)

;; 5. Prevent unwanted runtime configuration changes from altering file layouts
(setq frame-inhibit-implied-resize t)

