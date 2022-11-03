(import-macros {: use-package! : pack} :macros)

;; standard completion for neovim
(use-package! :zbirenbaum/copilot.lua
              {:nyoom-module completion.copilot
               :module :copilot
               :event [:InsertEnter :CmdLineEnter]})
