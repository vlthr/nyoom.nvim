(local M {})

; TODO: extract and refactor
(fn M.map-normal [opts]
    (vim.fn.setreg :z opts.args nil)
    (local last-search (vim.fn.getreg "/" nil))
    (local start-pos (vim.fn.getcurpos))
    (vim.cmd "normal gg")
    (var ___match___ (vim.fn.searchpos last-search :cW nil nil))
    (while (not= (. ___match___ 1) 0)
      (vim.cmd (.. "normal " opts.args))
      (vim.cmd :stopinsert)
      (set ___match___ (vim.fn.searchpos last-search :W nil nil)))
    (vim.fn.setpos "." start-pos))

  



(fn M.get_marked_region [mark1 mark2 options]
  (let [bufnr 0
        adjust (or options.adjust
                   (fn [pos1 pos2]
                     (values pos1 pos2)))
        regtype (or options.regtype (vim.fn.visualmode))
        selection (or options.selection (not= vim.o.selection :exclusive))]
    (var pos1 (vim.fn.getpos mark1))
    (var pos2 (vim.fn.getpos mark2))
    (set (pos1 pos2) (adjust pos1 pos2))
    (local start [(- (. pos1 2) 1) (+ (- (. pos1 3) 1) (. pos1 4))])
    (local finish [(- (. pos2 2) 1) (+ (- (. pos2 3) 1) (. pos2 4))])
    (when (or (< (. start 2) 0) (< (. finish 1) (. start 1)))
      (lua "return "))
    (local region (vim.region bufnr start finish regtype selection))
    (values region start finish)))


(fn M.to_search_pattern [text opts]
  (set-forcibly! opts (or opts {}))
  (when (not text)
    (lua "return nil"))
  (local search-char (or opts.search_char "/"))
  (local word (or opts.word false))
  (local case (or opts.case true))
  (var pattern (vim.fn.escape text "\\"))
  (set pattern (vim.fn.escape pattern (.. search-char "\n")))
  (when word
    (set pattern (.. "\\<" pattern "\\>")))
  (when case
    (set pattern (.. "\\C" pattern)))
  (set pattern (.. "\\V" pattern))
  pattern)

(fn M.feedkeys [keys opts]
  (set-forcibly! opts (or opts {}))
  (local remap (or opts.remap false))
  (var mode "")
  (if remap (set mode (.. mode :m)) (set mode (.. mode :n)))
  (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes keys true false true)
                         mode true))

(fn M.file_dir_or_cwd []
  (or (vim.fn.expand "%:p:h") (vim.fn.getcwd)))
