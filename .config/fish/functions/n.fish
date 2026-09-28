function n --wraps nvim --description 'Open Neovim in the current directory or on files'
    if test (count $argv) -eq 0
        command nvim .
    else
        command nvim $argv
    end
end
