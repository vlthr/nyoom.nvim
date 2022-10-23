(import-macros {: use-package!} :macros)

(use-package! :tami5/sqlite.lua
              { :opt true 
               :module "sqlite"})
(use-package! :nvim-telescope/telescope-frecency.nvim 
              {:opt true})
               ;; :after "telescope.nvim"
               ;; :requires ["tami5/sqlite.lua"]
