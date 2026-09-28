function sff --description 'Send fuzzy-selected files to an scp destination'
    if test (count $argv) -ne 1
        printf 'Usage: sff host:/destination\n' >&2
        return 2
    end
    set -l files (ff --print0 | string split0)
    if test (count $files) -gt 0
        command scp -- $files "$argv[1]"
    end
end
