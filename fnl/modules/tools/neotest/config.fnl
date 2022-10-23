(import-macros {: packadd! : nyoom-module-p!} :macros)
(local {: setup} (require :neotest))

(packadd! neotest-python)
(local neotest-python (require :neotest-python))
(setup { :adapters [ (neotest-python {:dap { :justMyCode false}})]})

(nyoom-module-p! ui.hydra
  (do
    (local Hydra (require :hydra))
    (local neotest-hint "

                  Neotest

  _t_: test nearest   _d_: debug nearest
  _f_: test file      _a_: attach to test
  _s_: stop tests   
^
  _q_: Exit

    ")
    (Hydra {:name :Neotest
            :hint neotest-hint
            :config {:color :red
                     :buffer bufnr
                     :invoke_on_body true
                     :hint {:position :middle :border :solid}}
            :mode :n
            :body :<Leader>t
            :heads [[:t 
                     #((. (require "neotest") :run :run))
                     {:exit true}]
                    [:f 
                     #((. (require "neotest") :run :run) (vim.fn.expand "%"))
                     {:exit true}]
                    [:d 
                     #((. (require "neotest") :run :run) {:strategy :dap})
                     {:exit true}]
                    [:s 
                     #((. (require "neotest") :run :stop))
                     {:exit true}]
                    [:a 
                     #((. (require "neotest") :run :attach))
                     {:exit true}]
                    [:<CR> 
                     #((. (require "neotest") :output :open 
                        {:short false :enter true :quiet false})) 
                        ;; :position-id nil
                     {:exit true}]
                    [:q
                     nil 
                     {:exit true :nowait true}]]})))
