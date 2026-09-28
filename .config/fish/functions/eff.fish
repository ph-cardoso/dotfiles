function eff --description 'Open fuzzy-selected files in the editor'
    set -l files (ff --print0 | string split0)
    if test (count $files) -gt 0
        set -l editor nvim
        if set -q EDITOR; and test -n "$EDITOR"
            set editor "$EDITOR"
        end
        command $editor $files
    end
end
