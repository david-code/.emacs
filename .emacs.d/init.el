;; Save custom variables in separate file
(setq custom-file "~/.emacs.d/custom.el")
(ignore-errors (load custom-file))
(setq enable-local-variables :safe)

;;; Package repository stuff
(require 'package)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))

(package-initialize)
(package-refresh-contents)

;;; Bug 3431
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;;; Set up use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
;; Make sure that the package is always downloaded
(setq use-package-always-ensure t)

;; auto update!
(use-package auto-package-update
  :defer 10
  :config
  ;; Delete residual old versions
  (setq auto-package-update-delete-old-versions t)
  ;; Do not bother when updates take place
  (setq auto-package-update-hide-results t)
  ;; Update installed packages at startup if there is an update pending
  (auto-package-update-maybe))

;; Help discovering what key to press
(use-package which-key
  :diminish
  :defer 5
  :config (which-key-mode)
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.05))

(use-package diminish
  :defer 5
  :config
  (diminish 'org-indent-mode))

(defun my/make-init-el-and-README ()
  "Tangle .el and a README from init.org"
  (interactive "P") ;; Places value of universal argument into: current-prefix-arg
  (when current-prefix-arg
    (let * ((time (current-time))
            (_date (format-time-string "_%Y-%m-%d"))
            (.emacs "~/.emacs")
            (.emacs.el "~/.emacs.el"))
         ;; make README.org
         (save-excursion
           (org-babel-goto-named-src-block "make-readme")
           (org-babel-execute-src-block))

         ;; remove other candidates
         (ignore-errors
           (f-move .emacs (concat .emacs _date))
           (f-move .emacs.el (concate .emacs.el _date)))

         ;; make init.el
         (org-babel-tangle)
         (load-file "~/.emacs.d/init.el")

         ;; Acknowlegement
         (message "Tangled, compiled and loaded init.el; and made README ... %.06f seconds"
                  (float-time (time-since time))))))

;; (add-hook 'after-save-hook 'my/make-init-el-and-README nil 'local-to-this-file-please)

;;; Store all backup files in the same directory
(setq backup-directory-alist
      `(("." . "/var/local/emacs/backups")))
(setq backup-by-copying t)

;;; Use spaces, not tabs
(setq-default indent-tabs-mode nil)

;;; No trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; JAVASCRIPT
(setq js-indent-level 2)

;;; WEB-MODE
(use-package web-mode
  :init
  ;;; Allow identifying template with comment
  (setq web-mode-enable-engine-detection t)
  (setq web-mode-style-padding 2)
  (setq web-mode-script-padding 2)
  (fci-mode)
  :mode ("\\.html\\'" "\\.svelte\\'"))

;;; FLYCHECK
(use-package flycheck-rust)
(use-package flycheck
  :init
  ;;; set up global flycheck mode
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;;; MAGIT
(use-package magit
  :bind (("C-x g" . 'magit)))

;;; RECENTLY OPENED
;; (require 'recentf)
;; (recentf-mode 1)
;; Open recent files with "C-c f"
;; (global-set-key (kbd "C-c f") 'recentf-open-files)
(use-package recentf
  :config
  (recentf-mode 1)
  :bind ("C-c f" . 'recentf-open-files))

;; elfeed
(use-package elfeed-org
  :ensure t
  :config
  (elfeed-org)
  (setq rmh-elfeed-org-files (list "~/rss/config.org")))

;; use a nice theme
(use-package moe-theme
  :config
  (moe-light))

(use-package counsel-etags
  :ensure t
  :bind (("C-]" . counsel-etags-find-tag-at-point))
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'after-save-hook
                        'counsel-etags-virtual-update-tags 'append 'local)))
  :config
  (setq counsel-etags-update-interval 60)
  (push "build" counsel-etags-ignore-directories))

;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line

(provide 'init)
;;; init.el ends here
