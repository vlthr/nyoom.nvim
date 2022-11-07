(import-macros {: map! : set! : nyoom-module-p!} :macros)
(local {: autoload} (require :core.lib.autoload))
(local vtf (autoload :vtf))
(local hotpot (autoload :hotpot))
(local hotpot-source (autoload :hotpot.api.source))
(local hotpot-compile (autoload :hotpot.api.compile))
(local hotpot-eval (autoload :hotpot.api.eval))
(local hotpot-cache (autoload :hotpot.api.cache))

(map! [n] :<leader>eb `(vtf.pecho (hotpot-eval.eval-buffer 0))
      {:desc "Evaluate entire buffer"})

(map! [n] :<leader>ecb `(vtf.pecho (hotpot-compile.compile-buffer 0))
      {:desc "Evaluate entire buffer"})

(map! [v] :<leader>es `(vtf.pecho (hotpot-eval.eval-selection))
      {:desc "Evaluate selection"})

(nyoom-module-p! hydra
                 (do
                   (local Hydra (require :hydra))
                   (local hotpot-hint "
           _b_: eval buffer      _c_: compile buffer
           _s_: source file

           _<BS>_: clear cache
  ^
           _q_

    ")
                   (local eval-buffer
                          (fn [buf-nr]
                            (vtf.pecho (hotpot-eval.eval-buffer (or buf-nr 0)))))
                   (local source-buffer
                          (fn []
                            (vim.cmd "Fnlsource %")))
                   (local compile-buffer
                          (fn [buf-nr]
                            (hotpot-compile.compile-buffer (or buf-nr 0))))
                   (local cache-path
                          (fn [fnl-file]
                            (hotpot-cache.cache-path-for-fnl-file (or fnl-file
                                                                      (vim.fn.expand "%")))))
                   (local clear-cache
                          (fn []
                            (hotpot-cache.clear-cache)))
                   (Hydra {:name :hotpot
                           :hint hotpot-hint
                           :config {:color :teal
                                    :invoke_on_body true
                                    :hint {:position :middle :border :solid}}
                           :mode :n
                           :body :<Leader>ee
                           :heads [[:c compile-buffer]
                                   [:<BS> clear-cache]
                                   [:b eval-buffer]
                                   [:s source-buffer]
                                   [:q nil {:exit true :nowait true}]]})))
