(import-macros {: nyoom-module-p! : packadd!} :macros)
(local {: autoload} (require :core.lib.autoload))
(local lsp (autoload :lspconfig))
(local {: deep-merge} (autoload :core.lib.tables))
(local install-root-dir (.. (vim.fn.stdpath :data) :mason))
(local lsp-util (autoload :lspconfig.util))
(local vtf (autoload :vtf))
(vim.fn.sign_define :DiagnosticSignError {:text "" :texthl :DiagnosticSignError})
(vim.fn.sign_define :DiagnosticSignWarn {:text "" :texthl :DiagnosticSignWarn})
(vim.fn.sign_define :DiagnosticSignInfo {:text "" :texthl :DiagnosticSignInfo})
(vim.fn.sign_define :DiagnosticSignHint {:text "" :texthl :DiagnosticSignHint})

;;; Improve UI
(set vim.lsp.handlers.textDocument/signatureHelp
      (vim.lsp.with vim.lsp.handlers.signature_help {:border :solid}))
(set vim.lsp.handlers.textDocument/hover
     (vim.lsp.with vim.lsp.handlers.hover {:border :solid}))

(fn on-attach [client bufnr]
  (import-macros {: buf-map! : autocmd! : augroup! : clear! : contains?} :macros)

  ;; Keybindings
  (local {:hover open-doc-float!
          :declaration goto-declaration!
          :definition goto-definition!
          :type_definition goto-type-definition!
          :code_action open-code-action-float!
          :references goto-references!
          :rename rename!} vim.lsp.buf)

  (buf-map! [n] "K" open-doc-float!)
  (buf-map! [nv] "<leader>a" open-code-action-float!)
  (buf-map! [nv] "<leader>rn" rename!)
  (buf-map! [n] "<leader>gD" goto-declaration!)
  (buf-map! [n] "gD" goto-declaration!)
  (buf-map! [n] "<leader>gd" goto-definition!)
  (buf-map! [n] "gd" goto-definition!)
  (buf-map! [n] "<leader>gt" goto-type-definition!)
  (buf-map! [n] "gt" goto-type-definition!)
  (buf-map! [n] "<leader>gr" goto-references!)
  (buf-map! [n] "gr" goto-references!)

  ;; Enable lsp formatting if available 
  (nyoom-module-p! format.+onsave
    (when (client.supports_method "textDocument/formatting")
      (augroup! lsp-format-before-saving
        (clear! {:buffer bufnr})
        (autocmd! BufWritePre <buffer>
          '(vim.lsp.buf.format {:filter (fn [client] (not (contains? [:jsonls :tsserver] client.name)))
                                :bufnr bufnr})
          {:buffer bufnr})))))

;; What should the lsp be demanded of?
(local capabilities (vim.lsp.protocol.make_client_capabilities))
(set capabilities.textDocument.completion.completionItem
     {:documentationFormat [:markdown :plaintext]
      :snippetSupport true
      :preselectSupport true
      :insertReplaceSupport true
      :labelDetailsSupport true
      :deprecatedSupport true
      :commitCharactersSupport true
      :tagSupport {:valueSet {1 1}}
      :resolveSupport {:properties [:documentation
                                    :detail
                                    :additionalTextEdits]}})

;;; Setup servers
(local defaults {:on_attach on-attach
                 : capabilities
                 :flags {:debounce_text_changes 150}})

;; conditional lsp servesr
(local lsp-servers {})

(tset lsp-servers :volar {:filetypes [:typescript
                                        :javascript
                                        :javascriptreact
                                        :typescriptreact
                                        :vue
                                        :json]
                          :init_options {:typescript {
                                                      :serverPath "onlyIncludedForOldVersion" 
                                                      :tsdk (vtf.path.stdpath 
                                                              :mason-packages 
                                                              :typescript-language-server 
                                                              :node_modules 
                                                              :typescript 
                                                              :lib)}}})

(nyoom-module-p! clojure
  (tset lsp-servers :clojure-lsp {}))

(nyoom-module-p! java
  (tset lsp-servers :jdtls {}))

(nyoom-module-p! sh
  (tset lsp-servers :bashls {}))

(nyoom-module-p! julia
  (tset lsp-servers :julials {}))

(nyoom-module-p! kotlin
  (tset lsp-servers :kotlin_language_server {}))

(nyoom-module-p! latex
  (tset lsp-servers :texlab {}))

(nyoom-module-p! markdown
  (tset lsp-servers :marksman {}))

(nyoom-module-p! nim
  (tset lsp-servers :nimls {}))

(nyoom-module-p! nix
  (tset lsp-servers :rnix {}))

(nyoom-module-p! python
  (tset lsp-servers :pyright {:root_dir (lsp-util.root_pattern ["pyrightconfig.json"])
                              :settings { :python {:analysis 
                                                    {:autoImportCompletions true
                                                     :useLibraryCodeForTypes true 
                                                     :disableOrganizeImports false}}}}))

(nyoom-module-p! zig
  (tset lsp-servers :zls {}))


;; for trickier servers you can change up the defaults
(nyoom-module-p! lua
  (local neodev (autoload :neodev))
  (neodev.setup {})
                 
  (lsp.sumneko_lua.setup { :settings {:Lua {:diagnostics {:globals {1 :vim}}
                                            :workspace {:library {(vim.fn.expand :$VIMRUNTIME/lua) true
                                                                  (vim.fn.expand :$VIMRUNTIME/lua/vim/lsp) true}
                                                        :maxPreload 100000
                                                        :preloadFileSize 10000}}}}))

(local null-ls (autoload :null-ls))
(null-ls.setup {:sources [null-ls.builtins.formatting.black
                          null-ls.builtins.diagnostics.flake8
                          null-ls.builtins.formatting.prettier
                          null-ls.builtins.formatting.isort]})
;; Load lsp
(let [servers lsp-servers]
  (each [server server_config (pairs servers)]
    ((. (. lsp server) :setup) (deep-merge defaults server_config))))


{: on-attach}
