(provide 'nikita-init)

;;;;; Bootstrap
(require 'cl)

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
(setq-default tab-width 4)
(setq sentence-end-double-space nil)
(setq case-replace nil)
(setq vc-follow-symlinks t)

(electric-pair-mode 1)

(modify-syntax-entry ?_ "w" (standard-syntax-table))


;;;;; Generic

(defun quit-other-window (&optional kill)
  (interactive)
  (quit-window kill (next-window)))
(bind-key "<f7>" 'quit-other-window)


;;;;; Mode line
(column-number-mode t)


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
  ("C-;" . ido-switch-buffer)
  ("C-:" . ido-switch-buffer-other-window)
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

(defun nik--evil-paste-above (count &optional register)
  (interactive "p<x>")
  (dotimes (i (or count 1))
    (evil-insert-newline-above)
    (evil-paste-before 1 register)
    (evil-move-beginning-of-line)))

(defun nik--evil-paste-below (count &optional register)
  (interactive "p<x>")
  (dotimes (i (or count 1))
    (evil-insert-newline-below)
    (evil-paste-after 1 register)
    (evil-move-beginning-of-line)))

(defun use-clipboard (f)
  "Returns f with evil-this-register overwritten to the clipboard"
  (lexical-let ((func f))
    #'(lambda ()
        (interactive)
        (let ((evil-this-register ?+))
          (call-interactively func)))))

;; (defun ff-find-other-file-other-window ()
;;   (interactive)
;;   (save-selected-window
;;    (ff-find-other-file t)))
(defun ff-find-other-file-other-window ()
  (interactive)
  (ff-find-other-file t))

(defun save-some-buffers-no-confirm ()
  (interactive)
  (save-some-buffers 'no-confirm))

(use-package evil
  :ensure t
  :init
  (setq evil-want-fine-undo nil)
  (setq evil-search-module 'evil-search)
  :config
  (evil-declare-not-repeat (bind-key "RET" 'save-some-buffers-no-confirm evil-normal-state-map))
  (evil-declare-not-repeat (bind-key "C-w q" 'evil-quit evil-normal-state-map))
  (bind-key "C-u" 'nik--evil-c-u evil-insert-state-map)
  (evil-declare-not-repeat (bind-key "C-e" 'end-of-line evil-insert-state-map))
  (evil-declare-not-repeat (bind-key "g o" 'ff-find-other-file evil-normal-state-map))
  (evil-declare-not-repeat (bind-key "g O" 'ff-find-other-file-other-window evil-normal-state-map))

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

  (bind-key "C-x C-l" 'hippie-expand evil-insert-state-map)
  (bind-key "C-l" 'hippie-expand evil-insert-state-map)

  (bind-key "z p" (use-clipboard 'evil-paste-after) evil-normal-state-map)
  (bind-key "z P" (use-clipboard 'evil-paste-before) evil-normal-state-map)

  ;; vim-unimpaired
  (bind-key "[ SPC" 'nik--insert-blank-above evil-normal-state-map)
  (bind-key "] SPC" 'nik--insert-blank-below evil-normal-state-map)
  (bind-key "[ p" 'nik--evil-paste-above evil-normal-state-map)
  (bind-key "] p" 'nik--evil-paste-below evil-normal-state-map)
  (bind-key "z [ p" (use-clipboard 'nik--evil-paste-above) evil-normal-state-map)
  (bind-key "z ] p" (use-clipboard 'nik--evil-paste-below) evil-normal-state-map)

  (evil-mode t))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-vimish-fold
  :ensure t
  :config
  (evil-vimish-fold-mode 1))


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
  :bind
  ("M-x" . helm-M-x))


;;;;; imenu
(defun nik--imenu-elisp-sections ()
  (add-to-list 'imenu-generic-expression '("Sections" "^;;;;; \\(.+\\)$" 1) t))

(add-hook 'emacs-lisp-mode-hook 'nik--imenu-elisp-sections)
(bind-key "M-i" 'helm-imenu)


;;;;; dired
(defun nik--dired-here ()
  (interactive)
  (dired "."))

(use-package dired
  :config
  (bind-key "-" 'nik--dired-here evil-normal-state-map)
  (bind-key "-" 'dired-up-directory dired-mode-map))


;;;;; ibuffer
(bind-key "C-x C-b" 'ibuffer)


;;;;; Help
(bind-key "C-h j f" 'find-function)
(bind-key "C-h j v" 'find-variable)
(bind-key "C-h a" 'helm-apropos)


;;;;; Projectile

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode))

(use-package helm-projectile
  :ensure t
  :config
  (bind-key "C-p" 'helm-projectile evil-normal-state-map))


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

(defun evil-get-register-cliboard (orig-func register &optional noerror)
  (if (memq register '(?+ ?*))
      (simpleclip-get-contents)
    (funcall orig-func register noerror)))

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


;;;;; Server
(server-start)


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
  :init
  (advice-add
   'c-populate-syntax-table :after
   (lambda (table)
      (modify-syntax-entry ?_ "w" table)))
  :config
  (add-to-list 'c-default-style '(other . "stroustrup")))


;;;;; Magit
(use-package magit
  :ensure t
  :config
  (add-hook 'magit-status-mode-hook (lambda () (linum-relative-mode 0)))
  :bind
  ("<f12>" . magit-status))


;;;;; Company

;; https://gist.github.com/aaronjensen/a46f88dbd1ab9bb3aa22
;; aaronjensen/company-complete-cycle.el
;; Modify company so that tab and S-tab cycle through completions without
;; needing to hit enter.

(defvar-local company-simple-complete--previous-prefix nil)
(defvar-local company-simple-complete--before-complete-point nil)

(defun company-simple-complete-frontend (command)
  (when (or (eq command 'show)
            (and (eq command 'update)
                 (not (equal company-prefix company-simple-complete--previous-prefix))))
    (setq company-selection -1
          company-simple-complete--previous-prefix company-prefix
          company-simple-complete--before-complete-point nil)))

(defun company-simple-complete-next (&optional arg)
  (interactive "p")
  (company-select-next arg)
  (company-simple-complete//complete-selection-and-stay))

(defun company-simple-complete-previous (&optional arg)
  (interactive "p")
  (company-select-previous arg)
  (company-simple-complete//complete-selection-and-stay))

(put 'company-simple-complete-next 'company-keep t)
(put 'company-simple-complete-previous 'company-keep t)

(defun company-simple-complete//complete-selection-and-stay ()
  (if (cdr company-candidates)
      (when (company-manual-begin)
        (when company-simple-complete--before-complete-point
          (delete-region company-simple-complete--before-complete-point (point)))
        (setq company-simple-complete--before-complete-point (point))
        (unless (eq company-selection -1)
          (company--insert-candidate (nth company-selection company-candidates)))
        (company-call-frontends 'update)
        (company-call-frontends 'post-command))
    (company-complete-selection)))

(defadvice company-set-selection (around allow-no-selection (selection &optional force-update))
  "Allow selection to be -1"
  (setq selection
        ;; TODO deal w/ wrap-around
        (if company-selection-wrap-around
            (mod selection company-candidates-length)
          (max -1 (min (1- company-candidates-length) selection))))
  (when (or force-update (not (equal selection company-selection)))
    (setq company-selection selection
          company-selection-changed t)
    (company-call-frontends 'update)))

(defadvice company-tooltip--lines-update-offset (before allow-no-selection (selection _num-lines _limit))
  "Allow selection to be -1"
  (when (eq selection -1)
    (ad-set-arg 0 0)))

(defadvice company-tooltip--simple-update-offset (before allow-no-selection (selection _num-lines limit))
  "Allow selection to be -1"
  (when (eq selection -1)
    (ad-set-arg 0 0)))

(use-package company
  :ensure t
  :init
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t)
  (setq company-require-match nil)
  (setq company-dabbrev-ignore-case t)
  :config

  (global-company-mode)
  (add-hook 'evil-insert-state-exit-hook 'company-cancel)
  (unbind-key "<return>" company-active-map)
  (unbind-key "RET" company-active-map)
  (unbind-key "<tab>" company-active-map)
  (unbind-key "TAB" company-active-map)
  (evil-declare-change-repeat
   (bind-key "<tab>" 'company-simple-complete-next company-active-map))
  (evil-declare-change-repeat
   (bind-key "<backtab>" 'company-simple-complete-previous company-active-map))
  (unbind-key "C-w" company-active-map)

  (ad-activate 'company-set-selection)
  (ad-activate 'company-tooltip--simple-update-offset)
  (ad-activate 'company-tooltip--lines-update-offset)
  (add-to-list 'company-frontends 'company-simple-complete-frontend))


;;;;; Irony
(use-package irony
  :ensure t
  :init
  (setq irony-cdb-search-directory-list '("." "build" "out"))
  :config
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'c++-mode-hook 'irony-mode))

(use-package company-irony
  :ensure t
  :config
  (eval-after-load 'company
    '(add-to-list 'company-backends 'company-irony))
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (advice-add 'company-irony--post-completion :override 'ignore))


;;;;; Hippie expand
(use-package hippie-exp
  :config
  (setq hippie-expand-try-functions-list
        '(try-expand-line
          try-expand-line-all-buffers)))


;;;;; Highlight with space
(defun highlight-symbol-at-point-all-buffers ()
  (interactive)
  (let ((symbol-regexp (find-tag-default-as-symbol-regexp)))
    (setq evil-ex-search-pattern (list symbol-regexp t t)
          evil-ex-search-direction 'forward)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (dolist (pattern (bound-and-true-p hi-lock-interactive-patterns))
          (hi-lock-unface-buffer (car pattern)))
        (hi-lock-face-buffer symbol-regexp 'hi-blue)))))

(defun unhighlight-all-buffers ()
  (interactive)
  (evil-ex-nohighlight)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (dolist (pattern (bound-and-true-p hi-lock-interactive-patterns))
        (hi-lock-unface-buffer (car pattern))))))

(evil-declare-not-repeat (bind-key "<SPC>" 'highlight-symbol-at-point-all-buffers evil-normal-state-map))
(evil-declare-not-repeat (bind-key "<DEL>" 'unhighlight-all-buffers evil-normal-state-map))


;;;;; GNU Global ggtags
(use-package ggtags
  :ensure t
  :config
  (bind-key "C-]" 'ggtags-find-tag-dwim evil-normal-state-map))


;;;;; Cmake
(use-package cmake-mode
  :ensure t)


;;;;; Wiki
(defvar wiki-root (expand-file-name "~/wiki/"))

(defun wiki-commit ()
  (interactive)
  (if (string-prefix-p
       wiki-root
       (expand-file-name default-directory))
      (async-shell-command "git add -A && git commit -m . && git push")
    (error "Not on a wiki buffer")))

(defun wiki-helm-find-file ()
  (interactive)
  (let ((default-directory wiki-root))
    (helm-projectile-find-file)))

(bind-key "<C-f12>" 'wiki-commit)
(bind-key "C-c w" 'wiki-helm-find-file)


;;;;; Dash
(use-package helm-dash
  :ensure t
  :init
  (setq helm-dash-common-docsets
        '("Python 3"
          "Python 2"
          "wxWidgets"
          "C++"
          "C"))
  (bind-key "g <f1>" 'helm-dash-at-point evil-normal-state-map)
  :bind
  (("<f1>" . helm-dash)))


;;;;; Typescript
(use-package typescript-mode
  :ensure t)

(use-package tide
  :ensure t
  :init

  (defun tide-setup-hook ()
    (tide-setup)
    (flycheck-mode)
    (eldoc-mode +1))
  (add-hook 'typescript-mode-hook 'tide-setup-hook))


;;;;; Go
(use-package go-mode
  :ensure t)
