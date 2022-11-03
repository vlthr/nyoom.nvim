(import-macros {: packadd! : map!} :macros)
(local {: autoload} (require :core.lib.autoload))

(packadd! copilot.lua)
(local copilot (autoload :copilot))

(local node-path (vim.fn.expand "~/.nvm/versions/node/v16.17.0/bin/node"))

(copilot.setup {:panel {:enabled true
                        :auto_refresh false
                        :keymap {:jump_next "]]"
                                 :open :<M-CR>
                                 :refresh :gr
                                 :jump_prev "[["
                                 :accept :<CR>}}
                :suggestion {:enabled true
                             :keymap {:dismiss "<C-]>"
                                      :next "‘"
                                      :prev "“"
                                      ;; :next "<M-]>"
                                      ;; :prev "<M-[>"
                                      :accept :<M-l>}
                             :debounce 75
                             :auto_trigger false}
                :copilot_node_command node-path
                ;; :server_opts_overrides {}
                :filetypes {:hgcommit false
                            :help false
                            :svn false
                            :gitcommit false
                            :cvs false
                            :. false
                            :yaml false
                            :markdown false
                            :gitrebase false}})

(map! [i] :<C-f> "<cmd>lua require(\"copilot.suggestion\").next()<CR>"
      {:noremap true :silent true})
