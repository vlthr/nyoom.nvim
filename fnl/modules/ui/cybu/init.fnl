(import-macros {: use-package!} :macros)

(use-package! :ghillb/cybu.nvim
              {:nyoom-module ui.cybu
               :module :cybu
               :cmd [:CybuPrev
                     :CybuNext
                     :CybuLastUsedPrev
                     :CybuLastUsedNext
                     :Cybu]
               :keys [:<tab> :<S-tab>]
               :branch :main
               :requires [:nvim-tree/nvim-web-devicons :nvim-lua/plenary.nvim]})
