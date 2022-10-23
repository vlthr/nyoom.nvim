(import-macros {: use-package!} :macros)
(use-package! :ruifm/gitlinker.nvim {:nyoom-module tools.gitlinker
                                     :module :gitlinker
                                     :cmd ["Gitlinker"]
                                     :requires [(use-package! "nvim-lua/plenary.nvim")]})
