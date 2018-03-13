;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generic
;; it turns on some capabilities of cdlatex
(add-hook 'org-mode-hook 'turn-on-org-cdlatex)
;; it turns on visual-line-mode
(add-hook 'org-mode-hook 'visual-line-mode)
;; cut, copy, paste with common keys (C-x) (C-c) (C-v)
(cua-mode t)
;; org coding
(modify-coding-system-alist 'file "\\.org\\'" 'utf-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theme
(load-theme 'leuven t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org

(require 'org)
(require 'org-id)

 ; for org-mode-remap: link : [[org-mode-remap]]
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
 ; http://orgmode.org/manual/Using-links-outside-Org.html#Using-links-outside-Org
(global-set-key "\C-cL" 'org-insert-link-global)
(global-set-key "\C-co" 'org-open-at-point-global)
(global-set-key "\C-cO" 'org-mark-ring-goto)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pakages

;; examples: http://www.gnu.org/software/emacs/manual/html_node/emacs/Init-Examples.html#Init-Examples


;; Archives from which to fetch.
(require 'package)
;; (add-to-list 'package-archives
;;              '("elpy" . "http://jorgenschaefer.github.io/packages/")
;; )


;; https://www.emacswiki.org/emacs/InstallingPackages

(setq package-archives
      (append '(
		("melpa" . "http://melpa.milkbox.net/packages/")
		("elpy" . "http://jorgenschaefer.github.io/packages/")
		)
	      package-archives))

(defun check-pkg ( pkg )
  (progn
    (when (not (require (intern pkg) nil 'noerror))
      (package-install (intern pkg))
      )
    )
  )

;; messa anche nell'hook, da togliera da una delle 2 parti
(defun check-mylist-of-pkgs ()
  ;; (interactive "")  (check-pkg "org" )
  (check-pkg "yaml-mode")
  (check-pkg "iedit")
  (check-pkg "folding") 
  )

;; HOOKS

;;This normal hook is run, once, just after handling the command line arguments. In batch mode, Emacs does not run this hook. 
(add-hook 'emacs-startup-hook
	  '(lambda ()
	     (check-mylist-of-pkgs)
	     (progn
	       ;; ;; la funzione va, ma no nel .emacs
	       ;; (when (require 'elpy nil 'noerror)
	       ;; 	 (message "elpy akiro")
	       ;; 	 )
	       (when (require 'elpy nil 'noerror)
		 ;; (package-initialize)
		 ;; (elpy-enable)
		 ;; ;; if ipython
		 ;; (elpy-use-ipython)
		 )
	       ;; yasnippet
	       (require 'yasnippet)
	       (yas/initialize)
	       (yas/load-directory "/home/akiro/.emacs.d/snippets")
	       )))

