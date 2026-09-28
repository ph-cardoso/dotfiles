function zd --description 'Change to a directory or query zoxide'
    if test (count $argv) -eq 0
        cd
    else if test (count $argv) -eq 1; and test -d "$argv[1]"
        cd -- "$argv[1]"
    else if functions -q z
        z $argv
    else
        cd $argv
    end
end
