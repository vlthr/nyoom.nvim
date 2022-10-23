(local {: setup } (require :diffview))
(local actions (require :diffview.actions))
(setup {
        :enhanced_diff_hl true
        :hooks {:view_opened (fn []
                              (vim.api.nvim_set_hl 0 :DiffAdd {:underdotted false
                                                               :fg nil
                                                               ;; :nocombine true
                                                               :bg "#123010"})
                                                               ;; :sp "#88B72A"

                              (vim.api.nvim_set_hl 0 :DiffDelete
                                                   {:underdotted false
                                                    ;; :fg "#E55561"
                                                    ;; :nocombine true
                                                    :bg nil
                                                    :sp "#F07178"})

                              (vim.api.nvim_set_hl 0 :DiffChange
                                                   {:underline false
                                                    :fg nil
                                                    :nocombine true
                                                    :bg "#30363f"
                                                    :sp nil})

                              (vim.api.nvim_set_hl 0 :DiffText
                                                   {:underline true
                                                    :fg nil
                                                    :nocombine true
                                                    :bg "#30363f"
                                                    :sp "#36A3D9"}))}
        :keymaps {
                  ;; :disable_defaults false
                  :view { 
                         "<tab>"      actions.select_next_entry
                         "<s-tab>"    actions.select_prev_entry
                         "gf"         actions.goto_file
                         "<C-w><C-f>" actions.goto_file_split
                         "<C-w>gf"    actions.goto_file_tab
                         "<leader>e"  actions.focus_files
                         "<leader>b"  actions.toggle_files
                         "g<C-x>"     actions.cycle_layout
                         "[x"         actions.prev_conflict
                         "]x"         actions.next_conflict
                         "<leader>co" (fn [] (actions.conflict_choose "ours"))
                         "<leader>ct" (fn [] (actions.conflict_choose "theirs"))
                         "<leader>cb" (fn [] (actions.conflict_choose "base"))
                         "<leader>ca" (fn [] (actions.conflict_choose "all"))
                         "dx"         (fn [] (actions.conflict_choose "none"))
                         "q"            (fn [] (vim.cmd "DiffviewClose"))}
                  :diff1 {}
                  :diff2 {}
                  :diff3 [
                          [ [ "n" "x" ] "2do" (fn [] (actions.diffget "ours"))]
                          [ [ "n" "x" ] "3do" (fn [] (actions.diffget "theirs"))]]
                  :diff4 [
                          [ [ "n" "x" ] "1do" (fn [] (actions.diffget "base"))]
                          [ [ "n" "x" ] "2do" (fn [] (actions.diffget "ours"))]
                          [ [ "n" "x" ] "3do" (fn [] (actions.diffget "theirs"))]]
                  :file_panel { 
                               "j"             actions.next_entry
                               "<down>"        actions.next_entry
                               "k"             actions.prev_entry
                               "<up>"          actions.prev_entry
                               "<cr>"          actions.select_entry
                               "o"             actions.select_entry
                               "<2-LeftMouse>" actions.select_entry
                               "<space>"             actions.toggle_stage_entry
                               "s"             actions.toggle_stage_entry
                               "S"             actions.stage_all
                               "U"             actions.unstage_all
                               "X"             actions.restore_entry
                               "R"             actions.refresh_files
                               "L"             actions.open_commit_log
                               "<c-b>"         (fn [] (actions.scroll_view -0.25))
                               "<c-f>"         (fn [] (actions.scroll_view 0.25))
                               "<tab>"         actions.select_next_entry
                               "<s-tab>"       actions.select_prev_entry
                               "gf"            actions.goto_file
                               "<C-w><C-f>"    actions.goto_file_split
                               "<C-w>gf"       actions.goto_file_tab
                               "i"             actions.listing_style
                               "f"             actions.toggle_flatten_dirs
                               "<leader>e"     actions.focus_files
                               "<leader>b"     actions.toggle_files
                               "g<C-x>"        actions.cycle_layout
                               "[x"            actions.prev_conflict
                               "]x"            actions.next_conflict
                               "q"            (fn [] (vim.cmd "DiffviewClose"))}




                  :file_history_panel { 
                                       "g!"            actions.options
                                       "<C-A-d>"       actions.open_in_diffview
                                       "y"             actions.copy_hash
                                       "L"             actions.open_commit_log
                                       "zR"            actions.open_all_folds
                                       "zM"            actions.close_all_folds
                                       "j"             actions.next_entry
                                       "<down>"        actions.next_entry
                                       "k"             actions.prev_entry
                                       "<up>"          actions.prev_entry
                                       "<cr>"          actions.select_entry
                                       "o"             actions.select_entry
                                       "<2-LeftMouse>" actions.select_entry
                                       "<c-b>"         (fn [] (actions.scroll_view -0.25))
                                       "<c-f>"         (fn [] (actions.scroll_view 0.25))
                                       "<tab>"         actions.select_next_entry
                                       "<s-tab>"       actions.select_prev_entry
                                       "gf"            actions.goto_file
                                       "<C-w><C-f>"    actions.goto_file_split
                                       "<C-w>gf"       actions.goto_file_tab
                                       "<leader>e"     actions.focus_files
                                       "<leader>b"     actions.toggle_files
                                       "g<C-x>"        actions.cycle_layout
                                       "q"            (fn [] (vim.cmd "DiffviewClose"))}




                  :option_panel {
                                 "<tab>" actions.select_entry
                                 "q"     actions.close}}})















