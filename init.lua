if pcall(require, "hotpot") then
    -- Setup hotpot.nvim
    require("hotpot").setup({
        enable_hotpot_diagnostics = true,
        provide_require_fennel = true,
        compiler = {
            -- options passed to fennel.compile for modules, defaults to {}
            modules = {
                -- not default but recommended, align lua lines with fnl source
                -- for more debuggable errors, but less readable lua.
                correlate = true
            },
            -- options passed to fennel.compile for macros, defaults as shown
            macros = {
                env = "_COMPILER", -- MUST be set along with any other options
                -- you may wish to disable fennels macro-compiler sandbox in some cases,
                -- this allows access to tables like `vim` or `os` inside macro functions.
                -- See fennels own documentation for details on these options.
                compilerEnv = _G,
                allowGlobals = true,
            }
        }

    })
    -- Import neovim configuration
    --
    require("core")
else
    print("Unable to require hotpot")
end
