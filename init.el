;; Set window size to a sensable default
(add-to-list 'default-frame-alist '(height . 36))
(add-to-list 'default-frame-alist '(width . 124))

;; Very important!!! In some systems the encoding can fuck up.
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Set Default font for all frames
;; (add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))
;; Beware of height
(set-face-attribute 'default nil :font "JetBrains Mono-11")
(set-face-font 'fixed-pitch "Ubuntu-11" t)
(set-face-font 'variable-pitch "Ubuntu-11" t)

(setq-default
 inhibit-startup-message t
 visual-bell t
 ring-bell-function 'ignore
 read-process-output-max (* 3 1024 1024)
 indent-tabs-mode nil
 vc-follow-symlinks t)

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)

;; Configure use-package to use straight.el by default
(use-package straight
  :custom (straight-use-package-by-default t))

;; Change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
(setq user-emacs-directory (expand-file-name "~/.local/share/emacs/")
      url-history-file (expand-file-name "url/history" user-emacs-directory))

;; Use no-littering to automatically set common paths to the new user-emacs-directory
(use-package no-littering)
(use-package diminish)
(use-package delight)
(use-package popup)
(use-package gcmh
  :diminish
  :config
  (setq gcmh-idle-delay 5
	gcmh-high-cons-threshold (* 100 1024 1024))
  (gcmh-mode 1))

;; Inherit environment variables from Shell.
(when (memq window-system '(mac ns x))
  (use-package exec-path-from-shell
    :config
    (exec-path-from-shell-initialize)))

(use-package bug-hunter)

(use-package restart-emacs)

(use-package free-keys)

;; Keep customization settings in a temporary file (thanks Ambrevar!)
(setq custom-file
      (if (boundp 'server-socket-dir)
          (expand-file-name "custom.el" server-socket-dir)
        (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

;; Sensable Defaults
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq display-line-numbers-type 'relative
      scroll-margin 8
      auto-revert-check-vc-info t
      scroll-step 1
      scroll-conservatively 1000
      scroll-preserve-screen-position 1
      save-interprogram-paste-before-kill t)
(save-place-mode t)
(global-display-line-numbers-mode)
(global-hl-line-mode)
(global-auto-revert-mode 1)
(make-variable-buffer-local 'global-hl-line-mode)
(dolist (mode '(org-mode-hook
		term-mode-hook
		vterm-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda ()
		   (display-line-numbers-mode 0)
		   (global-hl-line-mode 0))))

(add-hook
 'after-make-frame-functions
 (defun setup-blah-keys (frame)
   (with-selected-frame frame
     (when (display-graphic-p)
       (define-key input-decode-map (kbd "C-i") [C-i])
       (define-key input-decode-map (kbd "C-[") [C-lsb])
       (define-key input-decode-map (kbd "C-m") [C-m])))))

(use-package files
  :straight nil
  :custom
  (backup-directory-alist '(("." . "~/.emacs.d/backups")))
  (backup-by-copying t)               ; Always use copying to create backup files
  (delete-old-versions t)             ; Delete excess backup versions
  (kept-new-versions 6)               ; Number of newest versions to keep when a new backup is made
  (kept-old-versions 2)               ; Number of oldest versions to keep when a new backup is made
  (version-control t)                 ; Make numeric backup versions unconditionally
  (auto-save-default nil)             ; Stop creating #autosave# files
  (mode-require-final-newline nil)    ; Don't add newlines at the end of files
  (large-file-warning-threshold nil)) ; Open large files without requesting confirmation

(use-package dired
  :straight (:type built-in)
  :custom
  (dired-kill-when-opening-new-dired-buffer t))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key [f5] 'revert-buffer)

(use-package undo-tree
  :diminish
  :init
  (global-undo-tree-mode))

(use-package hydra)

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("=" text-scale-increase "in")
  ("-" text-scale-decrease "out")
  ("0" text-scale-adjust "reset"))

(use-package rainbow-delimiters
  :hook prog-mode)

;; Tree-sitter for faster and efficient language parsing and highlighting.
(use-package tree-sitter
  :delight " TS"
  :config
  (global-tree-sitter-mode)
  (use-package ts-fold
    :diminish
    :straight (ts-fold :type git :host github :repo "emacs-tree-sitter/ts-fold")))

(use-package tree-sitter-langs)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

(use-package all-the-icons)

;; Vertico for better completion
(straight-use-package '( vertico :files (:defaults "extensions/*")
                         :includes (vertico-buffer
                                    vertico-directory
                                    vertico-flat
                                    vertico-indexed
                                    vertico-mouse
                                    vertico-quick
                                    vertico-repeat
                                    vertico-reverse)))
(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;;(setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  :config
  (use-package vertico-mouse
    :config
    (vertico-mouse-mode)))
;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package vertico-directory)

;; Orderless
(use-package orderless
  :custom
  (completion-styles '(basic partial-completion orderless))
  (orderless-matching-styles '(orderless-literal orderless-flex orderless-regexp)))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Either bind `marginalia-cycle' globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
	 ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package embark
  :bind
  (("C-," . embark-act)
   ("C-M-," . embark-dwim)
   ("<f1> B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package zenburn-theme)

(use-package afternoon-theme)

(use-package dracula-theme)

(use-package ef-themes)

(use-package lambda-themes
  :straight (:type git :host github :repo "lambda-emacs/lambda-themes")
  :custom
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t)
  (lambda-themes-set-variable-pitch t))

(use-package doom-themes)

;; Load Themes
;; (add-to-list 'custom-theme-load-path (concat user-emacs-directory "themes"))

(defadvice load-theme (before clear-previous-themes activate)
  "Clear existing theme settings instead of layering them."
  (mapc #'disable-theme custom-enabled-themes))
(use-package emacs
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
	modus-themes-subtle-line-numbers t
        modus-themes-region '(bg-only no-extend)
	modus-themes-mode-line '(accented borderless)
	;; modus-themes-hl-line '(accented)
	modus-themes-parens-match '(bold intense)
	tab-always-indent 'complete)

  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  :config
  ;; Load the theme of your choice:
  (load-theme 'doom-zenburn t))
  
(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))


;; Display available keys.
(use-package which-key
  :diminish
  :config
  (which-key-mode))

(use-package eldoc
  :diminish)

(use-package treemacs)

(use-package wgrep)
(use-package bookmark-view)

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
	 ("<help> t" . consult-theme)             ;; orig. help-with-tutorial
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
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

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   :preview-key (kbd "M-."))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  )
(use-package consult-flycheck)
(use-package consult-projectile)

(use-package eglot
  :bind (("C-c l e" . eglot)
         :map eglot-mode-map
         ("C-c l r" . eglot-rename)
         ("C-c l a" . eglot-code-actions)
         ("C-c l f" . eglot-format))
  :custom
  (eglot-autoshutdown t)
  :init
  (which-key-add-key-based-replacements "C-c l" "eglot")
  :config
  (setcdr (assq 'java-mode eglot-server-programs)
          `("jdtls" "-data" "/home/pr09eek/.cache/emacs/workspace/"
	    "-Declipse.application=org.eclipse.jdt.ls.core.id1"
	"-Dosgi.bundles.defaultStartLevel=4"
	"-Declipse.product=org.eclipse.jdt.ls.core.product"
	"-Dlog.level=ALL"
	"-noverify"
	"-Xmx1G"
	"--add-modules=ALL-SYSTEM"
	"--add-opens java.base/java.util=ALL-UNNAMED"
	"--add-opens java.base/java.lang=ALL-UNNAMED"
	"-jar ./plugins/org.eclipse.equinox.launcher_1.5.200.v20180922-1751.jar"
	"-configuration ./config_linux")))

(use-package consult-eglot
  :after (eglot consult))

;; (use-package lsp-mode
;;   :custom
;;   (lsp-completion-provider :none) ;; we use Corfu!
;;   (lsp-file-watch-threshold 100000)
;;   (lsp-keymap-prefix "C-c l")
;;   :init
;;   (setq lsp-idle-delay 0)
;;   (defun my/lsp-mode-setup-completion ()
;;     (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
;;           '(orderless))) ;; Configure orderless
;;   :hook
;;   (lsp-completion-mode . my/lsp-mode-setup-completion)
;;   :commands (lsp lsp-deferred)
;;   :config
;;   (dolist (mode '(c-mode-hook
;; 		  c++-mode-hook
;; 		  js2-mode
;; 		  rjsx-mode
;; 		  js-mode))
;;     (add-hook mode 'lsp-deferred))
;;   (use-package consult-lsp)
;;   (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

;; (use-package dap-mode)

;; (use-package lsp-ui
;;   :after lsp-mode
;;   :custom
;;   (lsp-ui-doc-enable nil)
;;   (lsp-ui-peek-enable nil)
;;   (lsp-headerline-breadcrumb-enable nil))

;; (use-package lsp-java
;;   :hook (java-mode . lsp-deferred))

;; (use-package lsp-pyright
;;   :ensure t
;;   :init
;;   (advice-add 'lsp :before (lambda (&rest _args) (eval '(setf (lsp-session-server-id->folders (lsp-session)) (ht)))))
;;   (setq lsp-pyright-multi-root nil)
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-pyright)
;;                           (lsp-deferred))))  ; or lsp

(use-package pyvenv
  :hook python-mode)

(use-package rjsx-mode
  :mode "\\.[mc]?js")

(use-package yaml-mode)

(use-package fish-mode)

;; (use-package lsp-treemacs)

(use-package flymake
  :config
  (defhydra flymake-map (flymake-mode-map "C-c f")
    "flymake"
    ("n" flymake-goto-next-error "next-error")
    ("p" flymake-goto-prev-error "prev-error")
    ("f" flymake-show-buffer-diagnostics "buffer diagnostics"))
  :hook (prog-mode . flymake-mode))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 1)
  (corfu-separator ?\s)          ;; Orderless field separator
  (corfu-quit-at-boundary t)   ;; Never quit at completion boundary
  (corfu-quit-no-match 'separator)      ;; Never quit, even if there is no match
  (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
  (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (global-corfu-mode))

;; Add extensions
(use-package cape
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-ispell)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package vterm
  :config
  (setq vterm-kill-buffer-on-exit t
	vterm-max-scrollback 5000))

(use-package projectile
  :bind ("C-x p" . projectile-command-map)
  :custom
  (projectile-project-search-path '(("~/Projects/" . 1)))
  :config
  (projectile-global-mode 1))

(use-package ibuffer
  :config
  (define-ibuffer-column size
    (:name "Size"
     :inline t
     :header-mouse-map ibuffer-size-header-map)
    (file-size-human-readable (buffer-size))))

(use-package ibuffer-projectile
  :hook (ibuffer . ibuffer-projectile-set-filter-groups))

(use-package magit
  :config
  (magit-auto-revert-mode t))

(use-package smartparens
  :diminish
  :config
  (sp-use-smartparens-bindings)
  (smartparens-global-mode))

(use-package avy
  :bind ("M-j" . avy-goto-char-timer)
  :custom
  (avy-timeout-seconds 0.5))

(use-package git-gutter
  :diminish
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe)

;; (use-package discover
;;   :config
;;   (global-discover-mode 1))

(use-package org
  :mode ("\\.org$" . org-mode))

(setq gc-cons-threshold (* 1 1024 1024))

;; Utility functions

;; need to improve this
(defun copy-line (arg)
"Copy lines (as many as prefix argument) in the kill ring.
  Ease of use features:
    - Move to start of next line.
    - Appends the copy on sequential calls.
    - Use newline as last char even on the last line of the buffer.
    - If region is active, copy its lines."
  (interactive "p")
  (let ((beg (line-beginning-position))
        (end (line-end-position arg)))
    (when mark-active
      (if (> (point) (mark))
          (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
        (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
    (if (eq last-command 'copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-ring-save beg end)))
  (kill-append "\n" nil)
  (beginning-of-line (or (and arg (1+ arg)) 2))
  (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))