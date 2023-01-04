for files in /main/source-docs/*; do
  source $files
  source $alias
done

echo "Are devices mouted? :$ready"
read ready
if [[ $ready = y ]]; then
   echo ''
elif [[ $ready = n ]]; then
  return 69
fi

echo "Efi drive? :$efid"
read efid

echo "Root drive $rootd"
read rootd

echo "Home drive :$homed"
read homed

mount $rootd /mnt
mount --mkdir $efid /mnt/boot/efi
mount --mkdir $homed /mnt/docker

bootstrap
arch-chroot /mnt ./stack


