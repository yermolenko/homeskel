;; -*- coding: utf-8 -*-

(when (file-directory-p "~/.emacs.d/lisp/icicles")
  (add-to-list 'load-path "~/.emacs.d/lisp/icicles"))
(add-to-list 'load-path "~/.emacs.d/lisp")
(load "yaa.el")
;; (load "yaa-staging.el")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(if (eq window-system 'x)
    (progn
     (set-frame-font "DejaVu Sans Mono-14")
      (when (string-match-p (regexp-quote "edu.ua") system-name)
        (set-frame-font "DejaVu Sans Mono-14"))
      (when (string= system-name "yapc")
        (set-frame-font "DejaVu Sans Mono-16"))
      (when (string= system-name "yanb")
        (set-frame-font "DejaVu Sans Mono-14"))
      ))

(tool-bar-mode -1)
(setq visible-bell 1)
(setq inhibit-startup-screen t)

(setq column-number-mode t)

(global-auto-revert-mode t)

(setq scroll-conservatively 50)
(setq scroll-preserve-screen-position 't)
;;(setq scroll-step 1)

;; ------------------------------

(setq ispell-program-name "aspell")
(setq ispell-dictionary "russian")
;;(setq ispell-dictionary "english")
(when (string-match-p (regexp-quote "edu.ua") system-name)
  (setq ispell-dictionary "ukrainian"))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))
;; (add-hook 'html-mode-hook 'flyspell-mode)
(eval-after-load "flyspell"
  '(define-key flyspell-mode-map (kbd "C-;") nil))

;; --------------------

(defalias 'iscd 'ispell-change-dictionary)
(defalias 'isb 'ispell-buffer)
(defalias 'isr 'ispell-region)
(defalias 'isw 'ispell-word)

;; ------------------------------

(defun ensure-package-installed (&rest packages)
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "https://melpa.org/packages/")
   t)
  (package-initialize))

(defun yaa-install-packages ()
  (interactive)
  (when (>= emacs-major-version 24)
    (package-refresh-contents)
    ;; 'icicles
    ;; 'dash
    ;; 'git-commit
    (ensure-package-installed
     'browse-kill-ring
     'clean-aindent-mode
     'company 'company-c-headers 'company-math 'company-statistics
     'math-symbol-lists
     'async
     'with-editor
     'edit-server
     'yasnippet
     'xah-replace-pairs
     'magit 'magit-popup)
    ))

;; -------------------

(setq edit-server-new-frame nil)
;; (eval-after-load 'edit-server
;;   '(define-key edit-server-edit-mode-map (kbd "C-c C-c") nil))
(add-hook 'edit-server-edit-mode-hook
          (lambda ()
            (define-key edit-server-edit-mode-map (kbd "C-c C-c") nil)
            ))
;; (setq edit-server-url-major-mode-alist
;;       '(("github\\.com" . markdown-mode)))
(add-hook 'edit-server-start-hook
          (lambda ()
            (when (string-match "github.com" (buffer-name))
              (markdown-mode))
            (when (string-match-p (regexp-quote "edu.ua") (buffer-name))
              (html-mode))
            ))
(edit-server-start)

;; -------------------

(global-set-key (kbd "<f4>") 'speedbar)
(global-set-key (kbd "C-<f4>") 'yaa-open-current-dir-in-mc)
(global-set-key (kbd "C-S-<f4>") 'yaa-open-in-external-app)

(global-set-key (kbd "<f5>")
		(lambda () (interactive)
		  (toggle-input-method)))

(setq yaa-keybind-switch-to-russian "C-<f5>")
(setq yaa-keybind-switch-to-ukrainian "C-S-<f5>")
(when (string-match-p (regexp-quote "edu.ua") system-name)
  (progn
    (setq yaa-keybind-switch-to-russian "C-S-<f5>")
    (setq yaa-keybind-switch-to-ukrainian "C-<f5>")))

(global-set-key (kbd yaa-keybind-switch-to-russian)
		(lambda () (interactive)
		  (set-input-method 'russian-computer)))

(global-set-key (kbd yaa-keybind-switch-to-ukrainian)
		(lambda () (interactive)
		  (set-input-method 'ukrainian-computer)))

(global-set-key (kbd "<f8>") 'typopunct-mode)
(global-set-key (kbd "C-<f8>") 'describe-char)

(global-set-key (kbd "<f9>") 'compile)

(global-set-key (kbd "C-<f11>") 'yaa-toggle-maximize-buffer)

(global-set-key (kbd "<f12>") 'html-mode)

(global-set-key (kbd "C-;") 'set-mark-command)
(global-set-key (kbd "C-M-;") 'mark-sexp)

;; (global-set-key "\C-c\C-w" 'clipboard-kill-region)
;; (global-set-key "\C-c\M-w" 'clipboard-kill-ring-save)
;; (global-set-key "\C-c\C-y" 'clipboard-yank)

(keyboard-translate ?\C-h ?\C-?)
;; (define-key key-translation-map [?\C-h] [?\C-?])

(global-set-key (kbd "C-?") 'help-command)
;; (global-set-key (kbd "M-?") 'mark-paragraph)
;; (global-set-key (kbd "C-h") 'delete-backward-char)
;; (global-set-key (kbd "M-h") 'backward-kill-word)

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-switchb)

(ffap-bindings)

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; --------------------

(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
(add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

;; --------------------

(setq dired-dwim-target t)

(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "^")
              (lambda () (interactive) (find-alternate-file "..")))
            ))

(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")
            ;; Set dired-x global variables here.  For example:
            ;; (setq dired-guess-shell-gnutar "gtar")
            ;; (setq dired-x-hands-off-my-keys nil)
            ))

(add-hook 'dired-mode-hook
          (lambda ()
            ;; Set dired-x buffer-local variables here.  For example:
            (dired-omit-mode 1)
            ))

(autoload 'dired-jump "dired-x"
  "Jump to Dired buffer corresponding to current buffer." t)

(autoload 'dired-jump-other-window "dired-x"
  "Like \\[dired-jump] (dired-jump) but in other window." t)

(define-key global-map "\C-x\C-j" 'dired-jump)
(define-key global-map "\C-x4\C-j" 'dired-jump-other-window)

(require 'dired-details)
(dired-details-install)

;; -------------------

(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "C-c C-c h")
              'yaahtml-dired-autohref)))

(add-hook 'html-mode-hook
          (lambda ()
            (define-key html-mode-map (kbd "C-c C-c h")
              'yaahtml-wrap-autohref)
            (define-key html-mode-map (kbd "C-c C-c w")
              'yaahtml-wrap-with-tags)
            (define-key html-mode-map (kbd "C-c C-c x")
              (lambda () (interactive) (yaahtml-wrap-with-tags "nolink")))
            (define-key html-mode-map (kbd "C-c C-c e")
              (lambda () (interactive) (yaahtml-wrap-with-tags "em")))
            (define-key html-mode-map (kbd "C-c C-c s")
              (lambda () (interactive) (yaahtml-wrap-with-tags "strong")))
            (define-key html-mode-map (kbd "C-c C-c f")
              (lambda () (interactive) (yaahtml-wrap-with-tags "strong" "em")))
            (define-key html-mode-map (kbd "C-c C-c d")
              (lambda () (interactive) (yaahtml-wrap-with-tags "td")))
            (define-key html-mode-map (kbd "C-c C-c a")
              'yaahtml-wrap-url)
            (define-key html-mode-map (kbd "C-c C-c C-c")
              (lambda () (interactive) (yaahtml-wrap-logical-line-with-tag "p")))
            (define-key html-mode-map (kbd "C-c C-c C-d")
              (lambda () (interactive) (yaahtml-wrap-logical-line-with-tag "td")))
            (define-key html-mode-map (kbd "C-c C-c C-l")
              (lambda () (interactive) (yaahtml-wrap-logical-line-with-tag "li")))
            ))

;; -------------------

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'after-init-hook 'company-statistics-mode)
(add-to-list 'company-backends 'company-elisp)
(add-to-list 'company-backends 'company-c-headers)
(require 'company-c-headers)
(add-to-list 'company-c-headers-path-system "/usr/include/c++/6/")
(mapc (lambda (mode-hook) (add-hook mode-hook 'company-mode))
      '(c-mode-hook cc-mode-hook c++-mode-hook))
;; (setq company-ispell-available t)
;; (setq company-ispell-dictionary (file-truename "~/.emacs.d/ispell-dictionary.txt"))
;; (add-to-list 'company-backends 'company-ispell)

;; -------------------

(require 'icicles)
(icy-mode 1)

;; -------------------

(require 'yasnippet)
(yas-global-mode 1)

;; -------------------

(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))

;; -------------------

(autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
(autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot-mode" t)

(setq auto-mode-alist (append '(("\\.plt$" . gnuplot-mode))
                              auto-mode-alist))
(setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode))
                              auto-mode-alist))

;; -------------------

(require 'visual-indentation-mode)
(mapc (lambda (mode-hook) (add-hook mode-hook 'visual-indentation-mode))
      '(c-mode-common-hook tcl-mode-hook emacs-lisp-mode-hook
                           ruby-mode-hook java-mode-hook haskell-mode-hook
                           ess-mode-hook python-mode-hook sh-mode-hook))
;;(add-hook 'prog-mode-hook 'visual-indentation-mode)

;; -------------------

(require 'openwith)
(openwith-mode t)
(setq openwith-associations
      '(
        ("\\.pdf\\'" "okular" (file))
        ("\\.djvu\\'" "okular" (file))
        ("\\.\\(?:jp?g\\|png\\|gif\\)\\'" "gpicview" (file))
        ("\\.mp3\\'" "smplayer" (file))
        ("\\.\\(?:mpe?g\\|avi\\|wmv\\)\\'" "mplayer" ("-idx" file))
        ))

;; ------------------------------

;;(require 'desktop-menu)
;;(require 'desktop-frame)

;; ------------------------------

(require 'paren)
(show-paren-mode 1)

(electric-pair-mode 1)

(require 'clean-aindent-mode)
(define-key global-map (kbd "RET") 'newline-and-indent)
;; (add-hook 'prog-mode-hook 'clean-aindent-mode)

;; ------------------------------

(setq c-default-style "linux"
      c-basic-offset 2)

;;(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)
(c-set-offset 'innamespace 0)

(setq auto-mode-alist (append '(("\\.ctt$" . c++-mode))
                              auto-mode-alist))
(setq auto-mode-alist (append '(("\\.h$" . c++-mode))
                              auto-mode-alist))

;; ------------------------------

(add-hook 'before-save-hook 'copyright-update)

;; -------------------------------

(require 'whitespace)
(setq-default show-trailing-whitespace t)
(defun disable-showing-trailing-whitespace ()
  (setq show-trailing-whitespace nil))
(mapc (lambda (mode-hook) (add-hook mode-hook 'disable-showing-trailing-whitespace))
      '(w3m-mode-hook eww-mode-hook term-mode-hook eshell-mode-hook
                      compilation-mode-hook completion-list-mode-hook))

;; --------------------

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;; --------------------

(require 'typopunct)
(typopunct-change-language 'russian t)

(defalias 'tpm 'typopunct-mode)

;; --------------------

(require 'xah-replace-pairs)

;; --------------------

(require 'info)

(defun info-mode ()
  (interactive)
  (let ((file-name (buffer-file-name)))
    (kill-buffer (current-buffer))
    (info file-name)))
(add-to-list 'auto-mode-alist '("\\.info\\'" . info-mode))

;; --------------------

;;;;(setq w32-use-visible-system-caret nil)

;; (setq w3m-command-arguments
;;       (nconc w3m-command-arguments
;;              '("-o" "http_proxy=http://proxy:8000/")))

;;(require 'magit)

;; ------------------------------

(defalias 'edb 'ediff-buffers)
(defalias 'edf 'ediff-files)
(defalias 'edd 'ediff-directories)

;; --------------------

(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;; --------------------

(yaa-toggle-fullscreen)
