#!/bin/bash

# Configuración inicial
echo "Estableciendo configuración de teclado e idioma..."
loadkeys es
setfont latarcyrheb-sun16

echo "Sincronizando reloj..."
timedatectl set-ntp true

# Particionado del disco (usa /dev/sdX; reemplázalo con tu disco objetivo)
DISK="/dev/sda"
echo "Particionando el disco $DISK..."
parted -s $DISK mklabel gpt
parted -s $DISK mkpart ESP fat32 1MiB 513MiB
parted -s $DISK set 1 boot on
parted -s $DISK mkpart primary linux-swap 513MiB 2.5GiB
parted -s $DISK mkpart primary ext4 2.5GiB 100%

# Formateo de particiones
echo "Formateando particiones..."
mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"

# Montando las particiones
echo "Montando las particiones..."
mount "${DISK}3" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
swapon "${DISK}2"

# Instalación base
echo "Instalando el sistema base..."
pacstrap /mnt base linux linux-firmware

# Generar el fstab
echo "Generando el archivo fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
echo "Entrando en el sistema instalado..."
arch-chroot /mnt /bin/bash <<EOF

# Configuración del sistema
echo "Configurando la zona horaria..."
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

echo "Configurando locales..."
sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf

echo "Configurando teclado..."
echo "KEYMAP=es" > /etc/vconsole.conf

echo "Configurando hostname..."
echo "archlinux" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 archlinux.localdomain archlinux" >> /etc/hosts

# Configuración del usuario root y usuario sindo
echo "Configurando contraseñas de usuarios..."
echo "Establece la contraseña de root:"
passwd
useradd -m -G wheel sindo
echo "Establece la contraseña para el usuario sindo:"
passwd sindo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Instalación del cargador de arranque
echo "Instalando bootloader..."
BOOTLOADER="grub" # Cambiar a "bootctl" si prefieres systemd-boot
if [ "$BOOTLOADER" = "grub" ]; then
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
else
    bootctl install
    echo "default arch" > /boot/loader/loader.conf
    echo "title Arch Linux" > /boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
    echo "options root=$(blkid -s UUID -o value ${DISK}3) rw" >> /boot/loader/entries/arch.conf
fi

EOF

echo "Copiando el directorio a root"
		cp -R "$(pwd)" /mnt/root
		ls /mnt/root/
pause "Enter para continuar"

# Finalización
echo "Desmontando y reiniciando..."
umount -R /mnt
swapoff "${DISK}2"
echo "Instalación completada. Reinicia el sistema."
