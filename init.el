;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 100 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

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

(straight-use-package 'use-package)
(eval-when-compile (require 'use-package))

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 20)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

(column-number-mode t)
(global-display-line-numbers-mode -1)

;; Disable line numbers for some modes
(dolist (mode '(prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode t))))

(defun efs/set-font-faces ()
  (message "Setting faces!")
  (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 120)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil :font "JetBrainsMono Nerd Font" :height 120)

  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil :font "JetBrainsMono Nerd Font" :height 120 :weight 'regular))

(if (daemonp)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (setq doom-modeline-icon t)
              (with-selected-frame frame
                (efs/set-font-faces))))
  (efs/set-font-faces))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC")) ;; access leader in insert mode)

(use-package evil
  :init
  (setq evil-want-integration t)

  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(efs/leader-keys
  "f f" '(find-file :wk "find file")
  "f p" '((lambda () (interactive)
            (dired "~/.emacs.d/")) 
          :wk "Open user-emacs-directory in dired")
  "f r" '(counsel-recentf :wk "Find recent files")
  "/" '(comment-line :wk "comment lines"))

(use-package yasnippet-snippets
  :disabled)

(use-package yasnippet
  :config
  (setq yas-snippet-dirs
	`(,(concat (expand-file-name user-emacs-directory) "snippets")
	  ;; yasnippet-snippets-dir
	  ))
  (setq yas-triggers-in-field t)
  (yas-global-mode 1)
  (efs/leader-keys
    :keymaps 'yas-minor-mode-map
    :infix "es"
    "" '(:wk "yasnippet")
    "n" #'yas-new-snippet
    "s" #'yas-insert-snippet
    "v" #'yas-visit-snippet-file))

(general-define-key "M-TAB" 'company-yasnippet)

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(use-package evil-quickscope
  :after evil
  :config
  :hook ((prog-mode . turn-on-evil-quickscope-mode)
	 (LaTeX-mode . turn-on-evil-quickscope-mode)
	 (org-mode . turn-on-evil-quickscope-mode)))

(use-package evil-lion
  :config
  (setq evil-lion-left-align-key (kbd "g a"))
  (setq evil-lion-right-align-key (kbd "g A"))
  (evil-lion-mode))

(defun my/deadgrep-fix-buffer-advice (fun &rest args)
  (let ((buf (apply fun args)))
    (with-current-buffer buf
      (toggle-truncate-lines 1))
    buf))

(use-package deadgrep
  :commands (deadgrep)
  :config
  (advice-add #'deadgrep--buffer :around #'my/deadgrep-fix-buffer-advice))

(use-package ivy
  :config
  (setq ivy-use-virtual-buffers t)
  (ivy-mode))

(use-package counsel
  :after ivy
  :config
  (counsel-mode))

(use-package swiper
  :defer t)

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode 1)
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line))

(use-package ivy-prescient
  :after counsel
  :config
  (ivy-prescient-mode 1)
  (setq ivy-prescient-retain-classic-highlighting t)
  (prescient-persist-mode 1)
  (setq ivy-prescient-sort-commands
        '(:not swiper
               swiper-isearch
               ivy-switch-buffer
               ;; ivy-resume
               ;; ivy--restore-session
               lsp-ivy-workspace-symbol
               dap-switch-stack-frame
               dap-switch-session
               dap-switch-thread
               counsel-grep
               ;; counsel-find-file
               counsel-git-grep
               counsel-rg
               counsel-ag
               counsel-ack
               counsel-fzf
               counsel-pt
               counsel-imenu
               counsel-yank-pop
               counsel-recentf
               counsel-buffer-or-recentf
               proced-filter-interactive
               proced-sort-interactive
               perspective-exwm-switch-perspective
               lsp-execute-code-action
               dired-recent-open))
  ;; Do not use prescient in find-file
  (ivy--alist-set 'ivy-sort-functions-alist #'read-file-name-internal #'ivy-sort-file-function-default))

(defun my/swiper-isearch ()
  (interactive)
  (if current-prefix-arg
      (swiper-all)
    (swiper-isearch)))

(efs/leader-keys
  "p b" '(persp-ivy-switch-buffer :which-key "persp-ivy-switch-buffer")
  "f c" '(counsel-yank-pop :which-key "counsel-yank-pop")
  "c r" '(counsel-rg :which-key "counsel-rg")
  "d" '(deadgrep :which-key "deadgrep")
  "c A" '(counsel-ag :which-key "counsel-ag")
  "i r" '(ivy-resume :which-key "ivy-resume")
  "s" '(my/swiper-isearch :which-key "swiper-isearch"))

(general-define-key
 :states '(insert normal)
 "C-y" '(counsel-yank-pop :which-key "counsel-yank-pop"))

(general-define-key
 :keymaps '(ivy-minibuffer-map swiper-map)
 "M-j" '(ivy-next-line :which-key "ivy-next-line")
 "M-k" '(ivy-previous-line :which-key "ivy-next-line")
 "<C-return>" '(ivy-call :which-key "ivy-call")
 "M-RET" '(ivy-immediate-done :which-key "ivy-immediate-done")
 [escape] '(minibuffer-keyboard-quit))

(use-package company
  :config
  (global-company-mode t)
  (setq company-idle-delay 0.0)
  (setq company-dabbrev-downcase nil)
  (setq company-show-numbers t))

(use-package company-box
  :if (display-graphic-p)
  :after (company)
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-tokyo-night t)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 25)))

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))
(efs/leader-keys
  "SPC" '(counsel-M-x :which-key "Counsel M-x"))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(efs/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(electric-pair-mode 1) ; auto-insert matching bracket
(show-paren-mode 1)    ; turn on paren match highlighting

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package dashboard
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-display-icons-p t)
  (setq dashboard-set-navigator t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo)
  (setq dashboard-startup-banner "~/.emacs.d/art/ascii.txt")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom 
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region))

(global-prettify-symbols-mode t)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(100 . 100))

  ;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(use-package editorconfig
  :config
  (add-to-list 'editorconfig-indentation-alist
	       '(emmet-mode emmet-indentation)))

(recentf-mode 1)
(save-place-mode nil)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package dired-open
   :commands (dired dired-jump)
   :config
   ;; Doesn't work as expected!
   ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
   (setq dired-open-extensions '(("png" . "feh")
                                 ("mkv" . "mpv"))))

(use-package neotree
  :config
  (setq neo-smart-open t
	neo-show-hidden-files t
	neo-window-width 55
	neo-window-fixed-size nil
	inhibit-compacting-font-caches t
	projectile-switch-project-action 'neotree-projectile-action) 
  ;; truncate long file names in neotree
  (add-hook 'neo-after-create-hook
	    #'(lambda (_)
		(with-current-buffer (get-buffer neo-buffer-name)
		  (setq truncate-lines t)
		  (setq word-wrap nil)
		  (make-local-variable 'auto-hscroll-mode)
		  (setq auto-hscroll-mode nil)))))

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
(evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
(evil-define-key 'normal neotree-mode-map (kbd "p") 'neotree-previous-line)
(evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
(evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)

(setq neo-theme (if (display-graphic-p) 'icons 'icons))

(efs/leader-keys
  "t n" '(neotree-toggle :which-key "toggle neotree")
  "e n" '(neotree-enter :which-key "open file/unfold directory"))

(dirvish-override-dired-mode)

(efs/leader-keys
 "b b" '(switch-to-buffer :wk "Switch to buffer")
 "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
 "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
 "b d" '(bookmark-delete :wk "Delete bookmark")
 "b i" '(ibuffer :wk "Ibuffer")
 "b k" '(kill-current-buffer :wk "Kill current buffer")
 "b K" '(kill-some-buffers :wk "Kill multiple buffers")
 "b l" '(list-bookmarks :wk "List bookmarks")
 "b m" '(bookmark-set :wk "Set bookmark")
 "b n" '(next-buffer :wk "Next buffer")
 "b p" '(previous-buffer :wk "Previous buffer")
 "b r" '(revert-buffer :wk "Reload buffer")
 "b R" '(rename-buffer :wk "Rename buffer")
 "b s" '(basic-save-buffer :wk "Save buffer")
 "b S" '(save-some-buffers :wk "Save multiple buffers")
 "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

(efs/leader-keys
  ;; Window splits
  "w q" '(evil-window-delete :wk "Close window")
  "w n" '(evil-window-new :wk "New window")
  "w s" '(evil-window-split :wk "Horizontal split window")
  "w v" '(evil-window-vsplit :wk "Vertical split window")

  "w w" '(evil-window-next :wk "Goto next window")
  ;; Move Windows
  "w H" '(buf-move-left :wk "Buffer move left")
  "w J" '(buf-move-down :wk "Buffer move down")
  "w K" '(buf-move-up :wk "Buffer move up")
  "w L" '(buf-move-right :wk "Buffer move right"))

(general-define-key
 ;; Window motions
 "<C-M-left>" '(evil-window-left :wk "Window left")
 "<C-M-down>" '(evil-window-down :wk "Window down")
 "<C-M-up>" '(evil-window-up :wk "Window up")
 "<C-M-right>" '(evil-window-right :wk "Window right"))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "JetBrainsMono Nerd Font" :weight 'medium :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  (efs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 180
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(add-hook 'org-mode-hook (lambda ()
                           (display-line-numbers-mode -1)
                           (variable-pitch-mode)))

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("li" . "src lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package evil-org
  :hook (org-mode . evil-org-mode)
  :config
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme '(navigation insert textobjects additional calendar todo))))
  (add-to-list 'evil-emacs-state-modes 'org-agenda-mode)
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-alert
  :custom (alert-default-style 'notifications)
  :config
  (setq org-alert-interval 300
        org-alert-notification-title "Org Alert Reminder!")
  (org-alert-enable))

(use-package org-noter
  :after (:any org pdf-tools)
  :config
  (setq org-noter-notes-search-path '("~/Documents/roam")))

(let ((org-super-agenda-groups
       '(;; Each group has an implicit boolean OR operator between its selectors.
         (:name "Today"  ; Optionally specify section name
                :time-grid t  ; Items that appear on the time grid
                :todo "TODAY")  ; Items that have this TODO keyword
         (:name "Important"
                ;; Single arguments given alone
                :tag "bills"
                :priority "A")
         ;; Set order of multiple groups at once
         (:order-multi (2 (:name "Shopping in town"
                                 ;; Boolean AND group matches items that match all subgroups
                                 :and (:tag "shopping" :tag "@town"))
                          (:name "Food-related"
                                 ;; Multiple args given in list with implicit OR
                                 :tag ("food" "dinner"))
                          (:name "Personal"
                                 :habit t
                                 :tag "personal")
                          (:name "Space-related (non-moon-or-planet-related)"
                                 ;; Regexps match case-insensitively on the entire entry
                                 :and (:regexp ("space" "NASA")
                                               ;; Boolean NOT also has implicit OR between selectors
                                               :not (:regexp "moon" :tag "planet")))))
         ;; Groups supply their own section names when none are given
         (:todo "WAITING" :order 8)  ; Set order of this section
         (:todo ("SOMEDAY" "TO-READ" "CHECK" "TO-WATCH" "WATCHING")
                ;; Show this group at the end of the agenda (since it has the
                ;; highest number). If you specified this group last, items
                ;; with these todo keywords that e.g. have priority A would be
                ;; displayed in that group instead, because items are grouped
                ;; out in the order the groups are listed.
                :order 9)
         (:priority<= "B"
                      ;; Show this section after "Today" and "Important", because
                      ;; their order is unspecified, defaulting to 0. Sections
                      ;; are displayed lowest-number-first.
                      :order 1)
         ;; After the last group, the agenda will display items that didn't
         ;; match any of these groups, with the default order position of 99
         )))
  (org-agenda nil "a"))

(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (:map org-mode-map
         ("C-M-i" . completion-at-point))
  :config
  (org-roam-setup))

(efs/leader-keys
  "n l" '(org-roam-buffer-toggle :which-key "org-roam-buffer-toggle")
  "n f" '(org-roam-node-find :which-key "org-roam-node-find")
  "n i" '(org-roam-node-insert :which-key "org-roam-node-insert"))

(use-package tex
  :defer t
  :config
  (setq-default TeX-auto-save t)
  (setq-default TeX-parse-self t)
  (TeX-PDF-mode)
  ;; Use XeLaTeX & stuff
  (setq-default TeX-engine 'xetex)
  (setq-default TeX-command-extra-options "-shell-escape")
  (setq-default TeX-source-correlate-method 'synctex)
  (TeX-source-correlate-mode)
  (setq-default TeX-source-correlate-start-server t)
  (setq-default LaTeX-math-menu-unicode t)

  (setq-default font-latex-fontify-sectioning 1.3)

  ;; Scale preview for my DPI
  (setq-default preview-scale-function 1.4)
  (when (boundp 'tex--prettify-symbols-alist)
    (assoc-delete-all "--" tex--prettify-symbols-alist)
    (assoc-delete-all "---" tex--prettify-symbols-alist))

  (add-hook 'LaTeX-mode-hook
	    (lambda ()
	      (TeX-fold-mode 1)
	      (outline-minor-mode)))

  (add-to-list 'TeX-view-program-selection
	       '(output-pdf "Zathura"))

  ;; Do not run lsp within templated TeX files
  (add-hook 'LaTeX-mode-hook
	    (lambda ()
	      (unless (string-match "\.hogan\.tex$" (buffer-name))
		(lsp))
	      (setq-local lsp-diagnostic-package :none)
	      (setq-local flycheck-checker 'tex-chktex)))

  (add-hook 'LaTeX-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'LaTeX-mode-hook #'smartparens-mode)
  (add-hook 'LaTeX-mode-hook #'prettify-symbols-mode)

  (efs/leader-keys
   :keymaps '(LaTeX-mode-map latex-mode-map)
   "RET" '(TeX-command-run-all :wk "TeX-command-run-all")
   "c t" 'orgtbl-mode))

(defun my/list-sty ()
  (reverse
   (sort
    (seq-filter
     (lambda (file) (if (string-match ".*\.sty$" file) 1 nil))
     (directory-files
      (seq-some
       (lambda (dir)
	 (if (and
	      (f-directory-p dir)
	      (seq-some
	       (lambda (file) (string-match ".*\.sty$" file))
	       (directory-files dir))
	      ) dir nil))
       (list "./styles" "../styles/" "." "..")) :full))
    (lambda (f1 f2)
      (let ((f1b (file-name-base f1))
	    (f1b (file-name-base f2)))
	(cond
	 ((string-match-p ".*BibTex" f1) t)
	 ((and (string-match-p ".*Locale" f1) (not (string-match-p ".*BibTex" f2))) t)
	 ((string-match-p ".*Preamble" f2) t)
	 (t (string-lessp f1 f2))))))))

(defun my/import-sty ()
  (interactive)
  (insert
   (apply #'concat
	  (cl-mapcar
	   (lambda (file) (concat "\\usepackage{" (file-name-sans-extension (file-relative-name file default-directory)) "}\n"))
	   (my/list-sty)))))

(defun my/import-sty-org ()
  (interactive)
  (insert
   (apply #'concat
	  (cl-mapcar
	   (lambda (file) (concat "#+LATEX_HEADER: \\usepackage{" (file-name-sans-extension (file-relative-name file default-directory)) "}\n"))
	   (my/list-sty)))))

(setq my/greek-alphabet
      '(("a" . "\\alpha")
	("b" . "\\beta" )
	("g" . "\\gamma")
	("d" . "\\delta")
	("e" . "\\epsilon")
	("z" . "\\zeta")
	("h" . "\\eta")
	("o" . "\\theta")
	("i" . "\\iota")
	("k" . "\\kappa")
	("l" . "\\lambda")
	("m" . "\\mu")
	("n" . "\\nu")
	("x" . "\\xi")
	("p" . "\\pi")
	("r" . "\\rho")
	("s" . "\\sigma")
	("t" . "\\tau")
	("u" . "\\upsilon")
	("f" . "\\phi")
	("c" . "\\chi")
	("v" . "\\psi")
	("g" . "\\omega")))

(setq my/latex-greek-prefix "'")

;; The same for capitalized letters
(dolist (elem my/greek-alphabet)
  (let ((key (car elem))
	(value (cdr elem)))
    (when (string-equal key (downcase key))
      (add-to-list 'my/greek-alphabet
		   (cons
		    (capitalize (car elem))
		    (concat
		     (substring value 0 1)
		     (capitalize (substring value 1 2))
		     (substring value 2)))))))

(yas-define-snippets
 'latex-mode
 (mapcar
  (lambda (elem)
    (list (concat my/latex-greek-prefix (car elem)) (cdr elem) (concat "Greek letter " (car elem))))
  my/greek-alphabet))

(setq my/greek-alphabet
      '(("a" . "\\alpha")
	("b" . "\\beta" )
	("g" . "\\gamma")
	("d" . "\\delta")
	("e" . "\\epsilon")
	("z" . "\\zeta")
	("h" . "\\eta")
	("o" . "\\theta")
	("i" . "\\iota")
	("k" . "\\kappa")
	("l" . "\\lambda")
	("m" . "\\mu")
	("n" . "\\nu")
	("x" . "\\xi")
	("p" . "\\pi")
	("r" . "\\rho")
	("s" . "\\sigma")
	("t" . "\\tau")
	("u" . "\\upsilon")
	("f" . "\\phi")
	("c" . "\\chi")
	("v" . "\\psi")
	("g" . "\\omega")))

(setq my/latex-greek-prefix "'")

;; The same for capitalized letters
(dolist (elem my/greek-alphabet)
  (let ((key (car elem))
	(value (cdr elem)))
    (when (string-equal key (downcase key))
      (add-to-list 'my/greek-alphabet
		   (cons
		    (capitalize (car elem))
		    (concat
		     (substring value 0 1)
		     (capitalize (substring value 1 2))
		     (substring value 2)))))))

(yas-define-snippets
 'latex-mode
 (mapcar
  (lambda (elem)
    (list (concat my/latex-greek-prefix (car elem)) (cdr elem) (concat "Greek letter " (car elem))))
  my/greek-alphabet))

(setq my/latex-math-symbols
      '(("x" . "\\times")
	("." . "\\cdot")
	("v" . "\\forall")
	("s" . "\\sum_{$1}^{$2}$0")
	("p" . "\\prod_{$1}^{$2}$0")
	("d" . "\\partial")
	("e" . "\\exists")
	("i" . "\\int_{$1}^{$2}$0")
	("c" . "\\cap")
	("u" . "\\cup")
	("0" . "\\emptyset")
	("^" . "\\widehat{$1}$0")
	("_" . "\\overline{$1}$0")
	("~" . "\\sim")
	("|" . "\\mid")
	("_|" . "\\perp")))

(setq my/latex-math-prefix ";")

(yas-define-snippets
 'latex-mode
 (mapcar
  (lambda (elem)
    (let ((key (car elem))
	  (value (cdr elem)))
      (list (concat my/latex-math-prefix key) value (concat "Math symbol " value))))
  my/latex-math-symbols))

(setq my/latex-section-snippets
      '(("ch" . "\\chapter{$1}")
	("sec" . "\\section{$1}")
	("ssec" . "\\subsection{$1}")
	("sssec" . "\\subsubsection{$1}")
	("par" . "\\paragraph{$1}}")))

(setq my/latex-section-snippets
      (mapcar
       (lambda (elem)
	 `(,(car elem)
	   ,(cdr elem)
	   ,(progn
	      (string-match "[a-z]+" (cdr elem))
	      (match-string 0 (cdr elem)))))
       my/latex-section-snippets))

(dolist (elem my/latex-section-snippets)
  (let* ((key (nth 0 elem))
	 (value (nth 1 elem))
	 (desc (nth 2 elem))
	 (star-index (string-match "\{\$1\}" value)))
    (add-to-list 'my/latex-section-snippets
		 `(,(concat key "*")
		   ,(concat
		     (substring value 0 star-index)
		     "*"
		     (substring value star-index))
		   ,(concat desc " with *")))
    (add-to-list 'my/latex-section-snippets
		 `(,(concat key "l")
		   ,(concat value "%\n\\label{sec:$2}")
		   ,(concat desc " with label")))))

(dolist (elem my/latex-section-snippets)
  (setf (nth 1 elem) (concat (nth 1 elem) "\n$0")))

(yas-define-snippets
 'latex-mode
 my/latex-section-snippets)

(use-package lsp-latex
  :config
  (with-eval-after-load "tex-mode"
    (add-hook 'tex-mode-hook 'lsp)
    (add-hook 'latex-mode-hook 'lsp))

  ;; For bibtex
  (with-eval-after-load "bibtex"
    (add-hook 'bibtex-mode-hook 'lsp)))

(use-package company-auctex
  :after auctex
  :config
  (company-auctex-init))

;; local configuration for TeX modes
 (defun my-latex-mode-setup ()
   (setq-local company-backends
	       (append '((company-math-symbols-latex company-latex-commands))
		       company-backends)))

 (add-hook 'TeX-mode-hook 'my-latex-mode-setup)

(use-package company-reftex
  :after company)

(add-hook 'Latex-mode-hook 'turn-on-reftex)
(add-hook 'latex-mode-hook 'turn-on-reftex)

(custom-set-variables
 '(package-selected-packages (quote (company-reftex company))))
(custom-set-faces)

(eval-after-load "company"
'(add-to-list
  'company-backends
  'company-reftex-labels
  'company-reftex-citations))

(use-package cdlatex
  :diminish 'org-cdlatex-mode
  :hook ((LaTeX-mode . turn-on-cdlatex)
	 (org-mode . turn-on-org-cdlatex)))

(auctex-latexmk-setup)
(setq auctex-latexmk-inherit-TeX-PDF-mode t)

(add-hook 'LaTeX-mode-hook #'evil-tex-mode)

(latex-preview-pane-enable)

(use-package org-ref
  :init
  (setq bibtex-dialect 'biblatex)
  ;(setq bibtex-completion-bibliography '("~/30-39 Life/32 org-mode/library.bib"))
  ;(setq bibtex-completion-library-path '("~/30-39 Life/33 Library"))
  ;(setq bibtex-completion-notes-path "~/Documents/org-mode/literature-notes")
  (setq bibtex-completion-display-formats
        '((t . "${author:36} ${title:*} ${note:10} ${year:4} ${=has-pdf=:1}${=type=:7}")))
  (setq bibtex-completion-pdf-open-function
        (lambda (file)
          (start-process "dired-open" nil
                         "xdg-open" (file-truename file))))
  :after (org)
  :config
  (with-eval-after-load 'ivy-bibtex
    (require 'org-ref-ivy))
  (general-define-key
   :keymaps 'org-mode-map
   "C-c l" #'org-ref-insert-link-hydra/body)
  (general-define-key
   :keymaps 'bibtex-mode-map
   "M-RET" 'org-ref-bibtex-hydra/body))

(use-package ivy-bibtex
  :after (org-ref)
  :init
  (efs/leader-keys "fB" 'ivy-bibtex))

(add-hook 'bibtex-mode 'smartparens-mode)

(use-package treemacs
  :defer t
  :config
  (setq treemacs-space-between-root-nodes nil))

(efs/leader-keys
    :keymaps 'treemacs-mode-map
    :states '(normal emacs)
    "q" '(treemacs-quit :which-key "close treemacs"))

(use-package treemacs-evil
  :after (treemacs evil)
  :straight t)

(use-package lsp-mode
  :hook (
         (typescript-mode . lsp)
         (js-mode . lsp)
         (vue-mode . lsp)
         (go-mode . lsp)
         (svelte-mode . lsp)
         (python-mode . lsp)
         (json-mode . lsp)
         (haskell-mode . lsp)
         (haskell-literate-mode . lsp)
         (java-mode . lsp)
         ;; (csharp-mode . lsp)
         )
  :commands lsp
  :init
  (setq lsp-keymap-prefix nil)
  :config
  (setq lsp-idle-delay 1)
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-delay 2)
  (lsp-ui-doc-position 'bottom)
  (setq lsp-ui-sideline-show-hover nil))

(use-package lsp-treemacs
  :after lsp
  :commands lsp-treemacs-errors-list)

(efs/leader-keys
  :infix "l"
  "d" '(lsp-ui-peek-find-definitions)
  "r" '(lsp-rename)
  "u" '(lsp-ui-peek-find-references)
  "s" '(lsp-ui-find-workspace-symbol)
  "l" '(lsp-execute-code-action)
  "e" '(list-flycheck-errors))

(defun my/lsp--progress-status ()
  "Returns the status of the progress for the current workspaces."
  (-let ((progress-status
	  (s-join
	   "|"
	   (-keep
	    (lambda (workspace)
	      (let ((tokens (lsp--workspace-work-done-tokens workspace)))
		(unless (ht-empty? tokens)
		  (mapconcat
		   (-lambda ((&WorkDoneProgressBegin :message? :title :percentage?))
		     (concat (if percentage?
				 (if (numberp percentage?)
				     (format "%.0f%%%% " percentage?)
				   (format "%s%%%% " percentage?))
			       "")
			     (let ((msg (url-unhex-string (or message\? title))))
			       (if (string-match-p "\\`file:///" msg)
				   (file-name-nondirectory msg)))))
		   (ht-values tokens)
		   "|"))))
	    (lsp-workspaces)))))
    (unless (s-blank? progress-status)
      (concat lsp-progress-prefix progress-status))))

(with-eval-after-load 'lsp-mode
  (advice-add 'lsp--progress-status :override #'my/lsp--progress-status))

(use-package flycheck
  :config
  (global-flycheck-mode)
  (setq flycheck-check-syntax-automatically '(save idle-buffer-switch mode-enabled))
  ;; (add-hook 'evil-insert-state-exit-hook
  ;;           (lambda ()
  ;;             (if flycheck-checker
  ;;                 (flycheck-buffer))
  ;;             ))
  (advice-add 'flycheck-eslint-config-exists-p :override (lambda() t))
  (add-to-list 'display-buffer-alist
	       `(,(rx bos "*Flycheck errors*" eos)
		 (display-buffer-reuse-window
		  display-buffer-in-side-window)
		 (side            . bottom)
		 (reusable-frames . visible)
		 (window-height   . 0.33))))

(use-package dap-mode
  :commands (dap-debug)
  :init
  (setq lsp-enable-dap-auto-configure nil)
  :config

  (setq dap-ui-variable-length 100)
  (setq dap-auto-show-output nil)
  (require 'dap-node)
  (dap-node-setup)

  (require 'dap-chrome)
  (dap-chrome-setup)

  (require 'dap-python)
  (require 'dap-php)

  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (tooltip-mode 1))

(use-package highlight-indent-guides
  :config
  (setq highlight-indent-guides-method 'character
  highlight-indent-guides-responsive 'top)
  :hook (prog-mode . highlight-indent-guides-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package eshell-toggle
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term))

  (use-package eshell-syntax-highlighting
    :after esh-mode
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
  ;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
  ;; eshell-aliases-file -- sets an aliases file for the eshell.

  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
	eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
	eshell-history-size 5000
	eshell-buffer-maximum-lines 5000
	eshell-hist-ignoredups t
	eshell-scroll-to-bottom-on-input t
	eshell-destroy-buffer-when-process-dies t
	eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
  :straight t
  :config
  (setq shell-file-name "/bin/zsh"
        vterm-max-scrollback 5000))

(use-package vterm-toggle
  :straight t
  :after vterm
  :config
  ;; When running programs in Vterm and in 'normal' mode, make sure that ESC
  ;; kills the program as it would in most standard terminal programs.
  (evil-define-key 'normal vterm-mode-map (kbd "<escape>") 'vterm--self-insert)
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.4))))

(efs/leader-keys
  "t t" '(vterm-toggle :which-key "toggle vterm"))

(setq frame-resize-pixelwise t)

(use-package app-launcher
  :straight '(app-launcher :host github :repo "SebastienWae/app-launcher"))

;; emacsclient -cF "((visibility . nil))" -e "(emacs-run-launcher)"

(defmacro bookmark-selector-launcher (NAME WIDTH HEIGHT FUNCTION)
  "Define a launcher command.

Bookmark-selector is a package revolving around using emacs
outside of emacs to browse your bookmarks. Most of the commands
defined, consist of opening an emacs frame with only a
minibuffer, with a specified NAME, WIDTH and HEIGHT and inside it
calling FUNCTION and deleting the frame after the function
completes or is canceled."
  `(with-selected-frame (make-frame '((name . ,NAME)
                                      (minibuffer . only)
                                      (width . ,WIDTH)
                                      (height . ,HEIGHT)))
     (unwind-protect
         (funcall ,FUNCTION)
       (delete-frame))))

(defun emacs-run-launcher ()
  "Create and select a frame called emacs-run-launcher which consists only of a minibuffer and has specific dimensions. Runs app-launcher-run-app on that frame, which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour. Delete the frame after that command has exited"
  (interactive)
  (bookmark-selector-launcher "emacs-run-launcher" 59 14 'app-launcher-run-app)
    (unwind-protect
        (funcall ,FUNCTION)
      (delete-frame)))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 5000 1000))
