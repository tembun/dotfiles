;; -*- lexical-binding: t; mode: emacs-lisp -*-

;; Simple package manager
;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(defvar pkg/fresh nil)
(defun pkg/update ()
  (when (not pkg/fresh)
    (setq pkg/fresh t)
    (package-refresh-contents)))
(defun pkg/_require (pkg)
  (when (not (package-installed-p pkg))
    (pkg/update)
    (package-install pkg))
  (require pkg))
(defun pkg/require (&rest pkgs)
  (dolist (pkg pkgs)
    (pkg/_require pkg)))

;; Files
;;
;; Put changes done from the editor into a separate file
(setq custom-file "~/.emacs.d/custom.el")
;; Various credentials
(setq auth-sources '("~/.authinfo"))
;; Backups, auto-saves, locks
;;
;; Put backups and auto-saves in ~/emacs.d and lock files - in /tmp.
(setq user-backup-dir (concat user-emacs-directory ".backups"))
(setq backup-directory-alist `((".*" . ,(expand-file-name user-backup-dir))))
(setq backup-by-copying t)
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name user-backup-dir t))))
(setq lock-file-name-transforms '(("\\`/.*/\\([^/]+\\)\\'" "/tmp/\\1" t)))

;; Appearance
;;
;; Remove bells and whistles
(setq inhibit-startup-screen t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(blink-cursor-mode 0)
;; Theme
;;
(pkg/require 'gruber-darker-theme)
(load-theme 'gruber-darker t)
;; (gruber-darker special): make a fringe the same color as the current line
;; number so that it's easier to notice it.
(set-face-attribute 'fringe
		    nil
		    :foreground (face-foreground 'line-number-current-line))
;; Font
;;
(defun font/set ()
  (interactive)
  (set-frame-font
   "-*-terminus-bold-normal-normal-*-18-*-*-*-*-*-iso10646-1"
   nil t))
(add-hook 'emacs-startup-hook #'font/set)
;; Line numbers
;;
;; 'visual is the same as 'relative, but counts visual screen rows - it's more
;; practical for jumping around.
(setq-default display-line-numbers 'visual)
;; Battery
;;
(defun battery/acpiconf-func ()
  (let* ((acpi-out (split-string
		    (replace-regexp-in-string
		     "\t" " " (replace-regexp-in-string
			       ".*:\t+"
			       ""
			       (battery--call-process-to-string
				"acpiconf"
				"-i0")))
		    "\n" t))
	 (battery-life (replace-regexp-in-string "%" "" (nth 18 acpi-out)))
	 (battery-time-raw (nth 19 acpi-out))
	 (battery-time (if (string= battery-time-raw "unknown")
			   ""
			 battery-time-raw)))
    (list (cons ?p battery-life)
	  (cons ?t battery-time))))
(setq-default battery-status-function #'battery/acpiconf-func)
;; <Battery percentage>~<remaining time, if known>
(setq-default battery-mode-line-format "%p~%t")
;; It starts a timer that periodically (60 seconds by default) updates
;; battery-mode-line-string, so that it can be used in modeline.
(display-battery-mode)
;; Mode line
;;
;; Without that the last character of right-aligned screen goes off the screen.
(setq mode-line-right-align-edge 'right-fringe)
(setq-default mode-line-format
	      ;; Writable and read-only indicators
	      '((:eval mode-line-modified)
		" "
		;; A buffer name with it's major mode
		"%b"
		" "
		(:eval (format-mode-line mode-name))
		;; The current version control system state (branch, for Git)
		(vc-mode vc-mode)
		;; Align everything below to the right edge
		mode-line-format-right-align
		battery-mode-line-string
		" "
		;; Current date and time
		(:eval
		 (format-time-string
		  "%a %d %b %H:%M"
		  (current-time)))
		))
;; vc-mode is not very customizable (I confirmed it by looking into sources),
;; so it's just a hacky way to strip the VC backend name (I use nothing but Git)
;; from it.
(setcdr (assq 'vc-mode mode-line-format)
	'((:eval (replace-regexp-in-string "^ Git[\@\:\-]" " " vc-mode))))
;; To make the date and time accurate, update the modeline every second.
(run-with-timer 0 1 #'force-mode-line-update t)

;; Text appearance
;;
;; whitespace-mode
(global-set-key (kbd "C-c C-w") #'whitespace-mode)
;;
;; Highlighting text anchors like XXX, TODO, KLUDGE and so on.
(defface face/text-anchor-urgent
  '((t (:foreground "white"
		    :background "red"
		    :weight bold)))
  "Face for urgent text anchors like XXX, TODO and so on.")
(defface face/text-anchor-info
  '((t (:foreground "black"
		    :background "orange"
		    :weight bold)))
  "Face for info text anchors like NOTE, KLUDGE and so on.")
(defvar vis/hl-text-anchors
  '(("\\<\\(XXX\\|TODO\\|FIXME\\|BUG\\)\\>" 1 'face/text-anchor-urgent prepend)
    ("\\<\\(NOTE\\|HACK\\|KLUDGE\\|WARN\\)\\>" 1 'face/text-anchor-info prepend)))
(define-minor-mode vis/hl-text-anchors-local-mode
  "Highlight text anchors like XXX, TODO, KLUDGE and so on in the buffer."
  :global t
  (if vis/hl-text-anchors-local-mode
      (font-lock-add-keywords nil vis/hl-text-anchors)
    (font-lock-remove-keywords nil vis/hl-text-anchors))
  (when (bound-and-true-p font-lock-mode)
    (if (fboundp 'font-lock-flush)
	(font-lock-flush)
      (with-no-warnings (font-lock-fontify-buffer)))))
(add-hook 'after-change-major-mode-hook #'vis/hl-text-anchors-local-mode)
;; Rainbow mode (display colors by their names or codes)
(pkg/require 'rainbow-mode)
(add-hook 'prog-mode-hook #'rainbow-mode)

;; Text style
;;
;; Indentation
(setq style/tab-width 8)
(setq-default indent-tabs-mode t)
(setq-default tab-width style/tab-width)
(setq style/indent-offset 8)
(setq style/second-indent-offset 4)
(setq-default standard-indent style/indent-offset)
(defun style/setup-indent ()
  (interactive)
  (setq-local indent-tabs-mode t)
  (setq-local tab-width style/tab-width))
;; Auto line wrapping
;;
(auto-fill-mode 1)
(setq-default fill-column 80)
(global-set-key (kbd "C-c f p") #'fill-paragraph)
(add-hook 'after-change-major-mode-hook #'auto-fill-mode)
(setq require-final-newline t)
;; Whitespace cleanup
;;
;; If delete-trailing-whitespace should also delete trailing lines.
(setq delete-trailing-lines t)
(defun style/whitespace-cleanup ()
  (interactive)
  (delete-trailing-whitespace)
  (whitespace-cleanup))
;; Cleanup whitespaces immediately after the buffer is opened and whenever the
;; buffer is saved.
(add-hook 'prog-mode-hook
	  #'(lambda ()
	      (style/whitespace-cleanup)
	      (add-hook 'before-save-hook #'style/whitespace-cleanup)))

;; Navigation
;;
;; dired
(require 'dired)
(require 'wdired)
(pkg/require 'dired-preview)
(setq dired-mode t)
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-listing-switches "-lah")
(global-set-key (kbd "C-x C-d") #'dired)
(setq dired-create-destination-dirs "always")
(setq dired-create-destination-dirs-on-trailing-dirsep t)
(define-key dired-mode-map (kbd "b") #'dired-up-directory)
(define-key dired-mode-map (kbd "V") #'dired-preview-mode)
(setq dired-create-empty-file-in-current-directory t)
(define-key dired-mode-map (kbd "_") #'dired-create-empty-file)
(setq wdired-allow-to-change-permissions 'advanced)
;; Window management
;;
(defun win/func-other (func)
  "Execute the function in other window."
  (other-window-prefix)
  (funcall func))
;; Otherwise window is always considered unsuitable for vertical split (its
;; height is less than 80, which is a default value for this variable) and
;; setting the split-window-preferred-direction will anyway result in the
;; horizontal split.
(setq split-height-threshold 30)
(setq split-window-preferred-direction 'vertical)
(defun win/display-buffer-use-some-window-dwim (buffer alist)
  "If the buffer's major mode, or the mode cdr from alist matches is derived
from the major mode of the current buffer, display the buffer in the same
window; otherwise - display the buffer in some already existing window.
Intended for use in display-buffer-alist."
  (if (or (derived-mode-p (alist-get 'mode alist))
	  (derived-mode-p (buffer-local-value 'major-mode buffer)))
      (display-buffer-same-window buffer (cons '(inhibit-same-window . nil) alist))
    (display-buffer-use-some-window buffer (cons '(inhibit-same-window . t) alist))))
;; Resizing the windows
;;
(global-set-key (kbd "S-M-<left>") #'shrink-window-horizontally)
(global-set-key (kbd "S-M-<right>") #'enlarge-window-horizontally)
(global-set-key (kbd "S-M-<down>") #'shrink-window)
(global-set-key (kbd "S-M-<up>") #'enlarge-window)
;; Scrolling
;;
;; Custom scrolling steps
(setq scroll/step-size 12)
(defun scroll/func-by-step-size (func)
  (funcall func scroll/step-size))
(defun scroll/up ()
  (interactive)
  (scroll/func-by-step-size #'scroll-up))
(defun scroll/down ()
  (interactive)
  (scroll/func-by-step-size #'scroll-down))
(defun scroll/up-other-window ()
  (interactive)
  (scroll/func-by-step-size #'scroll-other-window))
(defun scroll/down-other-window ()
  (interactive)
  (scroll/func-by-step-size #'scroll-other-window-down))
(global-set-key (kbd "C-v") #'scroll/up)
(global-set-key (kbd "M-v") #'scroll/down)
(global-set-key (kbd "C-=") #'scroll/up-other-window)
(global-set-key (kbd "M-=") #'scroll/down-other-window)
;; Regions
;;
(global-set-key (kbd "C-M-=") #'count-words-region)
;; expand-region
;;
(pkg/require 'expand-region)
(global-set-key (kbd "C-M-SPC") #'er/expand-region)
(global-set-key (kbd "M-SPC") #'er/contract-region)
;; Undo/redo
;;
(pkg/require 'undo-tree)
(global-undo-tree-mode 1)
(setq undo-tree-history-directory-alist
      `(("." . ,(concat user-emacs-directory ".undo-tree"))))
(global-set-key (kbd "C-M-/") #'undo-tree-redo)

;; Searching
;;
;; ido mode
(require 'ido)
(pkg/require 'ido-completing-read+)
(ido-mode t)
(ido-everywhere t)
(ido-ubiquitous-mode t)
(setq ido-enable-flex-matching t)
;; smex (ido mode for M-x)
;;
(pkg/require 'smex)
(global-set-key (kbd "M-x") #'smex)
(global-set-key (kbd "M-X") #'smex-major-mode-commands)
;; which-key-mode
(require 'which-key)
(which-key-mode)
;; helm (incremental searching in files)
;;
(pkg/require 'helm)
(setq helm-follow-mode-persistent t)
(global-set-key (kbd "C-x f") #'helm-do-grep-ag)
(global-set-key (kbd "C-x C-x") #'helm-resume)

;; Text editing
;;
(add-hook 'after-change-major-mode-hook
	  #'(lambda()
	      (local-set-key (kbd "DEL") #'delete-backward-char)))
(global-set-key (kbd "C-M-;") #'comment-line)
(global-set-key (kbd "C-<return>") #'default-indent-new-line)
(put 'downcase-region 'disabled nil)
;; Helpers
;;
(defun ed/check-empty-line ()
  (= (line-beginning-position) (line-end-position)))
(defun ed/delete-if-empty-line ()
  (when (ed/check-empty-line)
    (delete-char 1)))
(defun ed/delete-empty-line-after-function (func)
  (funcall func)
  (ed/delete-if-empty-line))
(defun ed/indent-after-function (func)
  (let ((start (point)))
    (funcall func)
    (indent-region start (point))))
;; Duplicating the line
;;
(defun ed/duplicate-current-line ()
  "Duplicate the current line to the bottom"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
	(line (let ((s (thing-at-point 'line t)))
		(if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))
(global-set-key (kbd "M-,") #'ed/duplicate-current-line)
;; Joining the lines
;;
(defun ed/join-lines ()
  "Join all bottom lines with the current one."
  (interactive)
  (next-line)
  (delete-indentation))
(global-set-key (kbd "M-j") #'ed/join-lines)
;; Killing
;;
(defun ed/kill-whole-visual-line ()
  "Kill the whole visual line."
  (interactive)
  (if (ed/check-empty-line)
      (delete-char 1)
      (beginning-of-visual-line)
      (ed/delete-empty-line-after-function #'kill-visual-line)))
(global-set-key (kbd "C-k") #'ed/kill-whole-visual-line)
(global-set-key (kbd "M-k") #'kill-visual-line)
(defun ed/kill-whole-region (start end)
  "Kill the whole region: if the simple killing leaves an empty line - kill it."
  (interactive "r")
  (ed/delete-empty-line-after-function
   #'(lambda ()
       (kill-region start end))))
(global-set-key (kbd "C-w") #'ed/kill-whole-region)
;; Kill-ring
;;
(defun ed/kill-ring-save-dwim ()
  "Save the region (if it's active) or a line into the kill ring."
  (interactive)
  (kill-ring-save
   (line-beginning-position)
   (line-end-position)
   (if mark-active
       (list (region-beginning) (region-end))
     nil)))
(global-set-key (kbd "M-w") #'ed/kill-ring-save-dwim)
;; Yanking
;;
(defun ed/yank-no-newline ()
  "Yank without trailing newline."
  (interactive)
  (ed/delete-empty-line-after-function #'yank))
(defun ed/yank-indent ()
  "Indent the yanked region immediately after yanking.  It allows to copy a
hunk from one indentaion level, paste it into another indentation level and
don't have the formatting messed up."
  (interactive)
  (ed/indent-after-function #'ed/yank-no-newline))
(global-set-key (kbd "C-y") #'ed/yank-indent)
(defun ed/yank-pop-no-newline ()
  (interactive)
  (ed/delete-empty-line-after-function #'yank-pop))
(defun ed/yank-pop-indent ()
  (interactive)
  (ed/indent-after-function #'ed/yank-pop-no-newline))
(global-set-key (kbd "M-y") #'ed/yank-pop-indent)
;; Autocompletion
;;
(pkg/require 'company)
(global-company-mode t)
(setq company-idle-delay nil)
(setq company-frontends
      '(company-pseudo-tooltip-unless-just-one-frontend))
(global-set-key (kbd "M-n") #'company-complete)
;; Snippets
;;
;; yasnippet
(pkg/require 'yasnippet)
(setq yas-snippet-dirs '("~/.emacs.snippets"))
;; Allow nested snippets
(setq yas-triggers-in-field t)
(yas-global-mode 1)
;; multiple-cursors
;;
(pkg/require 'multiple-cursors)
(global-set-key (kbd "C-M-<return>") #'mc/edit-lines)
(global-set-key (kbd "C-M-,") #'mc/mark-previous-like-this)
(global-set-key (kbd "C-M-.") #'mc/mark-next-like-this)

;; Major modes
;;
;; Treesitter setup
(setopt treesit-enabled-modes t)
(setq treesit-auto-install-grammar 'always)
;; C
;;
(defun c/style ()
  (style/setup-indent)
  (setq indent-tabs-mode t)
  (setq-local c-tab-always-indent nil)
  (c-set-style "bsd")
  ;; Use C-c C-s at points of source code so see which c-set-offset is in effect
  ;; for this situation.
  (c-set-offset 'arglist-close style/second-indent-offset)
  (c-set-offset 'arglist-cont-nonempty style/second-indent-offset)
  (c-set-offset 'defun-block-intro style/tab-width)
  (c-set-offset 'inclass style/tab-width)
  (c-set-offset 'knr-argdecl-intro style/tab-width)
  (c-set-offset 'knr-argdecl-intro style/tab-width)
  (c-set-offset 'statement-block-intro style/tab-width)
  (c-set-offset 'statement-case-intro style/tab-width)
  (c-set-offset 'substatement style/tab-width)
  (c-set-offset 'substatement-open style/indent-offset))
(add-hook 'c-mode-hook #'c/style)

;; sh
;;
(defun sh/style ()
  (style/setup-indent)
  (setq-local sh-basic-offset style/tab-width)
  (setq-local sh-indent-for-case-label 0)
  (setq-local sh-indent-for-case-alt '+)
  (setq-local sh-indent-for-continuation '*)
  (setq-local sh-basic-offset style/tab-width))
(defun sh/setup ()
  (setq sh-shell-file "/bin/sh")
  (sh/style))
(add-hook 'bash-ts-mode-hook #'sh/setup)

;; JSON
;;
(defun json/style ()
  (style/setup-indent)
  (setq-local json-ts-mode-indent-offset style/indent-offset))
(add-hook 'json-ts-mode-hook #'json/style)

;; JavaScript
;;
(defun js/style ()
  (style/setup-indent)
  (setq-local js-indent-level style/indent-offset))
(defun js/setup ()
  (js/style))
(add-hook 'js-ts-mode-hook #'js/setup)

;; TypeScript
;;
(add-hook 'typescript-ts-mode-hook #'eglot-ensure)
(defun ts/style ()
  (style/setup-indent)
  (setq-local typescript-ts-mode-indent-offset style/indent-offset))
(defun ts/setup ()
  (ts/style))
(add-hook 'typescript-ts-mode-hook #'ts/setup)

;; Markdown
;;
(custom-set-variables
 '(markdown-command "/usr/local/bin/pandoc"))

;; Magit
;;
(pkg/require 'magit 'magit-ido 'magit-gh 'magit-pre-commit 'forge)
(defun magit/style ()
  (setq-local fill-column 72))
(add-hook 'git-commit-mode-hook #'magit/style)
(define-key magit-status-mode-map (kbd "M-RET") #'forge-checkout-this-pullreq)
(add-to-list 'display-buffer-alist
	     '((derived-mode . magit-status-mode)
	       (display-buffer-full-frame)))

;; Compilation
;;
(add-to-list 'display-buffer-alist
	     '((derived-mode . compilation-mode)
	       (win/display-buffer-use-some-window-dwim)
	       (mode . compilation-mode)))

;; Shell
;;
;; This is needed for bash(1) aliases to be available for {async-}shell-command.
(setenv "BASH_ENV" "~/.bashrc")
(global-set-key (kbd "C-c s s") #'shell)
(global-set-key (kbd "C-x 4 s s") #'(lambda ()
				      (interactive)
				      (win/func-other #'shell)))

;; Shell command
;;
(add-to-list 'display-buffer-alist
	     '((derived-mode . shell-command-mode)
	       nil
	       (post-command-select-window . t)))

;; Terminal
;;
(defun term/bash ()
  (interactive)
  (term "env bash"))
(global-set-key (kbd "C-c t") #'term/bash)

;; Occur
;;
(add-to-list 'display-buffer-alist
	     '((derived-mode . occur-mode)
	       nil
	       (post-command-select-window . t)))

;; Help
;;
(add-to-list 'display-buffer-alist
	     '((derived-mode . help-mode)
	       nil
	       (post-command-select-window . t)))

;; Man
;;
;; Major mode for man pages (Man-mode) is not set at the time the buffer
;; matching condition is evaluated, so we can't use derived-mode condition here
;; - can only match the buffer by the regexp.  That also means that we should
;; provide mode for win/display-buffer-use-some-window-dwim.
(add-to-list 'display-buffer-alist
	     '("\\*Man"
	       (win/display-buffer-use-some-window-dwim)
	       (mode . Man-mode)
	       (post-command-select-window . t)))

;; Buffer menu
;;
(add-to-list 'display-buffer-alist
	     '((derived-mode . Buffer-menu-mode)
	       (win/display-buffer-use-some-window-dwim)
	       (post-command-select-window . t)))

;; Scratch buffer
;;
(global-set-key (kbd "C-c s p") #'scratch-buffer)

;; Minibuffer
;;
(defun minibuffer/focus ()
  "Focus minibuffer window."
  (interactive)
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))
    (error "Minibuffer is not active")))
(global-set-key (kbd "C-c m b") #'minibuffer/focus)
