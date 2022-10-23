(import-macros {: packadd! : pack : rock : use-package! : rock! : unpack! : echo!} :macros)

;; Load packer
(echo! "Loading Packer")
(packadd! packer.nvim)

;; include modules
(echo! "Compiling Modules")
(include :fnl.modules)

;; Setup packer
(local non-interactive (if (os.getenv :NYOOM_CLI) true false))
(echo! "Initiating Packer")
(let [packer (require :packer)]
   (packer.init {:git {:clone_timeout 300}
                 :compile_path (.. (vim.fn.stdpath :config) "/lua/packer_compiled.lua")
                 :auto_reload_compiled false
                 :display {:non_interactive non-interactive}}))

;; Core packages
(use-package! :wbthomason/packer.nvim {:opt true})
(use-package! :nvim-lua/plenary.nvim {:module :plenary})

;; To install a package with Nyoom you must declare them here and run 'nyoom sync'
;; on the command line, then restart nvim for the changes to take effect
;; The syntax is as follows: 

;; (use-package! :username/repo {:opt true
;;                               :defer reponame-to-defer
;;                               :call-setup pluginname-to-setup
;;                               :cmd [:cmds :to :lazyload]
;;                               :event [:events :to :lazyload]
;;                               :ft [:ft :to :load :on]
;;                               :requires [(pack :plugin/dependency)]
;;                               :run :commandtorun
;;                               :as :nametoloadas
;;                               :branch :repobranch
;;                               :setup (fn [])
;;                                        ;; same as setup with packer.nvim)})
;;                               :config (fn [])})
;;                                        ;; same as config with packer.nvim)})


;; ---------------------
;; Put your plugins here
;; ---------------------
;; (use-package! )
;;
(use-package! :tpope/vim-abolish 
              {:cmd ["Subvert"]
               :keys ["crs" "crm" "crc" "cru" "cr-" "cr." "cr<space>" "crt"]})

(use-package! :kylechui/nvim-surround {:config (fn [] 
                                                 (local surround (require "nvim-surround"))
                                                 (surround.setup {}))})
(use-package! :linty-org/readline.nvim
              {:module "readline"})

(use-package! :fladson/vim-kitty)
(use-package! :milkias17/reloader.nvim {:module "reloader" :cmd ["Reload"] :requires ["nvim-lua/plenary.nvim"]})

;;   ["stevearc/dressing.nvim"] = {
;;                                 requires = "MunifTanjim/nui.nvim",
;;                                 -- lots of configs, see
;;                                 -- https://github.com/stevearc/dressing.nvim#installation}
;;   ,
;;
;;
;;
;;   ["mfussenegger/nvim-dap-python"] = {
;;                                       module = "dap-python",
;;                                       after = "nvim-dap",
;;                                       requires = { "mfussenegger/nvim-dap" },
;;                                       config = function()
;;                                       require("dap-python").setup("~/.pyenv/versions/debugpy/bin/python")
;;                                       require("dap-python").test_runner = "pytest"
;;                                       end,}
;;   ,
;;
;;   ["smjonas/live-command.nvim"] = {
;;                                    -- module = "live-command",
;;                                    -- cmd = {"Norm"},
;;                                    config = function()
;;                                    require("plugins.configs.live_command").setup()
;;                                    end}
;;   ,
(use-package! :kdheepak/lazygit.nvim {
                                      :cmd  [ "LazyGit" "LazyGitConfig" "LazyGitFilter" "LazyGitFilterCurrentFile"]
                                      :module  [  "lazygit" "lazygit.utils"]
                                      :config  (fn [] (local telescope (require :telescope))
                                                (telescope.load_extension "lazygit"))})
(use-package! :kevinhwang91/nvim-bqf {:ft "qf"})
;;   ["nvim-telescope/telescope-live-grep-args.nvim"] = {
;;                                                       after = "telescope.nvim",}
;;   ,
;;   ,
(use-package! :nvim-treesitter/nvim-treesitter-textobjects 
              {
               :after "nvim-treesitter"
               :config (fn [] 
                         (local vt-tree (require :vt.treesitter)) 
                         (vt-tree.setup_textobjects))})
(use-package! :RRethy/nvim-treesitter-textsubjects 
              {
               :after "nvim-treesitter"
               :config (fn [] 
                         (local vt-tree (require :vt.treesitter)) 
                         (vt-tree.setup_textsubjects))})

(use-package! :stevearc/overseer.nvim {:call-setup overseer})
(use-package! :navarasu/onedark.nvim {:config (fn [] (local onedark (require :onedark))
                                               (onedark.setup {:style "darker"}))})


;; Send plugins to packer
(echo! "Installing Packages")
(unpack!)
