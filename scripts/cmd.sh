#!/bin/bash
# @AnAncientForce

restore_pth=""
gap="   "
valid_flag=false

restore_pth="~/.backup"

function trap_ctrlc() {
    echo -e ${BRed}"\n[!] The current operation has been stopped.\n" ${Color_Off}
    exit 2
}
trap "trap_ctrlc" 2

# ----------------------------- Flag Logic
help() {
    clear
    echo -e ${BPurple}"Available flags\n" ${Color_Off}
    echo -e ${BGreen}"[*] setup          : ?" ${Color_Off}
    echo -e ${BGreen}"[*] backup         : ?" ${Color_Off}
    echo -e ${BGreen}"[*] sd             : Launches Stable Diffusion" ${Color_Off}
    echo -e ${BGreen}"[*] comfy          : Launches ComfyUI" ${Color_Off}
    echo -e ${BGreen}"[*] ocr            : ?" ${Color_Off}
    echo -e ${BGreen}"[*] patch-spotify  : ?" ${Color_Off}
    echo -e ${BGreen}"[*] ch             : ?" ${Color_Off}
    exit 0
}
if [ "$1" = "h" ]; then
    help
fi
for arg in "$@"; do
    case "$arg" in
    setup)
        sudo pacman -S --noconfirm - < packages/pacman.txt
        yay -S --noconfirm - < packages/aur.txt
        sudo systemctl enable --now swayosd-libinput-backend.service
        sudo systemctl enable libvirtd
        sudo systemctl start libvirtd
        sudo systemctl status libvirtd
        sudo usermod -aG libvirt $(whoami)
        sudo usermod -aG kvm $(whoami)
        sudo usermod -a -G uucp USERNAME
        valid_flag=true
        ;;
    tr)
        mv ~/Downloads/*.jpg *.jpeg *.png *.gif /mnt/veracrypt1/forum/
        valid_flag=true
        ;;
    change-bg)
        WALLPAPER_DIRECTORY=~/Library/pictures/backgrounds
        WALLPAPER=$(find "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)

        hyprctl hyprpaper preload "$WALLPAPER"
        hyprctl hyprpaper wallpaper "DP-2,$WALLPAPER"
        hyprctl hyprpaper wallpaper "DP-1,$WALLPAPER"
        hyprctl hyprpaper wallpaper "HDMI-A-2,$WALLPAPER"

        sleep 1

        hyprctl hyprpaper unload unused

        wal -i "$WALLPAPER"
        valid_flag=true
        ;;
    backup)
        repo=~/Library/dev/archlinux/dotfiles-2025

        cd $repo

        rm -rf $repo/{.config,scripts,rules,packages}

        mkdir -p .config scripts rules packages

        cp -r ~/.config/hypr                $repo/.config
        cp -r ~/.config/nwg-panel           $repo/.config
        cp -r ~/.config/nwg-dock-hyprland   $repo/.config
        cp -r ~/.config/kitty               $repo/.config

        cp -r ~/Library/scripts/rules       $repo

        cp -r ~/Library/scripts/cmd.sh      $repo/scripts

        pacman -Qqen > packages/pacman.txt
        pacman -Qqem > packages/aur.txt

        date=$(date +%Y.%m.%d-%H.%M.%S)
        read -p "Create $date backup?
        (y/n): " choice
        if [ "$choice" = "y" ]; then
            tar -czf "/run/media/Z/My Passport/Library/Backups/archlinux/$date.tar.gz" -T ~/Library/scripts/rules/include.txt
        fi
        valid_flag=true
        ;;
    sd)
        ./Library/AI/stable-diffusion-webui/webui.sh
        valid_flag=true
        ;;
    patch-spotify)
        bash <(curl -sSL https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh)
        curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
        valid_flag=true
        ;;
    steam)
        nohup steam -forcedesktopscaling 1.75
        valid_flag=true
        ;;
    comfy)
        cd ~/Library/AI/ComfyUI
        source activate base
        conda activate comfyenv
        python main.py
        valid_flag=true
        ;;
    kh)
        URL="$2"
        cd ~/Library/Apps/khinsider/
        python khinsider.py --format flac '$URL'
        cd ~
        valid_flag=true
        ;;
    ch)
        cd ~/Library/scripts
        chmod +x *.sh
        cd ~
        valid_flag=true
        ;;
    off)
        shutdown now
        ;;
    ocr)
        OCR_FOLDER=~/OCR
        IMAGE_PATH="$OCR_FOLDER/$(date +%Y%m%d%H%M%S).png"

        mkdir -p "$OCR_FOLDER"
        grim -g "$(slurp)" "$IMAGE_PATH"
        tesseract -l eng "$IMAGE_PATH" "$OCR_FOLDER/output" && cat "$OCR_FOLDER/output.txt" | wl-copy

        valid_flag=true
        ;;
    sym)
        ln -s /mnt/veracrypt1/AI/stable-diffusion-webui/outputs ~/Library/AI/stable-diffusion-webui/outputs
        ln -s /mnt/veracrypt1/AI/ComfyUI/output ~/Library/AI/ComfyUI/output
        echo OK
        valid_flag=true
        ;;
    *) ;;
    esac
done
if ! $valid_flag; then
    # echo -e ${BRed}"\n[!] Incorrect or misspelled flag.\n\nProceeding with default...\n" ${Color_Off}
    if [ $# -eq 0 ]; then
        echo -e "${BRed}[!] No flags were supplied.\n${Color_Off}"
    else
        echo -e ${BRed}"[!] Incorrect or misspelled flag.\n" ${Color_Off}
    fi
    echo -e ${BBlue}"[?] Usage: cmd h" ${Color_Off}
    exit 2
fi
