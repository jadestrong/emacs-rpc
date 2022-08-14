;;; demo-backend.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 JadeStrong
;;
;; Author: JadeStrong <jadestrong@163.com>
;; Maintainer: JadeStrong <jadestrong@163.com>
;; Created: August 13, 2022
;; Modified: August 13, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/jadestrong/demo-backend
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:
(require 'cl-lib)
(require 'company)
(require 'epc)
(require 'lsp-mode)

(defvar demo-backend-epc nil "Company epc.")
(defvar demo-backend--callback nil "Company callback to return candidates to.")

(setq demo-backend-epc (epc:start-epc "node" '("echo.js")))

(defun demo-backend--find-candidates (arg)
  "Find candidates by (as ARG)."
  (message "find args %s" arg)
  (let* ((cands (epc:call-sync demo-backend-epc 'calc "a"))
         (return-cands (cl-remove-if-not
                        (lambda (c) (string-prefix-p arg c))
                        cands)))
    (funcall demo-backend--callback return-cands)))


(defun demo-backend--get-input-prefix ()
  "Get user input prefix."
  (let ((bound (bounds-of-thing-at-point 'symbol)))
    (if bound
        (buffer-substring-no-properties (car bound) (cdr bound))
      "")))

(defun demo-backend--calculate-column ()
  "Calculate character offset of cursor in current line."
  (/ (- (length (encode-coding-region (line-beginning-position)
                                   (min (point) (point-max)) 'utf-16 t))
        2)
     2))

(defun demo-backend--position ()
  "Get position of cursor."
  (list :line (1- (line-number-at-pos)) :character (demo-backend--calculate-column)))

(defun demo-backend--make-completion-request (prefix)
  "Make request body for completion.
PREFIX is a string prefix given by company-mode.
Returns the request body that can be used by `lsp-send-request' or `lsp-send-request-async'."
  (message "prefix---- %s" (type-of prefix))
  (let ((position (demo-backend--position))
        (filepath (file-truename buffer-file-name)))
    (deferred:$
      (epc:call-deferred demo-backend-epc 'calc (list filepath position prefix))
      (deferred:nextc it
        (lambda (x)
          (message "Return : %S " x)
          (let ((cands (cl-remove-if-not (lambda (c) (string-prefix-p prefix c)) x)))
            (funcall demo-backend--callback cands)))))))

(defun demo-backend--find-candidates-async (prefix)
  "Asyncly find candidate by (as PREFIX)."
  (deferred:$
    (epc:call-deferred demo-backend-epc 'calc "a")
    (deferred:nextc it
      (lambda (x)
        (message "Return : %S " x)
        (let ((cands (cl-remove-if-not (lambda (c) (string-prefix-p prefix c)) x)))
          (funcall demo-backend--callback cands))))))

(defun company-sample-backend (command &optional arg &rest ignored)
  "A sample company backend called COMMAND (as ARG) (as IGNORED)."
  (interactive (list 'interactive))

  (cl-case command
    (interactive (company-begin-backend 'company-sample-backend))
    (prefix (and (eq major-mode 'fundamental-mode)
                 (demo-backend--get-input-prefix)))
    (candidates (cons :async
                      (lambda (callback)
                        (setq demo-backend--callback callback)
                        (demo-backend--make-completion-request arg))))
    ;; (candidates
    ;;  (let ((cands (epc:call-sync demo-backend-epc 'calc "a")))
    ;;    (message "cands %s" cands)
    ;;    (cl-remove-if-not
    ;;     (lambda (c) (string-prefix-p arg c))
    ;;     cands)))
    ))


;; (provide 'demo-backend)
;;; demo-backend.el ends here
