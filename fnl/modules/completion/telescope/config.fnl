(import-macros {: packadd! : map! : nyoom-module-p!} :macros)
(local {: autoload} (require :core.lib.autoload))
(local {: setup : load_extension} (autoload :telescope))

(fn fb-action [action]
  (fn [buf_nr]
    (local fb-actions (. (autoload :telescope) :extensions :file_browser
                         :actions))
    ((. fb-actions action) buf_nr)))

(fn toggle-hidden-or-ignored [prompt-bufnr]
  (let [action-state (require :telescope.actions.state)
        current-picker (action-state.get_current_picker prompt-bufnr)
        finder current-picker.finder]
    (set finder.hidden (not finder.hidden))
    (set finder.respect_gitignore (not finder.hidden))
    (current-picker:refresh finder
                            {:multi current-picker._multi :reset_prompt true})))

(local file-browser-opts
       {:quiet false
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
                       :h toggle-hidden-or-ignored
                       :o (fb-action :open)
                       :g (fb-action :goto_parent_dir)}
                   :i {:<C-g> (fb-action :goto_parent_dir)
                       "<C-\\>d" (fb-action :remove)
                       "<C-\\>H" (fb-action :goto_cwd)
                       "<C-\\>m" (fb-action :move)
                       "<C-\\>h" toggle-hidden-or-ignored
                       :<C-h> toggle-hidden-or-ignored
                       :<C-s> (fb-action :toggle_all)
                       "<C-\\>n" (fb-action :create)
                       "<C-\\>r" (fb-action :rename)
                       "<C-\\>o" (fb-action :open)
                       "<C-\\>y" (fb-action :copy)
                       :<C-f> (fb-action :toggle_browser)
                       :<S-CR> (fb-action :create_from_prompt)
                       :<C-e> nil
                       ;; (fb-action :goto_home_dir)
                       :<C-t> (fb-action :change_cwd)}}})

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
                   :dynamic_preview_title true
                   :vimgrep_arguments [:rg
                                       :--color=never
                                       :--hidden
                                       :--no-heading
                                       :--with-filename
                                       :--line-number
                                       :--column
                                       :--smart-case
                                       :--follow
                                       :--trim]}
        ;; :extensions_list [:themes :terms :live_grep_args :frecency]
        :extensions {:file_browser file-browser-opts
                     :fzf {:fuzzy true
                           :case_mode :smart_case
                           :override_file_sorter true
                           :override_generic_sorter true}
                     :frecency {:ignore_patterns [:*.git/*
                                                  :*/tmp/*
                                                  :*/__pycache__/*]
                                :show_scores false
                                :show_unindexed true
                                :workspaces (. (autoload :vt.projects)
                                               :frecency_workspaces)
                                :disable_devicons false}
                     :live_grep_args {:mappings {:i {:<C-l>g (fn []
                                                               ((. (autoload :telescope-live-grep-args.actions)
                                                                   :quote_prompt) {:postfix " --iglob "}))
                                                     :<C-q> (fn []
                                                              ((. (autoload :telescope-live-grep-args.actions)
                                                                  :quote_prompt)))
                                                     :<C-l>t (fn []
                                                               ((. (autoload :telescope-live-grep-args.actions)
                                                                   :quote_prompt) {:postfix " -t"}))}}
                                      :auto_quoting false}
                     :fzy_native {:override_file_sorter false
                                  :override_generic_sorter false}
                     :fzf_writer {:minimum_grep_characters 2
                                  :minimum_files_characters 2
                                  :use_highlighter true}
                     :zf-native {:file {:enable false
                                        :match_filename true
                                        :highlight_results true}
                                 :generic {:enable false
                                           :match_filename false
                                           :highlight_results true}}}
        :pickers {:git_files {:attach_mappings (fn [_ map]
                                                 (local actions
                                                        (autoload :telescope.actions))
                                                 (local action_state
                                                        (autoload :telescope.actions.state))
                                                 ;; attach_mappings doesn't octually override here
                                                 (actions.select_default:replace (fn [prompt_bufnr]
                                                                                   (local action_state
                                                                                          (autoload :telescope.actions.state))
                                                                                   (local selected
                                                                                          (action_state.get_selected_entry))
                                                                                   (when (not (= nil
                                                                                                 selected))
                                                                                     (actions.close prompt_bufnr)
                                                                                     (vim.cmd (.. "DiffviewOpen "
                                                                                                  selected)))))
                                                 false)}
                  :find_files {:find_command [:rg
                                              :--files
                                              :--color=never
                                              :--follow]
                               :mappings {}}}})

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
                           :lsp_workspace_symbols open-workspace-symbol-float!}
                          (autoload :telescope.builtin))
                   (map! [n] :<leader>li open-impl-float!)
                   (map! [n] :<leader>lr open-ref-float!)
                   (map! [n] :<leader>ls open-local-symbol-float!)
                   (map! [n] :<leader>lS open-workspace-symbol-float!)))

(nyoom-module-p! syntax
                 (do
                   (local {:diagnostics open-diag-float!}
                          (autoload :telescope.builtin))
                   (map! [n] :<leader>ld `(open-diag-float! {:bufnr 0}))
                   (map! [n] :<leader>lD open-diag-float!)))
