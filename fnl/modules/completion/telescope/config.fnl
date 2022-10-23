(import-macros {: packadd! : map! : nyoom-module-p!} :macros)
(local {: setup : load_extension} (require :telescope))

(fn fb-action [action]
  (fn [buf_nr]
   (local fb-actions (. (require :telescope) :extensions :file_browser :actions))
   ((. fb-actions action) buf_nr)))

(local file-browser-opts {:quiet false
                          :mappings {:n {:r (fb-action :rename)
                                         :s (fb-action :toggle_all)
                                         :m (fb-action :move)
                                         :e (fb-action :goto_home_dir)
                                         :y (fb-action :copy)
                                         :c (fb-action :create)
                                         :t (fb-action :change_cwd)
                                         :w (fb-action :goto_cwd)
                                         :f (fb-action :toggle_browser)
                                         :d (fb-action :remove)
                                         :h (fb-action :toggle_hidden)
                                         :o (fb-action :open)
                                         :g (fb-action :goto_parent_dir)}
                                     :i {"<C-g>" (fb-action :goto_parent_dir)
                                         "<C-\\>d" (fb-action :remove)
                                         "<C-\\>H" (fb-action :goto_cwd)
                                         "<C-\\>m" (fb-action :move)
                                         "<C-\\>h" (fb-action :toggle_hidden)
                                         "<C-s>" (fb-action :toggle_all)
                                         "<C-\\>n" (fb-action :create)
                                         "<C-\\>r" (fb-action :rename)
                                         "<C-\\>o" (fb-action :open)
                                         "<C-\\>y" (fb-action :copy)
                                         "<C-f>" (fb-action :toggle_browser)
                                         "<S-CR>" (fb-action :create_from_prompt)
                                         "<C-e>" nil ;; (fb-action :goto_home_dir)
                                         "<C-t>" (fb-action :change_cwd)}}})

(setup {:defaults {:prompt_prefix "   "
                   :selection_caret "  "
                   :entry_prefix "  "
                   :sorting_strategy :ascending
                   :layout_strategy :flex
                   :layout_config {:horizontal {:prompt_position :top
                                                :preview_width 0.55}
                                   :vertical {:mirror false}
                                   :width 0.87
                                   :height 0.8
                                   :preview_cutoff 120}
                   :set_env {:COLORTERM :truecolor}
                   :dynamic_preview_title true}})

;; Load extensions
(packadd! telescope-ui-select.nvim)
(load_extension :ui-select)
(packadd! telescope-file-browser.nvim)
(load_extension :file_browser)

;; only install native if the flag is there
(nyoom-module-p! telescope.+native
  (do
    (packadd! telescope-fzf-native.nvim)
    (load_extension :fzf)))

(nyoom-module-p! telescope.+zf-native
  (do
    (packadd! telescope-zf-native.nvim)
    (load_extension :zf-native)))

(nyoom-module-p! telescope.+frecency
  (do
    (packadd! telescope-frecency.nvim)
    (load_extension :frecency)))

;; load media-files and zoxide only if their executables exist
(when (= (vim.fn.executable :ueberzug) 1)
  (do
    (packadd! telescope-media-files.nvim)
    (load_extension :media_files)))

(when (= (vim.fn.executable :zoxide) 1)
  (do
    (packadd! telescope-zoxide)
    (load_extension :zoxide)))

(nyoom-module-p! lsp
  (do
    (local {:lsp_implementations open-impl-float!
            :lsp_references open-ref-float!
            :diagnostics open-diag-float!
            :lsp_document_symbols open-local-symbol-float!
            :lsp_workspace_symbols open-workspace-symbol-float!} (require :telescope.builtin))
    (map! [n] "<leader>li" open-impl-float!)
    (map! [n] "<leader>lr" open-ref-float!)
    (map! [n] "<leader>ls" open-local-symbol-float!)
    (map! [n] "<leader>lS" open-workspace-symbol-float!)))

(nyoom-module-p! syntax
  (do
    (local {:diagnostics open-diag-float!} (require :telescope.builtin))
    (map! [n] "<leader>ld" '(open-diag-float! {:bufnr 0}))
    (map! [n] "<leader>lD" open-diag-float!)))
