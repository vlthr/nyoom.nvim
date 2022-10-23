(import-macros {: use-package! : let!} :macros)

(local cli (os.getenv :NYOOM_CLI))
(if cli (let! [g] auto_session_enabled false)) 

(use-package! :rmagatti/auto-session
              { :nyoom-module ui.auto-session})
                ;; :module "auto-session"
                ;; :cmds [:SaveSession :RestoreSession :RestoreSessionFromFile :DeleteSession :Autosession]})

