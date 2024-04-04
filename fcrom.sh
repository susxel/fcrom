#! /bin/bash

if [ $1 ]; then
	filename=$1
else
	filename=`zenity --file-selection --title="Select .nes rom file"`
fi
if [ `hexdump $filename -n 4 -e '"%x"'` != "1a53454e" ]; then
	zenity --error --text="Not an .NES file"
	exit
else
	prg=$((`hexdump $filename -s 4 -n 1 -e '"%i"'`))
	chr=$((`hexdump $filename -s 5 -n 1 -e '"%i"'`))
	lmap=`hexdump $filename -s 6 -n 1 -e '"%x"'`
	hmap=`hexdump $filename -s 7 -n 1 -e '"%x"'`
	echo "PRG ROM: $(($prg*16)) KB ($(($prg*16*8)) Kb)" > $filename.inf
	echo "CHR ROM: $(($chr*8)) KB ($(($chr*8*8)) Kb)" >> $filename.inf
	echo "Mapper: `printf "%03.0f" $((16#${hmap:0:1}${lmap:0:1}))`" >> $filename.inf
	zenity --text-info --title="Header info" --filename=$filename.inf
fi