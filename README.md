# js2r-es6
An extension to [js2-refactor](https://github.com/magnars/js2-refactor.el) with ES6 features. 

## Introduction
These are ES6 specific refactorings which are not suited for the original `js2-refactor` package.

## Installation
Require `js2r-es6` right after the the `js2-refactor` require, like this:

```
(require 'js2-refactor)
(require 'js2r-es6) ;; The require should be at this point
(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-m")
```

## New refactorings
In addition to js2-refactor refactorings, these ES6 specific refactorings exists (more to come!): 

* `ri` is `js2r-require-to-import`: Convert a require statement to an import statement
* `ir` is `js2r-import-to-require`: Convert an import statement to a require statement


