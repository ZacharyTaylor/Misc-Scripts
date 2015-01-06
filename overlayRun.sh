#Creates a movie from a bunch of overlayed images
#Useful in building velodyne images

INITAL_DIR="/home/z/Documents/Houdini/ICRA2015/rawVel"
BACK="/home/z/Documents/Houdini/ICRA2015/back.png"
FINAL_DIR="/home/z/Documents/Houdini/ICRA2015/together4"

mkdir $FINAL_DIR

#get images assuming they have numerical names
IMAGES=(`ls "$INITAL_DIR" | sort -n`)
set -- $IMAGES

#overlay the rest
for (( i = 1 ; i < ${#IMAGES[@]} ; i=$i+1 ));
do
    composite "$INITAL_DIR/${IMAGES[${i}]}" "$BACK" "$FINAL_DIR/$i.jpg"
    echo ${IMAGES[${i}]}
done

#convert to video
avconv -r 30 -start_number 1 -i "$FINAL_DIR/%d.jpg" -b:v 50000k "$FINAL_DIR/video.avi"

