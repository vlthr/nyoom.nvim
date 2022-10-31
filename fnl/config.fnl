(require-macros :macros)
(local {: autoload} (require :core.lib.autoload))
(local vtele (autoload :vt.telescope))
(local search-repeat-change (autoload :vt.search-repeat-change))
(local trouble (autoload :trouble))
(tset _G :vtf (require :vtf))

(local init-commands-augroup
       (vim.api.nvim_create_augroup :init_commands {:clear true}))

(vim.api.nvim_create_autocmd :BufReadPost
                             {:command "if &ft !~# 'commit\\|rebase' && line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | execute \"normal! g`\\\"\" | endif"
                              :group init-commands-augroup
                              :pattern "*"
                              :once true})

                
;; (map! [nvo] :<space> "<NOP>")
;; (vim.cmd "unmap <space>")
(map! [i] :<F19> :<NOP>)
;; Place your private configuration here! Remember, you do not need to run 'nyoom
;; sync' after modifying this file!

;; You can use the `colorscheme` macro to load a custom theme, or load it manually
;; via require. This is the default:
(colorscheme onedark)

;; The set! macro sets vim.opt options. By default it sets the option to true 
;; Appending `no` in front sets it to false. This determines the style of line 
;; numbers in effect. If set to nonumber, line numbers are disabled. For 
;; relative line numbers, set 'relativenumber`
(set! number)
(set! cul) ;; cursorline
;; go to previous/next line with h,l,left arrow and right arrow)
;; when cursor reaches end/beginning of line)
;; (set! whichwrap+ "<>[]hl")
(set! clipboard "")
;; smartindent is automatic indentation, but disabled for pasting
(set! smartindent)

;; The let option sets global, or `vim.g` options. 
;; Heres an example with localleader, setting it to <space>m
(let! maplocalleader " m")

;; map! is used for mappings
;; Heres an example, preseing esc should also remove search highlights
(map! [n] "<esc>" "<esc><cmd>noh<cr>")

;; Poke around the Nyoom code for more! The following macros are also available:
;; contains? check if a table contains a value
;; custom-set-face! use nvim_set_hl to set a highlight value
;; set! set a vim option
;; local-set! buffer-local set!
;; command! create a vim user command
;; local-command! buffer-local command!
;; autocmd! create an autocmd
;; augroup! create an augroup
;; clear! clear events
;; packadd! force load a plugin from /opt
;; colorscheme set a colorscheme
;; map! set a mapping
;; buf-map! bufer-local mappings
;; let! set a vim global
;; echo!/warn!/err! emit vim notifications

(map! [nvsict] "<C-\\>b" "<cmd>Telescope buffers<CR>"
      {:desc "open buffer"})
(map! [nvsict] "<C-\\>f" "<cmd>Telescope current_buffer_fuzzy_find<CR>" {:desc "search buffer"})
(map! [nvsict] "<C-\\>p" "<cmd>Telescope frecency<CR>" {:desc "frecency"})
(map! [nvsict] "<C-\\>F" #(vtele.live_grep) {:desc "search project"})
(map! [n] "g/" #(vtele.grep_last_search) {:desc "grep last search"})
(map! [v] "#" (fn [] (search-repeat-change.visualstar :backwards true)) {:desc "visual star (backwards)"})
(map! [n] "#" "mz#`z" {:desc "star (backwards)"})
(map! [v] "*" (fn [] (search-repeat-change.visualstar)) {:desc "visual star"})
(map! [n] "*" "mz*`z" {:desc "star"})
(map! [i] "<C-.>" "<C-r>." {:desc "repeat insertion"})
(map! [v] "<" "<gv" {:desc "unindent"})
(map! [v] ">" ">gv" {:desc "indent"})
(map! [vs] "<C-\\>u" "<ESC>`<" {:desc "esc (first char)"})
(map! [i] "<C-\\>u" "<cmd>stopinsert<CR>" {:desc "esc right"})
(map! [n] "<C-\\>u" "<ESC>" {:desc "esc"})
(map! [o] "<C-\\>u" "<ESC>" {:desc "esc"})
(map! [c] "<C-\\>u" "<ESC>" {:desc "esc"})
(map! [n] "<S-Up>" "vk" {:desc "select up"})
(map! [vs] "<S-Up>" "k" {:desc "select up"})
(map! [i] "<S-Up>" "<C-o>vk" {:desc "select up"})
(map! [n] "<S-Down>" "vj" {:desc "select down"})
(map! [vs] "<S-Down>" "j" {:desc "select down"})
(map! [i] "<S-Down>" "<C-o>vj" {:desc "select down"})
(map! [n] "<S-Left>" "vh" {:desc "select left"})
(map! [vs] "<S-Left>" "h" {:desc "select left"})
(map! [i] "<S-Left>" "<ESC>v" {:desc "select left"})
(map! [n] "<S-Right>" "vlh" {:desc "select right"})
(map! [vs] "<S-Right>" "l" {:desc "select right"})
(map! [i] "<S-Right>" "<C-o>vlh" {:desc "select right"})
(map! [n] "<M-S-Left>" "hv<M-Left>" {:desc "select word left" :remap true})
(map! [vs] "<M-S-Left>" "<M-Left>" {:desc "select word left" :remap true})
(map! [n] "<M-S-Right>" "v<M-Right>" {:desc "select word right" :remap true})
(map! [vs] "<M-S-Right>" "<M-Right>" {:desc "select word right" :remap true})
(map! [n] "c*" "*Ncgn" {:desc "substitute last change"})
;; (map! [v] "p" "\"_dP" {:desc "paste (noclip)"})
;; (map! [v] "X" "\"_d" {:desc "delete (noclip)"})
(map! [v] "Y" "\"+y" {:desc "yank (clipboard)"})
(map! [n] "Y" "<cmd>let @+ = @0<CR>" {:desc "last yank to clipboard"})
(map! [n] "<leader>p" "\"+p" {:desc "p (clipboard)"})
(map! [n] "<leader>P" "\"+P" {:desc "P (clipboard)"})

;; (map! [n] "<leader>gd" '(vim.cmd.DiffviewFileHistory (vim.fn.expand "%") "--base=LOCAL") {:desc "diff file"})

(local readline (autoload "readline"))
(map! [nvsoitc] "<M-b>" #(readline.backward_word))
(map! [nvsoitc] "<M-Left>" #(readline.backward_word))
(map! [nvsoitc] "<M-f>" #(readline.forward_word))
(map! [nvsoitc] "<M-Right>" #(readline.forward_word))
(map! [c] "<C-a>" #(readline.beginning_of_line))
(map! [c] "<C-e>" #(readline.end_of_line))
(map! [nvsoit] "<C-a>" "<cmd>normal ^<CR>")
(map! [nvsoit] "<C-e>" #(readline.end_of_line))
(map! [nvitc] "<C-\\>w" #(readline.backward_kill_word))
(map! [itc] "∂" #(readline.kill_word))
(map! [itc] "<M-d>" #(readline.kill_word))
(map! [itc] "<C-w>" #(readline.backward_kill_word))


(map! [n] :<C-l> :<C-w>l {:desc " window right"})
(map! [n] :<leader>uv (fn []
                        ;; (local reload (require :plenary.reload))
                        (vim.cmd (.. ":Fnlsource " "/Users/von/.config/nvim/fnl/config.fnl"))
                        (print "reloaded mappings"))
      {:desc "Update nvim"})
(map! [n] :<C-h> :<C-w>h {:desc " window left"})
(map! [n] :<leader>ngn "<cmd> lua require'vt.telescope'.grep_nvim() <CR>"
      {:desc "grep neovim config"})
(map! [n] :<C-k> :<C-w>k {:desc " window up"})
(map! [n] :<leader>nfN "<cmd> lua require'vt.telescope'.find_nvim({nvchad=true}) <CR>"
      {:desc "find nvchad config"})
(map! [n] :<leader>nfc "<cmd> lua require'vt.telescope'.find_configs() <CR>"
      {:desc "find neovim config"})
(map! [n] :<M-Down> ":m .+1<CR>==" {:desc "move down"})
;; (map! [n] "]d" (fn [] (vim.diagnostic.goto_next)) {:desc "   goto_next"})
;; (map! [n] "[d" (fn []
;;                  (vim.diagnostic.goto_prev))
(map! [n] "[d" #(trouble.previous {:skip_groups true :jump true}))
(map! [n] "]d" #(trouble.next {:skip_groups true :jump true}))
(map! [n] :<M-S-Up> "V:copy .-1<CR>==" {:desc "copy up"})
(map! [n] :<leader>ngp "<cmd> lua require'vt.telescope'.grep_nvim_plugins() <CR>"
      {:desc "grep neovim plugins"})
(map! [n] :K (fn []
               (vim.lsp.buf.hover))
      {:desc "   lsp hover"}
      {:desc "   goto prev"})
(map! [n] :<C-j> :<C-w>j {:desc " window down"})
(map! [n] :<M-Up> ":m .-2<CR>==" {:desc "move up"})
(map! [n] :<leader>ngN "<cmd> lua require'vt.telescope'.grep_nvim({nvchad=true}) <CR>"
   {:desc "grep nvchad config"})
(map! [n] :<M-S-Down> "V:copy .+0<CR>==" {:desc "copy down"})
(map! [n] :<leader>nfn "<cmd> lua require'vt.telescope'.find_nvim() <CR>"
      {:desc "find neovim config"})
(map! [n] "<C-\\>." (fn [] (vim.lsp.buf.code_action)) {:desc "   lsp code_action"})
(map! [nv] "<C-\\>k" :<C-b> {:desc "page up"})
(map! [nv] "<C-\\>j" :<C-f> {:desc "page down"})
(map! [i] :<M-S-Down> "<ESC>V:copy .+0<CR>==" {:desc "copy down"})
(map! [i] :<M-Up> "<ESC>:m .-2<CR>==" {:desc "move up"})
(map! [i] :<M-S-Up> "<ESC>V:copy .-1<CR>==" {:desc "copy up"})
(map! [i] :<M-Down> "<ESC>:m .+1<CR>==" {:desc "move down"})
(map! [vs] :<M-S-Down> "V:copy '<-1<CR>gv=gv" {:desc "copy down"})
(map! [vs] :<M-Up> ":m '<-2<CR>gv=gv" {:desc "move up"})
(map! [vs] :<M-S-Up> "V:copy '>+1<CR>gv=gv" {:desc "copy up"})
(map! [vs] :<M-Down> ":m '>+1<CR>gv=gv" {:desc "move down"})
(map! [nvo] "]q" "<cmd>cnext<CR>" {:desc "next quickfix"})
(map! [nvo] "[q" "<cmd>cprev<CR>" {:desc "prev quickfix"})
(map! [nvsit] "<C-\\>q" (fn []
                          ((. (require :vt.quickfix) :toggle_qf)))
      {:desc "open quickfix list"})

;; TODO: map cmd-x in cmdline to C-r equivalent
(map! [nvsit] "<C-\\>x" "<cmd>Telescope command_history<CR>" {:desc "telescope command history"})

(fn go-struct-to-python []
  (vim.cmd "'<,'>s/^\\t/    /ge | '<,'>s://:#:ge | '<,'>v:\\v^\\s*(#|//|$):normal ^crsEa:^")
  (vim.cmd "normal gv")
  (vim.cmd "'<,'>g/\\v\\s*\\w+:/ '<,'>s:\\v\\[\\]\\*?(\\w+):ty.List[\\1]:ge | '<,'>s:\\vmap\\[\\*?(\\w+)\\](\\w+):ty.Dict[\\1, \\2]:ge | '<,'>s/*//ge | '<,'>s/\\v(\\s*\\w+:\\s*)\\*?string/\\1str/ge | '<,'>s/\\vu?int64/int/ge | '<,'>s/time.Time/NomadTimestamp/ge"))
(command! GoStructToPython go-struct-to-python {:range true})

(local nvim-restart-exit-code (tonumber (os.getenv :NVIM_RESTART_EXIT_CODE)))
(fn restart-nvim [] 
  (vim.cmd "SaveSession")
  (vim.cmd (.. "cquit " nvim-restart-exit-code)))
(when nvim-restart-exit-code
    (command! Restart restart-nvim {}))
