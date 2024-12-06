# Instalar Arch Linux minima con escritorio plasma y hyprland

Para instalar Arch Linux junto a Windows utilizando bootctl como gestor de arranque, necesitas hacer algunos pasos específicos en cuanto a particionamiento y configuración. Te doy una guía paso a paso con comandos para el proceso. Este script de ejemplo está orientado a un sistema UEFI y supone que tienes Windows ya instalado.

Advertencia: Realice una copia de seguridad de sus datos antes de proceder, ya que el proceso implica modificaciones a las particiones que podrían resultar en pérdida de datos si se realiza incorrectamente.

Pasos para el script de instalación de Arch Linux junto a Windows usando bootctl
Arranca desde el medio de instalación de Arch Linux (USB o CD).

# Notas importantes:

Reemplaza NOMBRE_DE_TU_RED con el nombre de tu red Wi-Fi.
Ajusta /dev/sdaY y /dev/sda1para que coincidan con las particiones correctas para Linux y EFI en tu sistema.
Modifica Region/City en la zona horaria según tu ubicación (por ejemplo, Europe/Madrid).
Configure el nombre del host en nombre_del_host.
Este script instalará Arch Linux junto con Windows, configurará bootctlpara que pueda elegir entre Arch Linux y Windows durante el arranque y habilitará NetworkManagerpara la administración de red.

# Instalación para configurar un entorno de escritorio básico en Arch Linux utilizando Hyprland como gestor de ventanas Wayland.

Este script instala las dependencias necesarias, configura el entorno gráfico y algunos programas útiles.

Guarde el contenido en un archivo (por ejemplo, c.sh), luego dale permisos de ejecución ( chmod +x hyprland_instal.sh) y ejecútalo con privilegios de administrador.

Este guión realiza los siguientes pasos:

Actualiza el sistema e instala base-devel, git, y yay(gestor de AUR).
Instale Hyprland junto con las dependencias necesarias para funcionar en Wayland.
Configura LightDM como gestor de inicio de sesión.
Cree una configuración básica para Hyprland.
Establece permisos correctos en el directorio de configuración para el usuario.
Notas
Cambia USER_NAME por tu nombre de usuario.
Puedes agregar o modificar programas a la lista según tus necesidades (por ejemplo, agregar firefox o alacritty).
Después de reiniciar, deberías ver la opción de iniciar sesión en Hyprland desde LightDM.
¡Espero que esto te sea útil para empezar con Hyprland en Arch Linux!

# Para instalar y usar Hyprland en VirtualBox

Se necesitan algunos ajustes adicionales debido a que VirtualBox tiene soporte limitado para Wayland y las características de gráficos avanzados que Hyprland requiere. Aquí está una versión revisada del script que incluye los cambios necesarios para un entorno virtual en VirtualBox:

# Modificaciones al script

Soporte de gráficos 3D : Asegúrese de que la aceleración 3D esté habilitada en la configuración de la máquina virtual.
Instalación de mesayxf86-video-vmware : Estos paquetes son necesarios para mejorar la compatibilidad gráfica en VirtualBox.
Configuración de resolución de pantalla : Agregar configuración para ajustar automáticamente la resolución de pantalla, ya que VirtualBox no puede integrarse bien con Wayland.

# Mensaje final

echo "Instalación completa. Reinicia el sistema para iniciar sesión en Hyprland."
Cambios adicionales y notas

Instalación de mesayxf86-video-vmware : Estos paquetes mejoran la compatibilidad gráfica de Hyprland en VirtualBox.
virtualbox-guest-utils: Necesario para mejorar la integración de la máquina virtual en VirtualBox, especialmente para soportar resoluciones de pantalla y portapapeles compartidos.
Habilitar el serviciovboxservice : Esto activa el soporte de los complementos de VirtualBox, como la redimensión automática de la ventana y otras integraciones de VirtualBox.
Pasos adicionales después de la instalación
Habilitar la aceleración 3D en la configuración de VirtualBox (esto puede mejorar el rendimiento, aunque VirtualBox no tiene un soporte completo para Wayland).
Reiniciar la máquina virtual para cargar correctamente todos los servicios.
Con estos cambios, el sistema debería estar mejor preparado para correr en un entorno VirtualBox, aunque ten en cuenta que el rendimiento de Hyprland en una VM podría no ser óptimo debido a las limitaciones de VirtualBox con Wayland.
