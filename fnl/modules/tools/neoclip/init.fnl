(import-macros {: use-package!} :macros)

(use-package! "AckslD/nvim-neoclip.lua"
              {:nyoom-module tools.neoclip
               :requires [(use-package! :kkharji/sqlite.lua {:module :sqlite}
                            (use-package! :nvim-telescope/telescope.nvim)
                            (use-package! :ibhagwan/fzf-lua))]})
