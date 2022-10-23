(local {: setup} (require :formatter))

(setup {:filetype {:c [(. (require :formatter.filetypes.c) :clangformat)]
                   :cpp [(. (require :formatter.filetypes.cpp) :clangformat)]
                   :lua [(. (require :formatter.filetypes.lua) :stylua)]
                   :typescript [(. (require :formatter.filetypes.typescript) :prettier)]
                   :vue [(. (require :formatter.filetypes.typescript) :prettier)]
                   :rust [(. (require :formatter.filetypes.rust) :rustfmt)]
                   :markdown [(. (require :formatter.filetypes.markdown) :prettier)]
                   :sh [(. (require :formatter.filetypes.sh) :shfmt)]
                   :python [(. (require :formatter.filetypes.python) :black)]
                   :zig [(. (require :formatter.filetypes.zig) :zigfmt)]}})
