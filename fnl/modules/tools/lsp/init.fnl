(import-macros {: use-package!} :macros)

; view lsp loading progress
(use-package! :j-hui/fidget.nvim {:call-setup fidget
                                  :after :nvim-lspconfig})

; easy to use configurations for language servers
(use-package! :neovim/nvim-lspconfig {:opt true
                                      :defer nvim-lspconfig
                                      :nyoom-module tools.lsp})


(use-package! :jose-elias-alvarez/null-ls.nvim {:opt true :module :null-ls})

(use-package! :folke/neodev.nvim {:opt true :module :neodev})
