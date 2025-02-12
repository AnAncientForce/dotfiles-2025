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
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yay --version
        cd ~
        sudo pacman -S --noconfirm - <packages/pacman.txt
        yay -S --noconfirm - <packages/aur.txt
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
        WALLPAPER_DIRECTORY=~/Library/hyprpaper
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
    bk)
        repo=~/Library/dev/archlinux/dotfiles-2025

        cd $repo

        rm -rf $repo/{.config,scripts,packages,local}

        mkdir -p .config scripts scripts/packages .local/share

        cp -r ~/.config/hypr $repo/.config
        cp -r ~/.config/waybar $repo/.config
        cp -r ~/.config/kitty $repo/.config
        cp -r ~/.config/vkBasalt $repo/.config
        cp -r ~/.config/easyeffects $repo/.config

        cp -r ~/.local/share/reshade $repo/.local/share

        cp -r ~/Library/scripts/cmd.sh $repo/scripts

        pacman -Qqen >$repo/scripts/packages/pacman.txt
        pacman -Qqem >$repo/scripts/packages/aur.txt

        date=$(date +%Y.%m.%d-%H.%M.%S)
        read -p "Create $date backup?
        (y/n): " choice
        if [ "$choice" = "y" ]; then
            tar -czf "/run/media/Z/My Passport/Library/Backups/archlinux/$date.tar.gz" -T ~/Library/scripts/include.txt
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
    open-webui)
        source activate base
        conda activate openenv
        open-webui serve
        valid_flag=true
        ;;
    kh)
        URL="$2"
        cd ~/Library/apps/khinsider/
        python khinsider.py --format flac "$URL"
        # --format flac
        cd ~
        valid_flag=true
        ;;
    kh-batch)
        URL="$2"
        cd ~/Library/apps/khinsider/
        while read -r line; do
            if [[ "$line" != "" && "$line" != \#* ]]; then
                python khinsider.py --format flac "$line"
            fi
        done <~/Library/scripts/music.txt
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
    bt)
        bluetoothctl connect 90:62:3F:97:DC:C1
        valid_flag=true
        ;;
    sensor)
        stty -F /dev/ttyACM0 9600 raw
        count=0
        cat /dev/ttyACM0 | while read -n1 char; do
            if [ "$char" = "o" ]; then
                count=$((count + 1))
                [ "$count" -eq 1 ] && continue
                echo "Detected 'o'"
                playerctl pause
            fi
        done
        valid_flag=true
        ;;
    waydroid-start)
        waydroid prop set persist.waydroid.width 1080  # you must run this in terminal while waydroid is running
        waydroid prop set persist.waydroid.height 1920 # you must run this in terminal while waydroid is running
        waydroid session stop
        echo "About to launch full ui... (3 secs waiting)"
        sleep 3
        waydroid prop set persist.waydroid.width 1080
        waydroid prop set persist.waydroid.height 1920
        sleep 1
        waydroid show-full-ui &
        sleep 1
        waydroid prop set persist.waydroid.width 1080
        waydroid prop set persist.waydroid.height 1920
        sleep 1

        valid_flag=true
        ;;
    waydroid-stop)
        waydroid session stop
        valid_flag=true
        ;;
    droid-1)
        pkill scrcpy
        adb shell wm density 320
        # adb shell wm size 1920x1080
        # adb shell settings put system screen_brightness 1
        scrcpy --video-codec=h265 --video-bit-rate=24M --max-fps=60 --stay-awake &
        # scrcpy --video-codec=h265 --video-bit-rate=24M --max-fps=144 --turn-screen-off --stay-awake &
        # https://github.com/Genymobile/scrcpy/blob/master/doc/device.md
        valid_flag=true
        ;;
    droid-0)
        pkill scrcpy
        adb shell wm density reset
        adb shell wm size reset
        adb shell settings put system screen_brightness 50
        valid_flag=true
        ;;
    rc-bose)
        dunstify 'Disconnect'
        bluetoothctl disconnect AC:BF:71:91:31:D5
        sleep 5
        dunstify 'Re-Connect'
        bluetoothctl connect AC:BF:71:91:31:D5
        sleep 5
        dunstify 'OK'
        pactl set-sink-volume @DEFAULT_SINK@ 50%
        valid_flag=true
        ;;
    bose-fix)
        while true; do
            if bluetoothctl info "AC:BF:71:91:31:D5" | grep -q "Connected: yes"; then
                pkill play
                VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')

                if [ "$VOLUME" -ge 75 ]; then
                    play -n synth whitenoise vol 0.0003 remix 1 0 &
                elif [ "$VOLUME" -ge 50 ]; then
                    play -n synth whitenoise vol 0.0006 remix 1 0 &
                elif [ "$VOLUME" -ge 25 ]; then
                    play -n synth whitenoise vol 0.0009 remix 1 0 &
                fi
            else
                pkill play
            fi
            sleep 60
        done

        valid_flag=true
        ;;
    ev)
        # cmd ev '/run/media/Z/E7FF-F652/Library/motorola edge 30 ultra/DCIM/QuickVideoRecorder/QVR_2025_02_06_14_19_22.mp4' '/home/Z/Library/test/b'
        ffmpeg -i "$2" -qscale:v 2 "$3/output_%03d.jpg"
        valid_flag=true
        ;;
    eth-up)
        sudo ip link set enp14s0 up
        valid_flag=true
        ;;
    eth-down)
        sudo ip link set enp14s0 down
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
