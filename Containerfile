#       !`              @                            ☆ﾟ.*･｡ﾟXeniaOS ﾟ｡･*.ﾟ☆
#      @```b        @@@@@                         Arch/CachyOS Bootc | Niri
#     @`````@     @/@@@@                         DMS | Gaming On Linux | Bazaar
#    @@``'))))))))))C@@                       Starship | Ptyxis | Dolphin on Niri
#   @@@){)))))())))))))                              ☆ﾟ.Flatpaks | FOSS.ﾟ☆
#    @r))))@oooo)))))h)))[                                 
#    rr)))joooooo(xooooo@)
# rrrxr))r/l;,,,z@{,,,,,@@                         One container file to rule them all!
#   rr  )        v  @;@rx                             Trans rights are human rights!
#     rrr)    \__^__/   ji                                Xenia means helping and supporting each other.
#      rj].           . r
#      [[]]11111111111111111]
#     ][[[]]][11111111111111111<                                   XeniaOS
#     ][[[[[]]]]]]]]]]]]]]-111111[            ⚧ Xenia Demonheart ☭ the transfem package fox
#     ]-[[[[[[;]]]]]]]]]]]]]]]]   1                    Programmers @tulilirockz @hecknt
#     ]][[[[[[[[[[[]]]]]]]]]]]]]                Artists Jasper Valery | Delphic Melody | Chimmie Firefly
#     1]][[[[[[[[[[[[[[<]]]]]]]]]                           videorelaxant6025 | @b-
#      11]]][[[[[[[[[[[[[[[]]]]]]]                         
#       111]]]]'[[[[[[[[[[[[[[]]]]
#         111-]]]]][[[[[[[[[[[[[]]  Software that makes this OS possible - Distros/software for inspiration and whose members helped in some way
#           11111]]]]]_[[[[[[[[[[]               Arch | CachyOS | Bootc | Aurora | Bazzite | Bluebuild | Zirconium | Bluefin
#               11111]]]i[[[[[[[[                          Docker | Podman | Fedora | Proton | Wine | Ubuntu
#                  1111]]+[[[[[[^                                @kylegospo @valerie-tar-gz @cyrv6737
#                    11 ]][[[[[[
#                    11 +][[[[
#                    1   ][[
#                       `            Credit art: Cathodegaytube for original art, @catumin for ascii-ification

FROM docker.io/cachyos/cachyos-v3:latest AS final
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
ENV DRACUT_NO_XATTR=1

# ✩₊˚.⋆☾𓃦☽⋆⁺₊✧ Index
# Section 1 - Package Installs
# Section 2 - Package List
# Section 3 - Chaotic AUR / AUR
# Section 4 - Flatpaks preinstalls
# Section 5 - Linux OS Stuffs
# Section 6 - Systemd n Services
# Section 7 - CachyOS Settings
# Section 8 - Niri/Chezmoi/DMS
# Section 9 - Final Bootc Setup

########################################################################################################################################
# Section 1 - Package Installs | We grab every package we can from official arch repo/set up all non-flatpak apps for user ^^ ##########
########################################################################################################################################

# Move everything from `/var` to `/usr/lib/sysimage` so behavior around pacman remains the same on `bootc usroverlay`'d systems
RUN grep "= */var" /etc/pacman.conf | sed "/= *\/var/s/.*=// ; s/ //" | xargs -n1 sh -c 'mkdir -p "/usr/lib/sysimage/$(dirname $(echo $1 | sed "s@/var/@@"))" && \
mv -v "$1" "/usr/lib/sysimage/$(echo "$1" | sed "s@/var/@@")"' '' && \
    sed -i -e "/= *\/var/ s/^#//" -e "s@= */var@= /usr/lib/sysimage@g" -e "/DownloadUser/d" /etc/pacman.conf

# Set it up such that pacman is always cleaned after installs
RUN echo -e "[Trigger]\n\
Operation = Install\n\
Operation = Upgrade\n\
Type = Package\n\
Target = *\n\
\n\
[Action]\n\
Description = Cleaning up package cache...\n\
Depends = coreutils\n\
When = PostTransaction\n\
Exec = /usr/bin/rm -rf /var/cache/pacman/pkg" > /usr/share/libalpm/hooks/package-cleanup.hook

# Initialize the database
RUN pacman -Syu --noconfirm

# Use the Arch mirrorlist that will be best at the moment for both the containerfile and user too! Fox will help!
RUN pacman -S --noconfirm reflector

# Base packages \ Linux Foundation \ Foss is love, foss is life! We split up packages by category for readability, debug ease, and less dependency trouble
RUN pacman -S --noconfirm base linux-firmware dracut linux-cachyos-bore ostree systemd btrfs-progs e2fsprogs xfsprogs binutils dosfstools skopeo dbus dbus-glib glib2 shadow cpio

# Media/Install utilities/Media drivers
RUN pacman -S --noconfirm librsvg libglvnd qt6-multimedia-ffmpeg plymouth acpid ddcutil dmidecode mesa-utils ntfs-3g \
      vulkan-tools wayland-utils playerctl rsync

# Fonts
RUN pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-cjk noto-fonts-emoji unicode-emoji

# CLI Utilities
RUN pacman -S --noconfirm sudo bash bash-completion fastfetch btop jq less lsof nano openssh powertop man-db wget yt-dlp \
      tree usbutils vim cliphist unzip ptyxis glibc-locales tar udev starship tuned-ppd tuned hyfetch curl patchelf 

# Virtualization \ Containerization
RUN pacman -S --noconfirm distrobox docker podman

# Drivers \ "Business, business, business! Numbersss."
RUN pacman -S --noconfirm amd-ucode intel-ucode efibootmgr shim mesa lib32-mesa libva-intel-driver libva-mesa-driver \
    vpl-gpu-rt vulkan-icd-loader vulkan-intel vulkan-radeon apparmor xf86-video-amdgpu lib32-vulkan-radeon zram-generator \
    lm_sensors intel-media-driver dotnet-runtime bluez bluez-utils

# Network / VPN / SMB / storage
RUN pacman -S --noconfirm libmtp nss-mdns samba smbclient networkmanager firewalld udiskie udisks2

# Accessibility
RUN pacman -S --noconfirm espeak-ng orca

# Pipewire
RUN pacman -S --noconfirm pipewire pipewire-pulse pipewire-zeroconf pipewire-ffado pipewire-libcamera sof-firmware wireplumber \
    alsa-firmware lib32-pipewire pipewire-audio linux-firmware-intel

# Printer
RUN pacman -S --noconfirm cups cups-browsed hplip

# Desktop Environment needs
RUN pacman -S --noconfirm greetd xwayland-satellite xdg-desktop-portal-kde xdg-desktop-portal xdg-user-dirs xdg-desktop-portal-gnome \
      ffmpegthumbs kdegraphics-thumbnailers kdenetwork-filesharing kio-admin chezmoi matugen accountsservice quickshell dgop cava dolphin \ 
      breeze brightnessctl ddcutil xdg-utils kservice5 archlinux-xdg-menu shared-mime-info kio glycin greetd-regreet gnome-themes-extra

# User frontend programs/apps
RUN pacman -S --noconfirm steam gamescope scx-scheds scx-manager gnome-disk-utility mangohud lib32-mangohud

#######################################################################################################################################################
# Section 2 - Package List | For my info and yours too! No secrets here. | Enjoy your life, and love everyone around you as much as possible ########
#######################################################################################################################################################

# -Package list- Chaotic-AUR precompiled packages
# niri-git | flatpak-git | dms-shell-git | opentabletdriver | bootc | coolercontrol

# Arch apps
# Dolphin | Chezmoi | Gnome-Disks | Docker | Podman | SCX Manager | Steam | Mangohud | Gamescope

# Flatpaks
# Bazaar | Firefox | Krita | Elisa | Pinta | OBS | Ark | Faugus Launcher | ProtonPlus | Kdenlive |
# Okular | Kate | Warehouse | Fedora Media Writer | Gear Lever | Haruna | Gwenview
# Audacity | Not Tetris 2 | Resources | Discord

##############################################################################################################################################
# Section 3 - Chaotic AUR / AUR # We grab some precompiled packages from the Chaotic AUR for things not on Arch repos/better updated~ ovo ####
##############################################################################################################################################

# Chaotic AUR repo
RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
RUN pacman-key --init && pacman-key --lsign-key 3056513887B78AEB
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
RUN echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf
# Hec's Bootc repo
RUN pacman-key --recv-key 5DE6BF3EBC86402E7A5C5D241FA48C960F9604CB --keyserver keyserver.ubuntu.com
RUN pacman-key --lsign-key 5DE6BF3EBC86402E7A5C5D241FA48C960F9604CB
RUN echo -e '[bootc]\nSigLevel = Required\nServer=https://github.com/hecknt/arch-bootc-pkgs/releases/download/$repo' >> /etc/pacman.conf

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm \
    chaotic-aur/niri-git chaotic-aur/flatpak-git chaotic-aur/darkly-qt6-git chaotic-aur/bootc \
    chaotic-aur/dms-shell-git chaotic-aur/opentabletdriver chaotic-aur/qt6ct-kde chaotic-aur/coolercontrold

RUN pacman -S --noconfirm \
  bootc/uupd && \
  systemctl enable uupd.timer

#######################################################################################################################################################
# Section 4 - Flatpaks preinstalls | Don't forget. Always, somewhere, someone is fighting for you. You are not alone. -Madoka Magica ##################
#######################################################################################################################################################

RUN mkdir -p /usr/share/flatpak/preinstall.d/

# Krita | Image editing + arting!
RUN echo -e "[Flatpak Preinstall org.kde.krita]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Krita.preinstall

# Elisa | Music player~
RUN echo -e "[Flatpak Preinstall org.kde.elisa]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Elisa.preinstall

# Pinta | Image editing! They set out a bit to match paint.net/paintdotnet, it does okay at that.
RUN echo -e "[Flatpak Preinstall com.github.PintaProject.Pinta]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Pinta.preinstall

# Ark | For unzipping files and file compression! (Imagine a fox whose face you may squish...)
RUN echo -e "[Flatpak Preinstall org.kde.ark]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Ark.preinstall

# Faugus Launcher | This is fantastic for using windows software on linux, throwing exes at it and whatnot
RUN echo -e "[Flatpak Preinstall io.github.faugus.faugus-launcher]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/FaugusLauncher.preinstall

# ProtonPlus | For installing different versions of proton! Emulation for windows games via Steam/Valve's work
RUN echo -e "[Flatpak Preinstall com.vysp3r.ProtonPlus]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/ProtonPlus.preinstall

# Kdenlive | Video editing!
RUN echo -e "[Flatpak Preinstall org.kde.kdenlive]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Kdenlive.preinstall

# Okular | Viewing pdfs~
RUN echo -e "[Flatpak Preinstall org.kde.okular]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Okular.preinstall

# Kate | Writing documents~ Also can act as an IDE/development environment interestingly!
RUN echo -e "[Flatpak Preinstall org.kde.kate]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Kate.preinstall

# Warehouse | Manage your flatpak apps, delete whatever you don"t need/use/want! It's YOUR computer.
RUN echo -e "[Flatpak Preinstall io.github.flattool.Warehouse]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Warehouse.preinstall

# Fedora Media Writer | Burn ISOs to usb sticks! Install linux on ALL the things. (This won"t work for Windows ISOs, cuz Microsoft is dumb) >:c
RUN echo -e "[Flatpak Preinstall org.fedoraproject.MediaWriter]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/FedoraMediaWriter.preinstall

# Gear Lever | Manage appimages!
RUN echo -e "[Flatpak Preinstall it.mijorus.gearlever]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/GearLever.preinstall

# Haruna | Watch video files! I actually personally like this better than VLC Media Player, nicer look/featureset
RUN echo -e "[Flatpak Preinstall org.kde.haruna]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Haruna.preinstall

# Gwenview | View images!
RUN echo -e "[Flatpak Preinstall org.kde.gwenview]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Gwenview.preinstall

# Audacity | Edit audio! We love Audacity~ Wonderful software.
RUN echo -e "[Flatpak Preinstall org.audacityteam.Audacity]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Audacity.preinstall

# Not Tetris 2 | DEFINITELY not Tetris... 2!!!
RUN echo -e "[Flatpak Preinstall net.stabyourself.nottetris2]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/NotTetris2.preinstall

# Firefox | A fellow fluffy fox!!
RUN echo -e "[Flatpak Preinstall org.mozilla.firefox]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Firefox.preinstall

# Resources | System Monitor/System Processes Manager
RUN echo -e "[Flatpak Preinstall net.nokyan.Resources]\nBranch=stable\nRuntime=false" > /usr/share/flatpak/preinstall.d/SystemMonitor.preinstall

# Vesktop | Instant Messaging Discord 3rd Party Chat client
RUN echo -e "[Flatpak Preinstall com.discordapp.Discord]\nBranch=stable\nRuntime=false" > /usr/share/flatpak/preinstall.d/Discord.preinstall

# OBS | Video recording/Streaming
RUN echo -e "[Flatpak Preinstall com.obsproject.Studio]\nBranch=stable\nRuntime=false" > /usr/share/flatpak/preinstall.d/OBS.preinstall

RUN echo -e "[Flatpak Preinstall com.obsproject.Studio.Plugin.OBSVkCapture]\nBranch=stable\nRuntime=true" > /usr/share/flatpak/preinstall.d/OBSVKCapture.preinstall

########################################################################################################################################
# Section 5 - Linux OS stuffs | "I'd decide for myself whether his teachings are right or wrong." Near, Death Note #####################
########################################################################################################################################
# Bazaar installed After flatpak-git for dependency trouble
# Also installed not as a flatpak because of perms trouble FIXME (possibly)
RUN pacman -S --noconfirm bazaar

# Place XeniaOS logo at plymouth folder location to appear on boot and shutdown.
RUN mkdir -p /etc/plymouth && \
      echo -e '[Daemon]\nTheme=spinner' | tee /etc/plymouth/plymouthd.conf && \
      wget --tries=5 -O /usr/share/plymouth/themes/spinner/watermark.png \
      https://raw.githubusercontent.com/XeniaMeraki/XeniaOS-G-Euphoria/refs/heads/main/xeniaos_textlogo_plymouth_delphic_melody.png

# All kindsa Sudo changes for ease and flavor
RUN echo -e '%wheel ALL=(ALL:ALL) ALL\n\
\n\
Defaults pwfeedback\n\
Defaults secure_path="/usr/local/bin:/usr/bin:/bin:/home/linuxbrew/.linuxbrew/bin"\n\
Defaults env_keep += "EDITOR VISUAL PATH"\n\
Defaults timestamp_timeout=0' > /etc/sudoers.d/xenias-sudo-quiver && \
    chmod 440 /etc/sudoers.d/xenias-sudo-quiver

RUN git clone --depth=1 https://github.com/vinceliuice/Colloid-icon-theme /tmp/colloid-icons && \
    cd /tmp/colloid-icons && \
    ./install.sh \
      -s catppuccin \
      -t orange \
      -d /usr/share/icons && \
    rm -rf /tmp/colloid-icons

RUN git clone --depth=1 https://github.com/Hexality/Colloidppuccin /tmp/colloid-gtk && \
    cd /tmp/colloid-gtk && \
    ./install.sh \
      -t orange \
      -c dark \
      -n Colloid-Orange-Dark-Catppuccin \
      -d /usr/share/themes && \
    rm -rf /tmp/colloid-gtk

# Add greetd user manually for rebase issues that arise
RUN useradd -M -G video,input -s /usr/bin/nologin greeter || true

# Set up zram, this will help users not run out of memory. Fox will fix!
RUN echo -e '[zram0]\nzram-size = min(ram, 8192)' > /usr/lib/systemd/zram-generator.conf
RUN echo -e 'enable systemd-resolved.service' > /usr/lib/systemd/system-preset/91-resolved-default.preset
RUN echo -e 'L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf' > /usr/lib/tmpfiles.d/resolved-default.conf
RUN systemctl preset systemd-resolved.service

# OS Release and Update uwu
RUN echo -e 'NAME="XeniaOS"\n\
PRETTY_NAME="XeniaOS"\n\
ID=arch\n\
BUILD_ID=rolling\n\
ANSI_COLOR="38;2;23;147;209"\n\
HOME_URL="https://github.com/XeniaMeraki/XeniaOS"\n\
LOGO=archlinux-logo\n\
DEFAULT_HOSTNAME="XeniaOS"' > /etc/os-release

# Symlink Vi to Vim / Make it to where a user can use vi in terminal command to use vim automatically | Thanks Tulip
RUN ln -s ./vim /usr/bin/vi

# Redirect neofetch & fastfetch -> hyfetch | Feel free to undo this as a user 
# Just to avoid confusion on admin side/make things aesthetic across the board
RUN ln -s /usr/bin/hyfetch /usr/bin/neofetch && \
    echo -e 'alias fastfetch=hyfetch' > /etc/profile.d/aliases.sh

# Symlink GTK to Libadwaita
RUN mkdir -p /usr/share/gtk-4.0

RUN ln -sf /usr/share/themes/Colloid-Orange-Dark-Catppuccin/gtk-4.0/{assets,gtk.css,gtk-dark.css} \
       /usr/share/gtk-4.0/

# Use Chezmoi to set up config files, visual assets, avatars, and wallpapers
RUN git clone https://github.com/XeniaMeraki/XeniaOS-HRT /usr/share/xeniaos/zdots/ && \
    git clone https://github.com/XeniaMeraki/XeniaOS-G-Euphoria /usr/share/xeniaos/wallpapers

# System-wide default application associations for filetype calls
RUN mkdir -p /etc/xdg/

RUN echo -e '[Default Applications]\n\
text/plain=org.kde.kate.desktop\n\
application/json=org.kde.kate.desktop\n\
\n\
text/html=floorp.desktop\n\
\n\
video/mp4=haruna.desktop\n\
video/x-matroska=haruna.desktop\n\
video/webm=haruna.desktop\n\
video/quicktime=haruna.desktop\n\
\n\
audio/mpeg=org.kde.elisa.desktop\n\
audio/flac=org.kde.elisa.desktop\n\
audio/ogg=org.kde.elisa.desktop\n\
audio/wav=org.kde.elisa.desktop\n\
\n\
image/png=pinta.desktop\n\
image/jpeg=pinta.desktop\n\
image/gif=org.kde.gwenview.desktop\n\
\n\
application/zip=org.kde.ark.desktop\n\
application/x-rar=org.kde.ark.desktop\n\
application/x-tar=org.kde.ark.desktop\n\
\n\
[Added Associations]' > /etc/xdg/mimeapps.list

# ENV default exports, QT theming 
# Load shared objects immediately for better first time latency
# Apply OBS_VK to all vulkan instances for better OBS game capture, some other windows may come along for the ride
# Auto dark mode everywhere
RUN echo -e 'QT_QPA_PLATFORMTHEME=qt6ct\n\
LD_BIND_NOW=1\n\
OBS_VKCAPTURE=1\n\
GTK_THEME=Colloid-Orange-Dark-Catppuccin\n\
QT_STYLE_OVERRIDE=Colloid-Orange-Dark-Catppuccin\n\
XDG_MENU_PREFIX=arch-\n\
XDG_MENU_PREFIX=plasma-\n' > /etc/environment

RUN kbuildsycoca6

# Set vm.max_map_count for stability/improved gaming performance
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
RUN echo -e "vm.max_map_count = 2147483642" > /etc/sysctl.d/80-gamecompatibility.conf

# Set up fictional Xenia shell companion in terminal
RUN curl --retry 5 -s https://api.github.com/repos/fwdekker/mommy/releases/latest | grep "browser_download_url.*\.pacman" | cut -d : -f 2,3 | tr -d \" | xargs curl -sLOJ && \
    sudo pacman -U --noconfirm ./mommy-*.pacman && \
    echo -e 'PROMPT_COMMAND="mommy -1 -s \$?; $PROMPT_COMMAND"' >> /etc/bash.bashrc && \
    mkdir -p /etc/mommy && \
    echo -e 'MOMMY_SWEETIE="foxgirl"\n\
MOMMY_CAREGIVER="Xenia"\n\
MOMMY_COLOR="208"\n\
MOMMY_CAPITALIZE="1"' > /etc/mommy/config.sh

# Automount ext4/btrfs drives, feel free to mount your own in fstab if you understand how to do so
# To turn off, run sudo ln -s /dev/null /etc/media-automount.d/_all.conf
RUN git clone --depth=1 https://github.com/Zeglius/media-automount-generator /tmp/media-automount-generator && \
    cd /tmp/media-automount-generator && \
    ./install.sh && \
    rm -rf /tmp/media-automount-generator

##############################################################################################################################################################################
# Section 6 - Systemd n Services | Hope is just like every other kind of work you do on your body, it's cyclical, and needs to be refreshed every day -Harpy #################
##############################################################################################################################################################################

# Systemd flatpak preinstall service, thanks Aurora
RUN echo -e '[Unit]\n\
Description=Preinstall Flatpaks\n\
After=network-online.target\n\
Wants=network-online.target\n\
ConditionPathExists=/usr/bin/flatpak\n\
Documentation=man:flatpak-preinstall(1)\n\
\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/bin/flatpak preinstall -y\n\
RemainAfterExit=true\n\
Restart=on-failure\n\
RestartSec=30\n\
\n\
StartLimitIntervalSec=600\n\
StartLimitBurst=3\n\
\n\
[Install]\n\
WantedBy=multi-user.target' > /usr/lib/systemd/system/flatpak-preinstall.service

RUN echo -e '[Unit]\n\
Description=udiskie automounter\n\
\n\
[Service]\n\
ExecStart=/usr/bin/udiskie\n\
\n\
[Install]\n\
WantedBy=default.target' > /usr/lib/systemd/user/udiskie.service

RUN echo -e '[Unit]\n\
Description=Initializes Chezmoi if directory is missing\n\
ConditionPathExists=!%h/.config/xeniaos/chezmoi\n\
\n\
[Service]\n\
ExecStart=mkdir -p %h/.config/xeniaos/chezmoi\n\
ExecStart=touch %h/.config/xeniaos/chezmoi/chezmoi.toml\n\
ExecStart=chezmoi apply -S /usr/share/xeniaos/zdots --config %h/.config/xeniaos/chezmoi/chezmoi.toml\n\
Type=oneshot\n\
\n\
[Install]\n\
WantedBy=graphical-session-pre.target' > /usr/lib/systemd/user/chezmoi-init.service

RUN echo -e '[Unit]\n\
Description=Timer for Chezmoi Update\n\
# This service will only execute for a user with an existing chezmoi directory\n\
ConditionPathExists=%h/.config/xeniaos/chezmoi\n\
\n\
[Timer]\n\
OnBootSec=5m\n\
OnUnitInactiveSec=1d\n\
\n\
[Install]\n\
WantedBy=timers.target' > /usr/lib/systemd/user/chezmoi-update.timer

RUN echo -e "[Unit]\n\
Description=Chezmoi Update\n\
\n\
[Service]\n\
ExecStart=mkdir -p %h/.config/xeniaos/chezmoi\n\
ExecStart=touch %h/.config/xeniaos/chezmoi/chezmoi.toml\n\
ExecStart=sh -c 'yes s | chezmoi apply --no-tty --keep-going -S /usr/share/xeniaos/zdots --verbose --config %h/.config/xeniaos/chezmoi/chezmoi.toml'\n\
Type=oneshot" > /usr/lib/systemd/user/chezmoi-update.service

# This fixes a user/groups error with rebasing from other problematic images.
# FIXME Do NOT remove until fixed upstream or fixed universally. Updating with new fix also fine. Script created by Tulip.
RUN mkdir -p /usr/lib/systemd/system-preset /usr/lib/systemd/system
RUN echo -e '#!/bin/sh\ncat /usr/lib/sysusers.d/*.conf | grep -e "^g" | grep -v -e "^#" | awk "NF" | awk '\''{print $2}'\'' | grep -v -e "wheel" -e "root" -e "sudo" | xargs -I{} sed -i "/{}/d" $1' > /usr/libexec/xeniaos-group-fix
RUN chmod +x /usr/libexec/xeniaos-group-fix
RUN echo -e '[Unit]\n\
Description=Fix groups\n\
Wants=local-fs.target\n\
After=local-fs.target\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/libexec/xeniaos-group-fix /etc/group\n\
ExecStart=/usr/libexec/xeniaos-group-fix /etc/gshadow\n\
ExecStart=systemd-sysusers\n\
[Install]\n\
WantedBy=default.target multi-user.target' > /usr/lib/systemd/system/xeniaos-group-fix.service

RUN echo -e "enable xeniaos-group-fix.service" > /usr/lib/systemd/system-preset/01-xeniaos-group-fix.preset

# System services (Machine Boot level)
RUN systemctl enable polkit.service \
    NetworkManager.service \
    tuned.service \
    tuned-ppd.service \
    firewalld.service \
    greetd.service \
    flatpak-preinstall.service \
    xeniaos-group-fix.service \
    cups.socket \
    cups-browsed.service \
    bluetooth.service

# User services (Niri/user session level)
RUN systemctl --global enable \
    niri.service \
    dms.service \
    udiskie.service \
    chezmoi-init.service \
    chezmoi-update.service \
    chezmoi-update.timer \
    opentabletdriver.service

########################################################################################################################################
# Section 7 - CachyOS settings | Since we have the CachyOS kernel, we gotta put it to good use ≽^•⩊•^≼ ################################
########################################################################################################################################

# Activate NTSync, wags my tail in your general direction
RUN echo -e 'ntsync' > /etc/modules-load.d/ntsync.conf

# CachyOS bbr3 Config Option
RUN echo -e 'net.core.default_qdisc=fq \n\
net.ipv4.tcp_congestion_control=bbr' > /etc/sysctl.d/99-bbr3.conf

########################################################################################################################################
# Section 8 - Niri/Chezmoi/DMS | Everything to do with the desktop/visual look of your taskbar/ config files (⸝⸝>w<⸝⸝) #################
########################################################################################################################################

# Catppuccin style cursor, in a lovely orange, much like my furrrrr~
RUN mkdir -p /usr/share/icons && \
    curl --retry 5 --retry-all-errors -fsSLO \
      https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-peach-cursors.zip && \
    unzip -q catppuccin-mocha-peach-cursors.zip -d /usr/share/icons && \
    rm -f catppuccin-mocha-peach-cursors.zip && \
    ln -sfn /usr/share/icons/Catppuccin-Mocha-Peach-Cursors /usr/share/icons/default

# Add Maple Mono font, it's so cute! It's a pain to download! You'll love it.
RUN mkdir -p "/usr/share/fonts/Maple Mono" && \
    curl --retry 5 --retry-all-errors -fsSL \
      https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-Variable.zip \
      -o /tmp/maple.zip && \
    unzip -q /tmp/maple.zip -d "/usr/share/fonts/Maple Mono" && \
    rm -f /tmp/maple.zip

# Redo font cache to pick up not just Maple Mono but All of our installed fonts
RUN fc-cache --force --really-force --system-only --verbose

# Add config for dolphin to Niri and switch away from GTK/Nautilus, use Dolphin for file chooser.
RUN echo -e '[preferred] \n\
default=kde;gtk;gnome; \n\
org.freedesktop.impl.portal.ScreenCast=gnome;kde;gtk; \n\
org.freedesktop.impl.portal.Access=kde;gtk;gnome; \n\
org.freedesktop.impl.portal.Notification=kde;gtk;gnome' > /usr/share/xdg-desktop-portal/niri-portals.conf

#Starship setup
RUN echo -e 'eval "$(starship init bash)"' >> /etc/bash.bashrc

# ReGreet login shell setup
RUN mkdir -p /etc/greetd/

RUN echo -e 'spawn-sh-at-startup "regreet; niri msg action quit --skip-confirmation"\n\
hotkey-overlay {\n\
    skip-at-startup\n\
}\n\
cursor {\n\
    xcursor-theme "catppuccin-mocha-peach-cursors"\n\
}' > /etc/greetd/niri.kdl

RUN echo -e '[terminal]\n\
vt = 1\n\
\n\
[default_session]\n\
command = "/usr/bin/dbus-run-session /usr/bin/niri --config /etc/greetd/niri.kdl"\n\
user = "greeter"' > /etc/greetd/config.toml

RUN echo -e '[background]\n\
path = "/usr/share/xeniaos/wallpapers/3_hypno_chimmie_firefly_videorelaxant6025.png"\n\
\n\
fit = "Fill"\n\
[GTK]\n\
application_prefer_dark_theme = true\n\
\n\
cursor_theme_name = "catppuccin-mocha-peach-cursors"\n\
\n\
cursor_blink = true\n\
\n\
font_name = "Maple Mono 16"\n\
\n\
icon_theme_name = "Colloid-Orange-Catppuccin-Dark"\n\
\n\
theme_name = "Colloid-Orange-Dark-Catppuccin"\n\
[commands]\n\
reboot = ["systemctl", "reboot"]\n\
\n\
poweroff = ["systemctl", "poweroff"]\n\
[appearance]\n\
greeting_msg = "Welcome to the fox den!~"\n\
\n\
[widget.clock]\n\
format = "%a %H:%M"\n\
\n\
resolution = "500ms"\n\
\n\
label_width = 150' > /etc/greetd/regreet.toml

########################################################################################################################################
# Section 9 - Final Bootc Setup | The horrors are endless. but we stay silly :3c -junoinfernal -maia arson crimew #####################
########################################################################################################################################

RUN printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf && \
      printf 'hostonly=no\nadd_dracutmodules+=" ostree bootc "' | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-modules.conf && \
      sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
      dracut --force --no-hostonly --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"'

RUN rm -rf /home/build/.cache/* && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/* && \
    pacman -Rns --noconfirm git

# Necessary for general behavior expected by image-based systems
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
    rm -rf /boot /home /root /usr/local /srv /opt /mnt /var /usr/lib/sysimage/log /usr/lib/sysimage/cache/pacman/pkg && \
    mkdir -p /sysroot /boot /usr/lib/ostree /var && \
    ln -sT sysroot/ostree /ostree && ln -sT var/roothome /root && ln -sT var/srv /srv && ln -sT var/opt /opt && ln -sT var/mnt /mnt && ln -sT var/home /home && ln -sT ../var/usrlocal /usr/local && \
    echo "$(for dir in opt home srv mnt usrlocal ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
    printf "d /var/roothome 0700 root root -\nd /run/media 0755 root root -" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
    printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' | tee "/usr/lib/ostree/prepare-root.conf"

RUN bootc container lint

#####################
#####################     ,c.                       .c;
#####################   .KMMMk....             ....kMMMK.
#####################   .WMMMMMX.....         .....KMMMMMW.                       
#####################   XMMMMMMM0.....        ....OMMMMMMMN
#####################  dMMMMMMMMM;.... ..... ....,MMMMMMMMMd
#####################  WMMMMMMMMMl;okKKKKKKKKKOo;cMMMMMMMMMM
##################### 'MMMMMMMNXK0KKKKKKKKKKKKKKK0KXNMMMMMMM;
##################### oMMMMMMMOxoKKKKKKKKKKKKKKKKKoxOMMMMMMMd                    
##################### dMMMMMMMdxxxKKKKKKKKKKKKKKKxxxdNMMMMMMk                  
##################### :MMMMX0xxxxxx0KKKKKKKK0KK0xxxxxx0XMMMMc
#####################  MMMOxxxxxxxxdxkdd0x0ddkxdxxxxxxxxOMMM 
##################### ;xxkxddxxxxdodxxxxdxdxxxxdodxxxxddxkxx;
#####################dxdKMMMWXo'.....'cdxxxdc'.....'lXWMMMXdxd
##################### cxdXMMMN,..........dxd'.........'XMMMNdxl 
#####################  .xxWMMl...''....'.;k:.'....''...lMMWxx.       
##################### ..:kXMMx..'....''..kMk..''....'..xMMXkc..
#####################  dMMMMMMd.....'...xMMMx...''....dMMMMMMx
#####################    kMMMMWOoc:coOkolllokOoc:coOWMMMMO
#####################          .MMMMMMMMl...lNMMMMMMM.
#####################             KMMMMMMXlKMMMMMMX
#####################                .MMMMMMMMM. 
#####################
##################### Art by @bhavyakukkar and @ioletsgo
