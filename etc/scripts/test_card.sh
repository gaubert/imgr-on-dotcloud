#!/bin/bash
set -x

# At work
IMG_MANIP_HOME=/homespace/gaubert/Dev/projects/imgr-on-dotcloud/etc
IMAGEMAGICK_DIR=/homespace/gaubert/ImageMagick-6.6.9-8

# On my laptop 
#IMG_MANIP_HOME=/home/aubert/Dev/projects/imgr-on-dotcloud/etc
#IMAGEMAGICK_DIR=/usr
# on dotcloud
#IMG_MANIP_HOME=/home/dotcloud/code/etc
#IMAGEMAGICK_DIR=/usr

font_dir=$IMG_MANIP_HOME/fonts/

convert=$IMAGEMAGICK_DIR/bin/convert
composite=$IMAGEMAGICK_DIR/bin/composite

in=$1
text=$2
out=$3

usage="$0 input_file \"My text to add\" output_file"

if [ -z "$in" ]; then
  echo "in is not defined"
  exit 1
fi

if [ -z "$out" ]; then
  echo "out is not defined"
  exit 1
fi

# delete out
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

cd $working_dir

#resize image and add border of 25x25 | add bigger bottom border
$convert $in -normalize -resize 640x480^ -bordercolor White -border 25x25 - | $convert - -gravity south -splice 0x60 -background White -gravity Center -append temp.jpg 

#get width and height of the produced picture
#W=`convert dummy.jpg -format %w info:`
W=`convert temp.jpg -format %w info:`
#echo "W is $W"
H=`convert temp.jpg -format %h info:`

# create a mask fro rounding the borders
#create mvg mask
# apply the mask
$convert temp.jpg -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+4] 15,15' info: > rounded_corner.mvg
$convert temp.jpg -border 3 -alpha transparent -background none -fill white -stroke none -strokewidth 0 -draw "@rounded_corner.mvg" rounded_corner_mask.png
$convert temp.jpg -matte -bordercolor none -border 3 rounded_corner_mask.png -compose DstIn -composite temp.png 
# add drop shadow
$convert temp.png \( +clone -background black -shadow 80x3+20+20 \) +swap -background white -layers merge +repage shadow.png

#create label and add it with composite
#$convert -font /homespace/gaubert/.gimp-2.6/plug-ins/fonts/Candice.ttf  -pointsize 36 label:"$text" label.png 
#$convert -font /homespace/gaubert/.gimp-2.6/plug-ins/fonts/Candice.ttf  -size "$W"x85 -pointsize 36 caption:"$text" label.png

#label size: remove the 50 pixels corresponding to the borders
# before version
#W=$(($W-50))
#$convert -font $IMG_MANIP_HOME/fonts/Candice.ttf -gravity center -size "$W"x60 label:"$text" label.jpg

#adjust label width 45 seems to be the best for the moment
W=$(($W-45))
#60 is the size for a one liner
#$convert -font $IMG_MANIP_HOME/fonts/Candice.ttf -pointsize 50 -size "$W"x60 -gravity center label:"$text" label.jpg
$convert -font $IMG_MANIP_HOME/fonts/communi.ttf -pointsize 33 -size "$W"x60 label:"$text" label.jpg
#when we have a label without any size
##$composite label.png -gravity south -geometry +0+52 shadow.png out.png
#$composite label.jpg -gravity south -geometry +0+40 shadow.png out.jpg
# ajust the height
H=$(($H-68))
# first value in geometry is the x position
$composite label.jpg -geometry +20+"$H" shadow.png out.jpg

# when font is dynamic not -pointsize
# with this font (Candice)19 characters can be put in one line for the max size font
# From 20 up to will keep a correct size font
# WHEN Font size is fixed and Candice
# for up to 20 characters => pointsize 60
# for up to 22 characters => pointsize 55
# for up to 24 characters => pointsize 50
# for up to 30 characters => pointsize 40 
# for up to 40 characters => pointsize 30
# with H=$(($H-68)) with this for Candice

# For zil font
# For up to 20 characters => pointsize 56 
# For up to 24 characters => pointsize 43 
# For up to 30 characters => pointsize 35 
# For up to 40 characters => pointsize 27 
# Need to calculate the center point

# for communi font
# For up to 20 characters => pointsize 58 
# For up to 24 characters => pointsize 45 
# For up to 30 characters => pointsize 35 
# For up to 40 characters => pointsize 27 
# Need to calculate the center point


# -gravity center to center the font but without it, it is left justified

cp out.jpg $out

#rm -Rf $working_dir

exit 0

