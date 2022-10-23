(import-macros {: use-package!} :macros)

(use-package! :sindrets/diffview.nvim
              {:nyoom-module ui.diffview
               :module "diffview"
               :cmd [ "DiffviewFileHistory" "DiffviewOpen" "DiffviewClose" "DiffviewToggleFiles" "DiffviewFocusFiles" "DiffviewRefresh"]})
