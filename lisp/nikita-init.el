(provide 'nikita-init)

;;;;; Bootstrap
(defvar gnu '("gnu" . "http://elpa.gnu.org/packages/"))
(defvar melpa-stable '("melpa-stable" . "https://stable.melpa.org/packages/"))
(defvar melpa '("melpa" . "https://melpa.org/packages/"))

(require 'package)
(add-to-list 'package-archives melpa)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(require 'bind-key)


;;;;; Change defaults
(setq create-lockfiles nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
(setq inhibit-startup-message t)

(fset 'yes-or-no-p 'y-or-n-p)

(setq scroll-step 1
      scroll-conservatively 5)

(set-language-environment "UTF-8")
(setq apropos-sort-by-scores t)

(setq-default indent-tabs-mode nil)
(setq sentence-end-double-space nil)

(electric-pair-mode 1)


;;;;; Ido
(use-package ido
  :demand
  :init
  (setq ido-enable-flex-matching t
	ido-auto-merge-work-directories-length -1)
  :config
  (ido-mode t)
  (ido-everywhere)
  :bind
  ("C-x C-g" . ido-switch-buffer)
  ("C-x g" . ido-switch-buffer-other-window)
  ("C-x f" . ido-find-file-other-window))


;;;;; Linum
(use-package linum-relative
  :ensure t
  :init
  ;; Show current line number instead of zero
  (setq linum-relative-current-symbol "")
  :config
  (linum-relative-global-mode))


;;;;; init.el, Config
(bind-key "C-c i"
	  (lambda () (interactive)
            (find-file-existing "~/.emacs.d/lisp/nikita-init.el")))

(bind-key "C-c M-i"
          (lambda () (interactive)
            (find-file-existing "~/.emacs.d/lisp/nikita-init.el")
            (helm-imenu)))

(bind-key "C-c p"
	  (lambda () (interactive)
            (find-file-existing "~/.emacs.d/pain_points.org")))


;;;;; Evil

(defun nik--evil-c-u ()
  (interactive)
  (evil-delete (point-at-bol) (point)))

(defun nik--evil-scroll-up ()
  (interactive)
  (evil-scroll-line-up 5))
(defun nik--evil-scroll-down ()
  (interactive)
  (evil-scroll-line-down 5))

(defun nik--insert-blank-above (count)
  (interactive "p")
  (save-excursion
    (move-beginning-of-line nil)
    (insert-before-markers (make-string count ?\n))))

(defun nik--insert-blank-below (count)
  (interactive "p")
  (save-excursion
    (move-end-of-line nil)
    (insert (make-string count ?\n))))

(use-package evil
  :ensure t
  :init
  (setq evil-want-fine-undo nil)
  :config
  (bind-key "RET" 'save-buffer evil-normal-state-map)
  (bind-key "C-w q" 'evil-quit evil-normal-state-map)
  (bind-key "C-u" 'nik--evil-c-u evil-insert-state-map)
  (bind-key "C-e" 'end-of-line evil-insert-state-map)

  (evil-declare-not-repeat (bind-key "C-k" 'nik--evil-scroll-up evil-motion-state-map))
  (evil-declare-not-repeat (bind-key "C-j" 'nik--evil-scroll-down evil-motion-state-map))

  ;; Basic Hebrew support
  (bind-key "ן" 'evil-insert evil-normal-state-map)
  (bind-key "ם" 'evil-open-below evil-normal-state-map)
  ; This overwrites recursive edit, but i'm not using it ATM
  (bind-key "C-]" 'evil-normal-state evil-insert-state-map)
  (bind-key "ו" 'undo evil-normal-state-map)

  (bind-key "י" 'evil-backward-char evil-motion-state-map)
  (bind-key "ח" 'evil-next-line evil-motion-state-map)
  (bind-key "ל" 'evil-previous-line evil-motion-state-map)
  (bind-key "ך" 'evil-forward-char evil-motion-state-map)

  ;; vim-unimpaired
  (bind-key "[ SPC" 'nik--insert-blank-above evil-normal-state-map)
  (bind-key "] SPC" 'nik--insert-blank-below evil-normal-state-map)

  (evil-mode t))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))


;;;;; Graphics, Theme
(load-theme 'tango-dark)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(tool-bar-mode -1)
(show-paren-mode 1)


;;;;; Helm
(use-package helm
  :ensure t
  :config
  (use-package helm-config)
  (bind-key "M-x" 'helm-M-x))


;;;;; imenu
(defun nik--imenu-elisp-sections ()
  (add-to-list 'imenu-generic-expression '("Sections" "^;;;;; \\(.+\\)$" 1) t))

(add-hook 'emacs-lisp-mode-hook 'nik--imenu-elisp-sections)
(bind-key "M-i" 'helm-imenu)


;;;;; ibuffer
(bind-key "C-x C-b" 'ibuffer)


;;;;; Help
(bind-key "C-h j f" 'find-function)
(bind-key "C-h j v" 'find-variable)
(bind-key "C-h a" 'helm-apropos)


;;;;; Clipboard

;; Evil mode clipboard behaves funny, because it works with the kill
;; ring, which in turn interacts with the system clipboard on every
;; operation. These hooks disable system clipboard when evil is
;; running it's stuff.

;; Simpleclip has a function that can just get the content of the
;; system clipboard. I don't want to pull the entire plugin, so I'll
;; just paste the relevant functions here:
;; github.com/rolandwalker/simpleclip
;; 7079086ec09a148fcc9146ba9bd10e12fb011861

;; MS Windows workaround - w32-get-clipboard-data returns nil
;; when Emacs was the originator of the clipboard data.
(defvar simpleclip-contents nil
  "Value of most-recent cut or paste.")

(defun simpleclip-get-contents ()
  "Return the contents of the system clipboard as a string."
  (condition-case nil
      (cond
        ((fboundp 'ns-get-pasteboard)
         (ns-get-pasteboard))
        ((fboundp 'w32-get-clipboard-data)
         (or (w32-get-clipboard-data)
             simpleclip-contents))
        ((and (featurep 'mac)
              (fboundp 'x-get-selection))
         (x-get-selection 'CLIPBOARD 'NSStringPboardType))
        ((fboundp 'x-get-selection)
         (x-get-selection 'CLIPBOARD))
        (t
         (error "Clipboard support not available")))
    (error
     (condition-case nil
         (cond
           ((eq system-type 'darwin)
            (with-output-to-string
              (with-current-buffer standard-output
                (call-process "/usr/bin/pbpaste" nil t nil "-Prefer" "txt"))))
           ((eq system-type 'cygwin)
            (with-output-to-string
              (with-current-buffer standard-output
                (call-process "getclip" nil t nil))))
           ((memq system-type '(gnu gnu/linux gnu/kfreebsd))
            (with-output-to-string
              (with-current-buffer standard-output
                (call-process "xsel" nil t nil "--clipboard" "--output"))))
           (t
            (error "Clipboard support not available")))
       (error
        (error "Clipboard support not available"))))))

(defun simpleclip-set-contents (str-val)
  "Set the contents of the system clipboard to STR-VAL."
  (condition-case nil
      (cond
        ((fboundp 'ns-set-pasteboard)
         (ns-set-pasteboard str-val))
        ((fboundp 'w32-set-clipboard-data)
         (w32-set-clipboard-data str-val)
         (setq simpleclip-contents str-val))
        ((fboundp 'x-set-selection)
         (x-set-selection 'CLIPBOARD str-val))
        (t
         (error "Clipboard support not available")))
    (error
     (condition-case nil
         (cond
           ((eq system-type 'darwin)
            (with-temp-buffer
              (insert str-val)
              (call-process-region (point-min) (point-max) "/usr/bin/pbcopy")))
           ((eq system-type 'cygwin)
            (with-temp-buffer
              (insert str-val)
              (call-process-region (point-min) (point-max) "putclip")))
           ((memq system-type '(gnu gnu/linux gnu/kfreebsd))
            (with-temp-buffer
              (insert str-val)
              (call-process-region (point-min) (point-max) "xsel" nil nil nil "--clipboard" "--input")))
           (t
            (error "Clipboard support not available")))
       (error
        (error "Clipboard support not available"))))))


(defun evil-yank-advice (orig-func beg end &optional register yank-handler)
  (if (and register
           (memq register '(?+ ?*)))
      (funcall orig-func beg end register yank-handler)
    (let ((interprogram-cut-function nil)
          (save-interprogram-paste-before-kill nil))
      (funcall orig-func beg end register yank-handler))))

(defun evil-paste-advice (orig-func &rest args)
  (let ((interprogram-cut-function nil)
        (interprogram-paste-function nil))
    (apply orig-func args)))

(defun evil-set-register-cliboard (register text)
  (when (memq register '(?+ ?*))
    (simpleclip-set-contents text)
    t))

(defun evil-get-register-cliboard (orig-func register)
  (if (memq register '(?+ ?*))
      (simpleclip-get-contents)
    (funcall orig-func register)))

(advice-add 'evil-yank-lines :around #'evil-yank-advice)
(advice-add 'evil-yank-characters :around #'evil-yank-advice)
(advice-add 'evil-yank-rectangle :around #'evil-yank-advice)

(advice-add 'evil-paste-before :around #'evil-paste-advice)
(advice-add 'evil-paste-after :around #'evil-paste-advice)
(advice-add 'evil-visual-paste :around #'evil-paste-advice)

(advice-add 'evil-set-register :before-until #'evil-set-register-cliboard)
(advice-add 'evil-get-register :around #'evil-get-register-cliboard)
(advice-add 'evil-visual-update-x-selection :override #'ignore)


;;;;; Mac OS X
(use-package exec-path-from-shell
  :ensure t
  :if (eq window-system 'ns)
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-envs '("PATH")))


;;;;; Lisp, Paredit
(use-package paredit
  :ensure t
  :config
  (add-hook 'lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
  (unbind-key "C-j" paredit-mode-map))

(evil-define-operator evil-eval (beg end type)
  "Evals the code in motion"
  :move-point nil
  :repeat nil
  (interactive "<R>")
  (eval-region beg end)
  (message "Evaluated region"))
(define-key evil-normal-state-map "gr" 'evil-eval)
(define-key evil-motion-state-map "gr" 'evil-eval)


;;;;; CC mode
(use-package cc-mode
  :config
  (add-to-list 'c-default-style '(other . "stroustrup")))


;;;;; Magit
(use-package magit
  :ensure t
  :bind
  ("<f12>" . magit-status))
