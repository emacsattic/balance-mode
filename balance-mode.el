;; balance-mode.el
;;

;; This file provides the package named ``balance-mode''.  When
;; compiled, if it contains macros, it should require itself to be
;; loaded before the program is compiled, thus the following require
;; statement.

(provide 'balance-mode)
(require 'balance-mode)

;; In defining a minor mode, we first define a variable with the name
;; of the mode.  When the variable is true, the mode will be active.
;; We make this variable ``buffer-local'' (emacs' sad attempt at
;; modularity) so that separate buffers can have separate balance-mode
;; states.

(defvar balance-mode nil)
(make-variable-buffer-local 'balance-mode)

;; The procedure ``balance-mode'' only sets or toggles the truth value
;; of the balance-mode variable.

(defun balance-mode (&optional arg)
  "Makes the ``['' and ``('' keys insert both opening and closing
characters, and the ``]'' and ``)'' keys move to the nearest 
closing character.  Meta-[, Meta-], Meta-( and Meta-) are rebound
to simply insert the appropriate characters."
  (interactive "P")
  (if (null arg)
      (setq balance-mode (not balance-mode))
    (setq balance-mode (> (prefix-numeric-value arg) 0))))

;; The procedure ``turn-on-balance-mode'' is supplied for easy use in
;; .emacs files.

(defun turn-on-balance-mode ()
  "Turns on balance mode.  See documentation for the command
``balance-mode'' for further information."
  (interactive)
  (balance-mode t))

;; As a minor mode, balance-mode gets its own sparse keymap which
;; shadows other keymaps active in the current buffer.  

(defvar balance-mode-keymap (make-sparse-keymap))

;; If we've already loaded this file, we don't screw around with
;; top-level values.  Otherwise, we add the balance-mode name to the
;; minor-mode-alist and the keymap to the minor-mode-map-alist.

(or (assq 'balance-mode minor-mode-alist)
    (setq minor-mode-alist
	  (cons '(balance-mode " Balance") minor-mode-alist)))

(or (assq 'balance-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (cons (cons 'balance-mode balance-mode-keymap) 
		minor-mode-map-alist)))

;; The main function of balance-mode is to redefine the various keys.
;; The following four key assignments handle setting Esc-<key> to be
;; the normal inserting command.

(define-key balance-mode-keymap "\M-(" 
  (function (lambda ()
	      "Inserts a left paren."
	      (interactive) (insert ?\())))
(define-key balance-mode-keymap "\M-[" 
  (function (lambda () 
	      "Inserts a left square bracket"
	      (interactive) (insert ?\[))))
(define-key balance-mode-keymap "\M-)" 
  (function (lambda () 
	      "Inserts a right parenthesis"
	      (interactive) (insert ?\)) (blink-matching-open))))
(define-key balance-mode-keymap "\M-]" 
  (function (lambda () 
	      "Inserts a right square bracket"
	      (interactive) (insert ?\]) (blink-matching-open))))

;; And these four define the <key>s to be their new, balancing,
;; commands.

(define-key balance-mode-keymap "(" 'insert-parentheses)
(define-key balance-mode-keymap ")" 'move-past-close)
(define-key balance-mode-keymap "[" 'insert-square-brackets)
(define-key balance-mode-keymap "]" 'move-past-close)

;; the backspace issue is tricky, since some people redefine C-h to be
;; backspacing.  

(define-key balance-mode-keymap "\C-?" 'backward-delete-paren)

(if (eq (key-binding "\C-h") 'backward-delete-char-untabify)
    (define-key balance-mode-keymap "\C-h" 'backward-delete-paren))

;; Lastly, a few functions needed to be defined.
;; ``insert-parentheses'' and ``insert-square-brackets'' are
;; essentially the same commands, but since emacs has dynamic scope,
;; no nice abstraction was possible.

(defun move-past-close ()
  "Just move past the next closing paren, don't reindent."
  (interactive)
  (up-list 1)
  (blink-matching-open))

(defun insert-parentheses (arg)
  "Put parens around next ARG sexps."
  (interactive "P")
  (let ((arg (if arg (prefix-numeric-value arg) 0)))
    (or (zerop arg) (skip-chars-forward " \t"))
    (insert ?\()
    (save-excursion
      (or (zerop arg) (forward-sexp arg))
      (insert ?\)))))

(defun insert-square-brackets (arg)
  "Put square brackets around next ARG sexps."
  (interactive "P")
  (let ((arg (if arg (prefix-numeric-value arg) 0)))
    (or (zerop arg) (skip-chars-forward " \t"))
    (insert ?\[)
    (save-excursion
      (or (zerop arg) (forward-sexp arg))
      (insert ?\]))))

;; backward-delete-paren moves over right-parens and only deletes
;; parens in empty pairs.

(defun backward-delete-paren (arg)
  "Delete a paren pair if we're in the right place, else error.
With an argument, don't error, just delete the paren."
  (interactive "P")
  (if arg
      (backward-delete-char-untabify 1)
    (if (member (char-after (- (point) 1)) '(?\( ?\[))
	(if (not (member (char-after (point)) '(?\) ?\])))
	    (error "Can't touch this")
	  (backward-char 1)
	  (delete-char 2))
      (if (member (char-after (- (point) 1)) '(?\) ?\]))
	  (backward-char 1)
	(backward-delete-char-untabify 1)))))

;; ---- end balance-mode.el
