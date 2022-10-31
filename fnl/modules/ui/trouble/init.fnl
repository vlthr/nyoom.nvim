(import-macros {: use-package!} :macros)

(use-package! :folke/trouble.nvim
              {:nyoom-module ui.trouble
               :module "trouble"
               :cmd [:Trouble :TroubleToggle :TroubleClose :TroubleRefresh]
               :requires [(use-package! :kyazdani42/nvim-web-devicons)]})
               
