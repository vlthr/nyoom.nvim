(import-macros {: set!} :macros)
(local {: setup} (require :auto-session))

(set! sessionoptions
      [:blank :buffers :curdir :folds :help :tabpages :winsize :winpos :terminal])

(setup {
           :log_level :error
           ;; :save_extra_cmds []
           :cwd_change_handling {  ;; :pre_cwd_changed_hook ["SomeVimCmd" some-lua-fn]
                                   ;; :post_cwd_changed_hook ["SomeVimCmd" some-lua-fn]
                                   :restore_upcoming_session false}
           :auto_session_suppress_dirs ["~/" "~/bb" "~/build" "~/Downloads" "/"]})


