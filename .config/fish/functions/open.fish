function open --description 'Open a file or URL in the system application'
    if test (uname) = Darwin
        command open $argv
    else if command -q explorer.exe
        if string match -rq '^https?://' -- "$argv[1]"; and command -q wsl-chrome
            command wsl-chrome $argv
        else
            command explorer.exe $argv
        end
    else
        command xdg-open $argv >/dev/null 2>&1 &
    end
end
