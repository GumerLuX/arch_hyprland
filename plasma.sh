#!/bin/bash

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o con sudo."
  exit 1
fi

# Función para actualizar el sistema
actualizar_sistema() {
  echo "\nActualizando el sistema..."
  pacman -Syu --noconfirm
}

# Función para instalar Xorg
instalar_xorg() {
  echo "\nInstalando el servidor gráfico Xorg..."
  pacman -S --noconfirm xorg-server xorg-xinit xorg-apps
}

# Función para instalar Wayland
instalar_wayland() {
  echo "\nInstalando Wayland..."
  pacman -S --noconfirm wayland plasma-wayland-session
}

# Función para instalar una instalación mínima
instalacion_minima() {
  echo "\nInstalando KDE Plasma (mínima)..."
  pacman -S --noconfirm plasma-desktop konsole dolphin dolphin-plugins ffmpegthumbs ark okular gwenview kscreen kcalc kate kde-gtk-config spectacle firefox sddm sddm-kcm kmix
  configurar_sddm
}

# Función para instalar una instalación completa
instalacion_completa() {
  echo "\nInstalando KDE Plasma y aplicaciones completas..."
  pacman -S --noconfirm plasma kde-applications
  configurar_sddm
}

# Función para configurar y habilitar SDDM
configurar_sddm() {
  echo "\nHabilitando SDDM..."
  systemctl enable sddm.service
  systemctl start sddm.service
}

# Mostrar opciones al usuario
echo "\nInstalador de KDE Plasma en Arch Linux"
echo "======================================"
echo "1) Instalación mínima (Xorg + Plasma, Dolphin, y Konsole)"
echo "2) Instalación completa (Xorg + Plasma + aplicaciones KDE)"
echo "q) Salir"

# Leer la elección del usuario
read -p "Elige una opción: " opcion

# Ejecutar la opción seleccionada
case $opcion in
  1)
    actualizar_sistema
    instalar_xorg
    instalar_wayland
    instalacion_minima
    ;;
  2)
    actualizar_sistema
    instalar_xorg
    instalar_wayland
    instalacion_completa
    ;;
  q|Q)
    echo "Saliendo..."
    exit 0
    ;;
  *)
    echo "Opción no válida. Por favor, elige 1, 2 o q."
    ;;
esac

# Mensaje final
echo "\nInstalación completada. Reinicia el sistema para aplicar los cambios."
