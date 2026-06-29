;; -*- lexical-binding: t; -*-

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
      mu4e-compose-format-flowed t
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
"Denílson dos Santos Ebling
Diretor de Tecnologia
Zeit Soluções em Inteligência Artificial LTDA. | https://zeit.com.br

Telefone: +55 (55) 99645-5313

Zeit - anexo a empresa HCC Energia Solar.
Estr. Mun. Norberto José; Kipper, 2169 - Camobi
Santa Maria - RS, 97110-530")
                ))))

(require 'mu4e-icalendar)
(mu4e-icalendar-setup)
(setq gnus-icalendar-org-capture-file (concat org-directory "calendar.org"))
(setq gnus-icalendar-org-capture-headline '("Email"))
(gnus-icalendar-org-setup)

(add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

(setq mu4e-bookmarks
      '((:name "Unread messages (Zeit)"        :query "flag:unread AND maildir:/zeit/inbox" :key ?u)
	(:name "Unread messages (Gmail)"       :query "flag:unread AND maildir:/personal/inbox" :key ?g)
	(:name "Unread messages (ContatoZeit)" :query "flag:unread AND maildir:/zeit-contato/inbox" :key ?c)
        (:name "Today's messages"              :query "date:today..now AND NOT flag:trashed" :key ?t)
        (:name "Last 7 days"                   :query "date:7d..now AND NOT flag:trashed" :hide-unread t :key ?w)
	(:name "All Unread messages"           :query "flag:unread AND NOT flag:trashed " :key ?a)))
(mu4e 't)

(provide 'mu4e-setup)
