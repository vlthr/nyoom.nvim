(local path {})
(local {: autoload} (require :core.lib.autoload))
(local s (autoload :vtf.string))
;; (import-macros {: dbg!} :macros)

(local plenary-path (autoload :plenary.path))

(fn path.exists? [p]
  (let [(ok err) (vim.loop.fs_stat p)]
    ok))

(fn path.directory? [p]
  (vim.fn.isdirectory p))

(fn path.file? [p]
  (and (path.exists? p) (not (path.directory? p))))

(fn path.readable? [p]
  (vim.fn.filereadable p))

(fn path.Path [...]
  ((. plenary-path "Path::new") ...))

(fn path.normalize [p]
  "Normalize a path to a standard format. A tilde (~) character at the beginning of
  the path is expanded to the user's home directory and any backslash (\\) characters
  are converted to forward slashes (/). Environment variables are also expanded."
  (vim.fs.normalize p))

(fn path.absolute [p]
  "absolute path (relative to cwd)"
  (vim.fn.fnamemodify p ":p"))

(fn path.parent [p]
  "last path component removed (\"head\")"
  (vim.fn.fnamemodify p ":h"))

(fn path.last [p]
  "last path component only (\"tail\")"
  (vim.fn.fnamemodify p ":t"))

(fn path.strip-ext [p]
  "one extension removed"
  (vim.fn.fnamemodify p ":r"))

(fn path.extension [p]
  "extension only (e.g. `\"fnl\"`)"
  (vim.fn.fnamemodify p ":e"))

(fn path.has-extension [p any-of]
  (var ext (path.extension p))
  (vim.tbl_contains any-of ext))

(fn path.components [s]
  "Split a path into components"
  (var done? false)
  (var acc [])
  (var index 1)
  (while (not done?)
    (let [(start end) (string.find s path.os-path-sep index)]
      (if (= :nil (type start))
          (do
            (let [component (string.sub s index)]
              (when (not (string.blank? component))
                (table.insert acc)))
            (set done? true))
          (do
            (let [component (string.sub s index (- start 1))]
              (when (not (string.blank? component))
                (table.insert acc)))
            (set index (+ end 1))))))
  acc)

(fn dbg! [out]
  (print (vim.inspect out))
  out)

(fn path.strip-prefix [p prefix]
  "Removes a path prefix if it exists"
  (var prefix-literal
       (s.escape-pattern (s.strip-suffix prefix path.os-path-sep)))
  (let [(stripped _) (string.gsub p
                                  (.. "^" prefix-literal path.os-path-sep "+"
                                      "(.-)")
                                  "%1")]
    stripped))

(fn path.strip-suffix [p suffix]
  "Removes a path suffix if it exists"
  (if (= nil suffix)
      (s.strip-suffix p path.os-path-sep)
      (do
        (var suffix-literal
             (s.escape-pattern (s.strip-prefix suffix path.os-path-sep)))
        (let [(stripped _) (string.gsub p
                                        (.. "(.-)" path.os-path-sep "+"
                                            suffix-literal)
                                        "%1")]
          stripped))))

(fn path.mkdirp [dir]
  (vim.fn.mkdir dir :p))

(fn path.expand [...]
  (vim.fn.expand ...))

(fn path.concat [...]
  (table.concat [...] path.os-path-sep))

(fn path.plugin [plugin ...]
  (let [opt-dir (path.stdpath :packer :opt plugin)
        start-dir (path.stdpath :packer :start plugin)]
    (print opt-dir)
    (print start-dir)
    (if (path.exists? start-dir) (path.concat start-dir ...)
        (path.exists? opt-dir) (path.concat opt-dir ...)
        nil)))

(fn path.stdpath [kind ...]
  "Get a subpath to a standard nvim path.
  (stdpath :config :lua/packer_compiled.lua)
  (stdpath :cache :lua/packer_compiled.lua)
  (stdpath :data :mason/bin)
  (stdpath :data :mason/bin)
  (stdpath :packer :opt/lazy-loaded-plugin/lua)
  (stdpath :packer :start/eager-loaded-plugin/lua)
  "
  (var base (match kind
              :mason (path.concat (vim.fn.stdpath :data) :mason)
              :mason-bin (path.concat (vim.fn.stdpath :data) :mason :bin)
              :mason-packages (path.concat (vim.fn.stdpath :data) :mason
                                           :packages)
              :mason-packages-build (path.concat (vim.fn.stdpath :data) :mason
                                                 :.packages)
              :packer (path.concat (. (require :packer) :config :package_root)
                                   :packer)
              _ (vim.fn.stdpath kind)))
  (path.concat base ...))

(fn path.file-to-module [fnl-or-lua]
  (assert (path.has-extension fnl-or-lua [:fnl :lua]))
  (-> fnl-or-lua
      (path.absolute)
      (path.normalize)
      ;; TODO: symlinked files are not always resolved within config path
      (path.strip-prefix (vim.fn.expand "~/bb/nyoom/fnl"))
      (path.strip-prefix (vim.fn.expand "~/bb/nyoom/lua"))
      (path.strip-prefix (path.stdpath :config :lua))
      (path.strip-prefix (path.stdpath :config :fnl))
      (path.strip-suffix :init.lua)
      (path.strip-suffix :init.fnl)
      (path.strip-suffix)
      (string.gsub path.os-path-sep ".")))

(tset path :os-path-sep
      ;; https://github.com/nvim-lua/plenary.nvim/blob/8bae2c1fadc9ed5bfcfb5ecbd0c0c4d7d40cb974/lua/plenary/path.lua#L20-L31
      (let [os (string.lower jit.os)]
        (if (or (= :linux os) (= :osx os) (= :bsd os)) "/" "\\")))

path
