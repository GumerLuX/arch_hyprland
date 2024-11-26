#!/bin/bash

# Conecta a Internet (ajusta según sea necesario)
#echo "Conectando a internet..."
#iwctl station wlan0 connect NOMBRE_DE_TU_RED

# Actualiza el reloj
timedatectl set-ntp true

# Configura las particiones (ajusta el dispositivo según sea necesario)
echo "Particionando el disco..."
#cfdisk /dev/sda

echo Cual es la particion boot:
read BOOT

echo Cual es la particion root:
read ROOT

# Formatea las particiones
echo "Formateando la partición de Linux en ext4..."
mkfs.ext4 /dev/$ROOT  # Ajusta /dev/sdaY a la partición de Linux que hayas creado

#echo "Formateando la partición EFI..."
#mkfs.fat -F32 /dev/sda1  # Ajusta /dev/sda1 a la partición EFI

# Monta las particiones
echo "Montando las particiones..."
mount /dev/$ROOT /mnt
mkdir -p /mnt/boot
mount /dev/$BOOT /mnt/boot

# Instala los paquetes base de Arch Linux
echo "Instalando Arch Linux..."
pacstrap /mnt base linux linux-firmware

# Genera el archivo fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Accede al sistema instalado
arch-chroot /mnt <<EOF

# Configura la zona horaria
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime  # Ajusta Region/City a tu zona horaria
hwclock --systohc

# Configura el idioma
sed -i 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf

# Configura el nombre del host
echo "nombre_del_host" > /etc/hostname  # Ajusta "nombre_del_host"

# Configura la contraseña de root
echo "Configura la contraseña de root:"
passwd

# "Configura cuenta de usuario:"
echo "Configura cuenta de usuario:"
read USUARIO
arch-chroot /mnt useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash "$USUARIO"
echo "Añadimos contraseña de usuario"
passwd $USUARIO

# Instala bootctl
echo "Instalando bootctl..."
bootctl install

# Crea la entrada de Arch Linux en bootctl
echo "Configurando bootctl..."
cat <<EOL > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$ROOT) rw  # Ajusta /dev/$ROOT a la partición de Linux
EOL

# Configura bootctl para arranque predeterminado
cat <<EOL > /boot/loader/loader.conf
default arch
timeout 5
console-mode max
EOL

# Instala y habilita NetworkManager
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

EOF

echo "Copiando el directorio a root"
		cp -R "$(pwd)" /mnt/root
		ls /mnt/root/
pause "Enter para continuar"

# Sal del entorno chroot y desmonta las particiones
echo "Terminando la instalación..."
umount -R /mnt

# Reinicia el sistema
echo "Instalación completa. Reiniciando..."
reboot
