function ff --wraps fzf --description 'Fuzzy file selection with a bat preview'
    command fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}' $argv
end
