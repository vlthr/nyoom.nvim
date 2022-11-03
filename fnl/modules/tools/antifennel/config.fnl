;; mixed from:
;; https://github.com/elkowar/antifennel-nvim/blob/master/fnl/antifennel-nvim.fnl
;; and https://github.com/beardedsakimonkey/nvim-antifennel/blob/main/lua/antifennel.fnl
(local vtf (require :vtf))
(import-macros {: command!} :macros)

(fn antifennel-script []
  (local vendored (vtf.path.plugin :nvim-antifennel :vendor :antifennel))
  vendored)

(if (not vim.g.antifennel_executable)
    (set vim.g.antifennel_executable (antifennel-script)))

(fn antifennel [lua-code]
  (let [compiler-path (or vim.g.antifennel_executable :antifennel)
        tmpfile (vtf.io.tmpfile lua-code)
        output (vim.fn.system (.. compiler-path " " tmpfile))]
    (print "tmpfile: " (vtf.slurp tmpfile))
    (if (= 0 vim.v.shell_error)
        (values output true)
        (values (.. "[nvim-antifennel] " output) false))))

(fn get-selection []
  (let [[_ s-start-line s-start-col] (vim.fn.getpos "'<")
        [_ s-end-line s-end-col] (vim.fn.getpos "'>")
        n-lines (+ 1 (math.abs (- s-end-line s-start-line)))
        lines (vim.api.nvim_buf_get_lines 0 (- s-start-line 1) s-end-line false)]
    (tset lines 1 (string.sub (. lines 1) s-start-col -1))
    (if (= 1 n-lines)
        (tset lines n-lines
              (string.sub (. lines n-lines) 1 (+ 1 (- s-end-col s-start-col))))
        (tset lines n-lines (string.sub (. lines n-lines) 1 s-end-col)))
    (values s-start-line s-end-line lines)))

(fn convert [text]
  (let [(output ok) (antifennel text)]
    (if ok
        output
        (vim.api.nvim_err_write (.. output "\n")))))

(fn convert-selection []
  (let [(s-start s-end lua-code) (get-selection)
        fennel-code (vtf.string.split (convert (vtf.string.join "\n" lua-code))
                                      "\n")]
    (vim.api.nvim_buf_set_lines 0 (- s-start 1) s-end false fennel-code)))

(fn convert-clipboard []
  (let [lua-code (vtf.io.get-clipboard)
        fnl-code (convert lua-code)]
    (when fnl-code
      (vim.api.nvim_paste fnl-code true -1))
    fnl-code))

;; (fn antifennel-command []
;;   (match (vim.api.nvim_get_mode)
;;     :v ()))

(command! Antifennel convert-selection {:range true})
(command! AntifennelClipboard convert-clipboard {:range false})

{: antifennel : convert : convert-selection : convert-clipboard}
