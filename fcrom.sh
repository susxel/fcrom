#! /bin/bash

if [ "$1" ]; then
	filename=$1
else
	dir=`more ~/.config/fcrom/.dir`
	filename=`zenity --file-selection --filename="*.nes" --title="Select .nes rom file"`
fi
if [ `hexdump "$filename" -n 4 -e '"%x"'` != "1a53454e" ]; then
	zenity --error --text="Not an .NES file"
	exit
fi
basename=`basename "$filename"`
prg=$((`hexdump "$filename" -s 4 -n 1 -e '"%i"'`))
chr=$((`hexdump "$filename" -s 5 -n 1 -e '"%i"'`))
lmap=`hexdump "$filename" -s 6 -n 1 -e '"%x"'`
hmap=`hexdump "$filename" -s 7 -n 1 -e '"%x"'`
cd ~
mkdir .config/fcrom	
mkdir .config/fcrom/inf
mkdir .config/fcrom/bin
echo "PRG ROM: $(($prg*16)) KB ($(($prg*16*8)) Kb)" > ".config/fcrom/inf/$basename.inf"
echo "CHR ROM: $(($chr*8)) KB ($(($chr*8*8)) Kb)" >> ".config/fcrom/inf/$basename.inf"
echo "Mapper: `printf "%03.0f" $((16#${hmap:0:1}${lmap:0:1}))`" >> ".config/fcrom/inf/$basename.inf"
zenity --text-info --title="Header info" --filename=".config/fcrom/inf/$basename.inf" --ok-label="Show mapper info" --cancel-label="Do not show mapper info"
case $? in
	0)
		if [ ${hmap:0:1} ]; then
			zenity --text-info --title="Mapper info" --width=1200 --height=1200 --html --url=https://www.nesdev.org/wiki/INES_Mapper_`printf "%03.0f" $((16#${hmap:0:1}${lmap:0:1}))`
		else
			zenity --text-info --title="Mapper info" --width=1200 --height=1200 --html --url=https://www.nesdev.org/wiki/NES_2.0_Mapper_`printf "%03.0f" $((16#${hmap:0:1}${lmap:0:1}))`
		fi
	;;
	1)
		echo "Nothing"
	;;
	-1)
		zenity --error --text="An unknown error has occurred."
	;;
esac
tail -c +17 "$filename" > ".config/fcrom/bin/$basename.prg"
truncate -s $(($prg*16))K ".config/fcrom/bin/$basename.prg"
tail -c $(($chr*8))K "$filename" > ".config/fcrom/bin/$basename.chr"
