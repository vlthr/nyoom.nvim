(import-macros {: use-package!} :macros)

(use-package! :nvim-neotest/neotest 
              { :nyoom-module tools.neotest :defer neotest :opt true})
              ;; :module [ "neotest"]
              ;; :requires [(use-package! "nvim-neotest/neotest-python" {:opt true})
              ;;            (use-package! "nvim-lua/plenary.nvim" {:opt true})
              ;;            (use-package! "nvim-treesitter/nvim-treesitter" {:opt true})])

(use-package! "nvim-neotest/neotest-python" {:opt true :defer neotest-python})

