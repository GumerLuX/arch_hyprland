#!/bin/bash

# Este script debe ejecutarse con permisos de root

# Variables de configuración
USER_NAME="$USUARIO"  # Cambia "tu_usuario" por tu nombre de usuario
SHELL="/bin/bash"

# Actualizar e instalar paquetes básicos
echo "Actualizando sistema e instalando paquetes básicos..."
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel git wget neovim nano

# Instalar el repositorio AUR helper (yay)
echo "Instalando yay..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

# Instalación de Hyprland y dependencias para entorno Wayland
echo "Instalando Hyprland y dependencias de Wayland..."
yay -S --noconfirm hyprland wayland wayland-protocols xorg-xwayland \
    xdg-desktop-portal-hyprland polkit-gnome wl-clipboard grim slurp \
    wlogout kanshi swappy swaybg swaylock-effects ttf-jetbrains-mono-nerd noto-fonts-emoji

# Instalación de controladores y herramientas adicionales para VirtualBox
echo "Instalando paquetes adicionales para VirtualBox..."
pacman -S --noconfirm mesa xf86-video-vmware virtualbox-guest-utils

# Habilitar servicios para VirtualBox Guest Additions
systemctl enable vboxservice.service
systemctl start vboxservice.service

# Instalación de utilidades de sistema y apariencia
echo "Instalando utilidades de sistema y temas..."
yay -S --noconfirm \
    rofi-lbonn-wayland rofi-emoji \
    kitty thunar thunar-archive-plugin file-roller \
    lightdm lightdm-gtk-greeter \
    dunst pavucontrol alsa-utils brightnessctl \
    ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd \
    papirus-icon-theme

# Configuración de LightDM (gestor de inicio de sesión)
echo "Configurando LightDM..."
systemctl enable lightdm.service

# Crear configuración básica para Hyprland
echo "Creando configuración básica de Hyprland para el usuario $USER_NAME..."
CONFIG_DIR="/home/$USER_NAME/.config/hypr"
mkdir -p $CONFIG_DIR
cat <<EOF > $CONFIG_DIR/hyprland.conf
# Configuración básica de Hyprland
monitor=,preferred,auto,1
exec-once=wl-paste -t text --watch cliphist store
exec-once=lightdm
layout=es
EOF

# Ajustes de permisos para el usuario
chown -R "$USER_NAME":"$USER_NAME" "/home/$USER_NAME/.config/hypr"

# Mensaje final
echo "Instalación completa. Reinicia el sistema para iniciar sesión en Hyprland."
