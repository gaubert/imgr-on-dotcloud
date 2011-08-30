#!/bin/bash
set -x

# At work
#IMG_MANIP_HOME=/home/aubert/Dev/projects/imgr-on-dotcloud/etc
#IMAGEMAGICK_DIR=/homespace/gaubert/ImageMagick-6.6.9-8
# On my laptop 
IMG_MANIP_HOME=/home/aubert/Dev/projects/imgr-on-dotcloud/etc
IMAGEMAGICK_DIR=/usr
# on dotcloud
#IMG_MANIP_HOME=/home/dotcloud/code/etc
#IMAGEMAGICK_DIR=/usr

font_dir=$IMG_MANIP_HOME/fonts/

convert=$IMAGEMAGICK_DIR/bin/convert
composite=$IMAGEMAGICK_DIR/bin/composite

in=$1
text=$2
out=$3

usage="./bottom_card.sh input_file \"My text to add\" output_file"

if [ -z "$in" ]; then
  echo "in is not defined"
  exit 1
fi

if [ -z "$out" ]; then
  echo "out is not defined"
  exit 1
fi

rm -f $out

if [ -z "$text" ]; then
  echo "text is not defined"
  exit 1
fi

#################################
## if $1 is relative,
## build the absolute path
#################################
D=`dirname "$1"`
B=`basename "$1"`
in="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

#################################
## if $3 is relative,
## build the absolute path
#################################
D=`dirname "$3"`
B=`basename "$3"`
out="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

working_dir=/tmp/wrk_dir
mkdir -p $working_dir

rm -f out.jpg
cd $working_dir

#resize image and border of 25x25
$convert $in -normalize -resize 640 -bordercolor White -border 25x25 dummy.jpg
# add bigger bottom border
$convert dummy.jpg -gravity south -splice 0x60 -background White -gravity Center -append temp.jpg
#get width and height of the produced picture
W=`convert dummy.jpg -format %w info:`
#echo "W is $W"
#H='convert temp.jpg -format %h info:'

# create a mask fro rounding the borders
# apply the mask
#create mvg mask
$convert temp.jpg -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+4] 15,15' info: > rounded_corner.mvg
$convert temp.jpg -border 3 -alpha transparent -background none -fill white -stroke none -strokewidth 0 -draw "@rounded_corner.mvg" rounded_corner_mask.png
$convert temp.jpg -matte -bordercolor none -border 3 rounded_corner_mask.png -compose DstIn -composite temp.png 
# add drop shadow
$convert temp.png \( +clone -background black -shadow 80x3+20+20 \) +swap -background white -layers merge +repage shadow.png 
#create label and add it with composite

#$convert -font /homespace/gaubert/.gimp-2.6/plug-ins/fonts/Candice.ttf  -pointsize 36 label:"$text" label.png 
#$convert -font /homespace/gaubert/.gimp-2.6/plug-ins/fonts/Candice.ttf  -size "$W"x85 -pointsize 36 caption:"$text" label.png

#label size: remove the 50 pixels corresponding to the borders
W=$(($W-50))
$convert -font $IMG_MANIP_HOME/fonts/Candice.ttf -gravity center -size "$W"x60 label:"$text" label.png
#when we have a label without any size
#$composite label.png -gravity south -geometry +0+52 shadow.png out.png

$composite label.png -gravity south -geometry +0+40 shadow.png out.png
cp out.png $out

rm -Rf $working_dir

exit 0

