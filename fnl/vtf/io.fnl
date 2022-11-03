(import-macros {: str? : tbl?} :macros)

(local vtf (require :vtf))

(local M {})

(fn M.get-clipboard []
  (vim.fn.getreg "+" nil))

(fn M.set-clipboard [contents]
  (assert (= :string (type contents)))
  (vim.fn.setreg "+" contents nil))

(fn M.tmpfile [contents]
  (let [tmp (vim.fn.tempname)]
    (if (= :table (type contents))
        (vtf.spit tmp (vtf.string.join "\n" contents))
        (vtf.spit tmp (or contents "")))
    tmp))

M
