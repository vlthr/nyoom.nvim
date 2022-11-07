(let [built-ins [:gzip
                 :zip
                 :zipPlugin
                 :tar
                 :tarPlugin
                 :getscript
                 :getscriptPlugin
                 :vimball
                 :vimballPlugin
                 :2html_plugin
                 :matchit
                 :matchparen
                 :logiPat
                 :rrhelper
                 :netrw
                 :netrwPlugin
                 :netrwSettings
                 :netrwFileHandlers]
      providers [:perl :node :ruby :python :python3]]
  (each [_ v (ipairs built-ins)]
    (let [plugin (.. :loaded_ v)]
      (tset vim.g plugin 1)))
  (each [_ v (ipairs providers)]
    (let [provider (.. :loaded_ v :_provider)]
      (tset vim.g provider 0))))

;; add language servers to path
(set vim.env.PATH (.. vim.env.PATH ":" (vim.fn.stdpath :data) :/mason/bin))

(tset _G :R (fn [...]
              (let [pr (require :plenary.reload)
                    mods [...]]
                (each [_ m (ipairs mods)]
                  (pr.reload_module m))
                (print "Reloaded " (vim.inspect mods)))))

(tset _G :P (fn [a]
              (let [fennel (require :fennel)]
                (print (fennel.view a)))))

(import-macros {: packadd!} :macros)

;; Load packer
;; (echo! "Loading Packer")
;; (tset package.loaded :packer nil)
;; (packadd! packer.nvim)
;; (require :packer)

(local cli (os.getenv :NYOOM_CLI))
(include :fnl.modules)

;; load packer if its available
(if (= (vim.fn.filereadable (.. (vim.fn.stdpath :config)
                                :/lua/packer_compiled.lua)) 1)
    (require :packer_compiled))

;; userconfig
(if cli
    (require :packages)
    (do
      ;; (require :modules)
      (require :modules)
      (require :config)))
