function t --wraps tmux --description 'Attach to tmux or create the Work session'
    if test (count $argv) -gt 0
        command tmux $argv
    else
        command tmux attach; or command tmux new -s Work
    end
end
