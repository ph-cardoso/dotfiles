function eff --description 'Open fuzzy-selected files in the editor'
    set -l files (ff --print0 | string split0)
    if test (count $files) -gt 0
        command $EDITOR $files
    end
end
