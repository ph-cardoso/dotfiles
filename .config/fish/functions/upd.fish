function upd --description 'Update native system packages and Homebrew if present'
    if command -q pacman
        if command -q paru
            command paru -Syu; or return
        else
            command sudo pacman -Syu; or return
        end
    else if command -q apt
        command sudo apt update; and command sudo apt upgrade; or return
    end
    if command -q brew
        command brew update; and command brew upgrade
    end
end
