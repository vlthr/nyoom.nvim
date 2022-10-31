(import-macros {: packadd! : nyoom-module-p!} :macros)
(local neotest (require :neotest))

(packadd! neotest-python)
(local neotest-python (require :neotest-python))
(local pytest-args [ "--log-level" "debug" "--slow"])

(neotest.setup {:icons {:passed "" :failed "" :running "" :skipped "" :unknown ""}
                :adapters [ (neotest-python {:args (fn [] pytest-args)
                                             :dap { :justMyCode true}})]})
(nyoom-module-p! hydra
  (do
    (local Hydra (require :hydra))
    (local neotest-hint "

                  Neotest

  _t_: test nearest   _d_: debug nearest
  _f_: test file      _a_: attach to test
  _s_: stop tests   
^
                      _<Tab>_:   toggle summary
  _q_: Exit           _<Enter>_: show output

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
                     #(neotest.run.run)
                     {:exit true}]
                    [:f 
                     #(neotest.run.run (vim.fn.expand "%"))
                     {:exit true}]
                    [:d 
                     #(neotest.run.run {:strategy :dap})
                     {:exit true}]
                    [:s 
                     #(neotest.run.stop)
                     {:exit true}]
                    [:a 
                     #(neotest.run.attach)
                     {:exit true}]
                    [:<Tab> 
                     #(neotest.summary.toggle) 
                     {:exit true}]
                    [:<Enter> 
                     #(neotest.output.open {:short true :enter true :quiet false}) 
                     {:exit true}]
                    [:q
                     nil 
                     {:exit true :nowait true}]]})))
