;;; js2r-es6.el --- An extension to js2-refactor with ES6 features  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Jakob Lind

;; Author: Jakob Lind <karl.jakob.lind@gmail.com>
;; URL: https://github.com/jakoblind/js2r-es6
;; Package-Requires: ((js2-refactor "0.8.0"))
;; Version: 1.0
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defun js2r--var-init-node (from-node)
  (let* ((var-init-node (js2r--closest 'js2-var-init-node-p)))
    (if var-init-node var-init-node (first (js2r--var-init-node-decendants from-node)))))

(defun js2r--import-node (from-node)
  (let* ((import-node (js2r--closest 'js2-import-node-p)))
    (if import-node import-node (first (js2r--import-node-decendants from-node)))))

(defun js2r--call-node (var-init)
  (let* ((call-node (js2r--closest 'js2-call-node-p)))
    (if call-node call-node (first (js2r--call-node-decendants var-init)))))

(defun js2r--call-node-decendants (node)
  (-select #'js2-call-node-p (js2r--decendants node)))

(defun js2r--import-node-decendants (node)
  (-select #'js2-import-node-p (js2r--decendants node)))

(defun js2r--from-clause-node-decendants (node)
  (-select #'js2-from-clause-node-p (js2r--decendants node)))

(defun js2r--import-clause-node-decendants (node)
  (-select #'js2-import-clause-node-p (js2r--decendants node)))

(defun js2r--from-clause-node-metadata-decendants (node)
  (-select #'js2-import-clause-node-metadata-p (js2r--decendants node)))

(defun js2r--export-binding-node-decendants (node)
  (-select #'js2-export-binding-node-p (js2r--decendants node)))

(defun js2r-require-to-import ()
   (interactive)
   (js2r--guard)
   (let* ((var-init-node (js2r--var-init-node (js2-node-at-point))))
     (unless var-init-node
       (error "No variable found"))
     (let* ((var-name (js2-name-node-name (js2-var-init-node-target var-init-node)))
            (call-node (js2r--call-node var-init-node)))
       (unless (and call-node (string= (js2-name-node-name (js2-call-node-target call-node)) "require"))
         (error "No require statement found"))
       (let* ((call-node-name (js2-node-string (first (js2-call-node-args call-node))))
              (stmt (js2-node-parent-stmt var-init-node))
              (beg (js2-node-abs-pos stmt)))
         (goto-char beg)
         (delete-char (js2-node-len stmt))
         (insert "import " var-name  " from " call-node-name ";")))))

 (defun js2r-import-to-require ()
   (interactive)
   (js2r--guard)
   (let* ((import-node (js2r--import-node (js2-node-at-point))))
     (unless import-node
       (error "No import statement found"))
     (let* ((from-clause (js2r--from-clause-node-decendants import-node))
            (import-clause (js2r--import-clause-node-decendants import-node))
            (from-string (js2-from-clause-node-module-id (first from-clause)))
            (binding-node (js2r--export-binding-node-decendants (first import-clause)))
            (var-name (js2-name-node-name (js2-export-binding-node-local-name (first binding-node))))
            (beg (js2-node-abs-pos import-node)))
       (goto-char beg)
       (delete-char (js2-node-len import-node))
       (insert "var " var-name  " = require(\"" from-string "\");"))))

(defun js2r--add-keybindings (key-fn)
  "Add js2r refactoring keybindings to `js2-mode-map' using KEY-FN to create each keybinding."
  ;; The old keys defined in js2-refactor
  (define-key js2-refactor-mode-map (funcall key-fn "eo") 'js2r-expand-object)
  (define-key js2-refactor-mode-map (funcall key-fn "co") 'js2r-contract-object)
  (define-key js2-refactor-mode-map (funcall key-fn "eu") 'js2r-expand-function)
  (define-key js2-refactor-mode-map (funcall key-fn "cu") 'js2r-contract-function)
  (define-key js2-refactor-mode-map (funcall key-fn "ea") 'js2r-expand-array)
  (define-key js2-refactor-mode-map (funcall key-fn "ca") 'js2r-contract-array)
  (define-key js2-refactor-mode-map (funcall key-fn "wi") 'js2r-wrap-buffer-in-iife)
  (define-key js2-refactor-mode-map (funcall key-fn "ig") 'js2r-inject-global-in-iife)
  (define-key js2-refactor-mode-map (funcall key-fn "ev") 'js2r-extract-var)
  (define-key js2-refactor-mode-map (funcall key-fn "iv") 'js2r-inline-var)
  (define-key js2-refactor-mode-map (funcall key-fn "rv") 'js2r-rename-var)
  (define-key js2-refactor-mode-map (funcall key-fn "vt") 'js2r-var-to-this)
  (define-key js2-refactor-mode-map (funcall key-fn "ag") 'js2r-add-to-globals-annotation)
  (define-key js2-refactor-mode-map (funcall key-fn "sv") 'js2r-split-var-declaration)
  (define-key js2-refactor-mode-map (funcall key-fn "ss") 'js2r-split-string)
  (define-key js2-refactor-mode-map (funcall key-fn "ef") 'js2r-extract-function)
  (define-key js2-refactor-mode-map (funcall key-fn "em") 'js2r-extract-method)
  (define-key js2-refactor-mode-map (funcall key-fn "ip") 'js2r-introduce-parameter)
  (define-key js2-refactor-mode-map (funcall key-fn "lp") 'js2r-localize-parameter)
  (define-key js2-refactor-mode-map (funcall key-fn "tf") 'js2r-toggle-function-expression-and-declaration)
  (define-key js2-refactor-mode-map (funcall key-fn "ao") 'js2r-arguments-to-object)
  (define-key js2-refactor-mode-map (funcall key-fn "uw") 'js2r-unwrap)
  (define-key js2-refactor-mode-map (funcall key-fn "wl") 'js2r-wrap-in-for-loop)
  (define-key js2-refactor-mode-map (funcall key-fn "3i") 'js2r-ternary-to-if)
  (define-key js2-refactor-mode-map (funcall key-fn "lt") 'js2r-log-this)
  (define-key js2-refactor-mode-map (funcall key-fn "dt") 'js2r-debug-this)
  (define-key js2-refactor-mode-map (funcall key-fn "sl") 'js2r-forward-slurp)
  (define-key js2-refactor-mode-map (funcall key-fn "ba") 'js2r-forward-barf)
  (define-key js2-refactor-mode-map (funcall key-fn "k") 'js2r-kill)
  (define-key js2-refactor-mode-map (funcall key-fn "ri") 'js2r-require-to-import)
  (define-key js2-refactor-mode-map (funcall key-fn "ir") 'js2r-import-to-require)
  (define-key js2-refactor-mode-map (kbd "<C-S-down>") 'js2r-move-line-down)
  (define-key js2-refactor-mode-map (kbd "<C-S-up>") 'js2r-move-line-up)
  ;; New keys defined in this package
  (define-key js2-refactor-mode-map (funcall key-fn "ri") 'js2r-require-to-import)
  (define-key js2-refactor-mode-map (funcall key-fn "ir") 'js2r-import-to-require))

(provide 'js2r-es6)
;;; js2r-es6.el ends here
