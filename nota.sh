#!/bin/bash

#shellcheck disable=SC2162

#es
Green="\e[0;32m\033[1m"
Red="\e[0;31m\033[1m"
Blue="\e[0;34m\033[1m"
Yellow="\e[0;33m\033[1m"
Cyan="\e[0;36m\033[1m"
Light="\e[96m\033[1m"
Gray="\e[0;37m\033[1m"
fin="\e[0m"


## Estilos
print_line(){
    printf "\e[1;34m%$(tput cols)s\n\e[0m"|tr ' ' '-'
}

write_header(){
    clear
    print_line
    echo -e "#${Gray}$1${fin}"
    print_line
    echo ""
}

print_info(){
    echo -e "${Green}$1${fin}\n"
}

pause_function(){
    echo
    print_line
    read -p "Presiona enter para continuar..."
}

# Guardar el tiempo de inicio
start_time=$(date +%s)

write_header "# Configuración inicial"
set -e
DISK="/dev/sda"  # Cambia esto por el disco correcto
HOSTNAME="archlinux"
USERNAME="sindo"
TIMEZONE="Europe/Madrid"
LOCALE="es_ES.UTF-8"
KEYMAP="es"

# Particiones (ajusta según sea necesario)
BOOT_SIZE="512M"  # Tamaño para la partición /boot
SWAP_SIZE="2G"    # Tamaño para la partición swap

echo "### Configurando particiones en $DISK ###"
# Crear particiones
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary fat32 1MiB "$BOOT_SIZE"
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary linux-swap "$BOOT_SIZE" "$((512 + 2048))MiB"
parted -s "$DISK" mkpart primary ext4 "$((512 + 2048))MiB" 100%

# Formatear particiones
mkfs.fat -F32 "${DISK}1"  # /boot
mkswap "${DISK}2"         # swap
mkfs.ext4 "${DISK}3"      # /

# Montar particiones
mount "${DISK}3" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
swapon "${DISK}2"

echo "### Configuración del espejo más rápido ###"
# Configurar mirrors para Arch Linux
reflector --country Spain --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

echo "### Instalando el sistema base ###"
# Instalar paquetes base
pacstrap /mnt base linux linux-firmware vim nano sudo networkmanager

# Generar fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "### Configurando el sistema ###"
arch-chroot /mnt /bin/bash <<EOF
# Configurar zona horaria
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Configurar idioma
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Configurar red
echo "$HOSTNAME" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOT

# Configurar usuario root y sudo
echo "Estableciendo contraseña para root"
echo "root:Gsindo90" | chpasswd
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Estableciendo contraseña para $USERNAME"
echo "$USERNAME:sindo" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Habilitar servicios
systemctl enable NetworkManager

EOF

echo "Copiando el directorio a root"
		cp -R "$(pwd)" /mnt/root
		ls /mnt/root/
pause "Enter para continuar"

echo "### Instalación completada. Desmontando particiones ###"
umount -R /mnt
swapoff -a
echo "### El sistema está listo para reiniciar ###"



# Calcular el tiempo de ejecución
end_time=$(date +%s)
execution_time=$((end_time - start_time))

write_header "Mostrar el tiempo en un formato legible"
hours=$((execution_time / 3600))
minutes=$(((execution_time % 3600) / 60))
seconds=$((execution_time % 60))

echo "Tiempo de ejecución: ${hours}h ${minutes}m ${seconds}s"
