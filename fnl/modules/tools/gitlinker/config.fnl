(import-macros {: command!} :macros)
(local {: setup : get_buf_range_url} (require :gitlinker))

(setup {:mappings nil})

(command! Gitlinker '(match (vim.fn.mode)
                       :n (get_buf_range_url :n {})
                       :i (get_buf_range_url :n {})
                       :v (get_buf_range_url :v {}))
          {:range true})
