(local neoclip (require :neoclip))

(neoclip.setup {:enable_persistent_history true
                :on_paste {:set_reg true} 
                :on_replay {:set_reg true} 
                :keys {:fzf {:custom {}
                                    :paste :ctrl-p
                                    :paste_behind :ctrl-k
                                    :select :default
                              :telescope {:i {:paste :<c-p>
                                              :select :<cr>
                                              :replay :<c-q>
                                              :paste_behind :<c-k>
                                              :custom {}
                                              :delete :<c-d>}
                                          :n {:paste :p
                                              :select :<cr>
                                              :replay :q
                                              :paste_behind :P
                                              :custom {}
                                              :delete :d}}}}})
