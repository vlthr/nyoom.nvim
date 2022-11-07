(import-macros {: set! : nyoom-module-p!} :macros)
(local {: autoload} (require :core.lib.autoload))
(local cmp (autoload :cmp))
(local luasnip (autoload :luasnip))

(set! completeopt [:menu :menuone :noselect])

(local sources [])

;; add general cmp sources
(table.insert sources {:name :luasnip :group_index 1})
(table.insert sources {:name :buffer :group_index 2})
(table.insert sources {:name :path :group_index 2})

;; add conditional sources
(nyoom-module-p! lsp (table.insert sources {:name :nvim_lsp :group_index 1}))
(nyoom-module-p! rust (table.insert sources {:name :crates :group_index 1}))
(nyoom-module-p! eval (table.insert sources {:name :conjure :group_index 1}))

;; default icons (lspkind)
(local icons {:Text ""
              :Method ""
              :Function ""
              :Constructor "⌘"
              :Field "ﰠ"
              :Variable ""
              :Class "ﴯ"
              :Interface ""
              :Module ""
              :Unit "塞"
              :Property "ﰠ"
              :Value ""
              :Enum ""
              :Keyword "廓"
              :Snippet ""
              :Color ""
              :File ""
              :Reference ""
              :Folder ""
              :EnumMember ""
              :Constant ""
              :Struct "פּ"
              :Event ""
              :Operator ""
              :TypeParameter ""})

;; (fn border [hl-name]
;;   [["╭" hl-name]
;;    ["─" hl-name]
;;    ["╮" hl-name]
;;    ["│" hl-name]
;;    ["╯" hl-name]
;;    ["─" hl-name]
;;    ["╰" hl-name]
;;    ["│" hl-name]])
(fn border [hl-name]
  :solid)

(local cmp-window (require :cmp.utils.window))

;; (set cmp-window.info_ cmp-window.info)

;; (set cmp-window.info (fn [self]
;;                        (let [info (self:info_)]
;;                          ;; (set info.scrollable false)
;;                          info)))

(cmp.setup {:experimental {:ghost_text true}
            :window {:documentation {:border (border :CmpDocBorder)
                                     :max_height 30}
                     :completion {:border (border :CmpBorder)
                                  :max_height 30
                                  :scrolloff 5}}
            :view {:entries {:name :custom :selection_order :near_cursor}}
            :preselect cmp.PreselectMode.None
            :snippet {:expand (fn [args]
                                (luasnip.lsp_expand args.body))}
            :mapping {:<C-b> (cmp.mapping.scroll_docs -4)
                      :<C-f> (cmp.mapping.scroll_docs 4)
                      :<C-space> (cmp.mapping.complete)
                      :<C-c> (fn [fallback]
                               (if (cmp.visible)
                                   (do
                                     (cmp.mapping.close)
                                     (vim.cmd :stopinsert))
                                   (fallback)))
                      :<up> (cmp.mapping.select_next_item)
                      :<down> (cmp.mapping.select_prev_item)
                      :<Tab> (cmp.mapping (fn [fallback]
                                            (if (cmp.visible)
                                                (cmp.select_next_item)
                                                (luasnip.expand_or_jumpable)
                                                (luasnip.expand_or_jump)
                                                (fallback)))
                                          [:i :s :c])
                      :<S-Tab> (cmp.mapping (fn [fallback]
                                              (if (cmp.visible)
                                                  (cmp.select_prev_item)
                                                  (luasnip.jumpable -1)
                                                  (luasnip.jump -1)
                                                  (fallback)))
                                            [:i :s :c])
                      :<CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Replace
                                                  :select false})
                      :<space> (cmp.mapping.confirm {:select false})}
            : sources
            :formatting {:fields {1 :kind 2 :abbr 3 :menu}
                         :format (fn [_ vim-item]
                                   (set vim-item.menu vim-item.kind)
                                   (set vim-item.kind (. icons vim-item.kind))
                                   vim-item)}})

;; Enable command-line completions
(cmp.setup.cmdline "/"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :buffer :group_index 1}]})

;; Enable search completions
(cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :path} {:name :cmdline :group_index 1}]})

;; snippets
((. (require :luasnip.loaders.from_vscode) :lazy_load))
;; loads all `luasnippets` folders on rtp (can pass `{:paths ...} to override)
((. (require :luasnip.loaders.from_lua) :lazy_load))

(nyoom-module-p! completion.copilot
                 (cmp.event:on :menu_opened
                               (fn []
                                 (set vim.b.copilot_suggestion_hidden true)))
                 (cmp.event:on :menu_closed
                               (fn []
                                 (set vim.b.copilot_suggestion_hidden false))))
