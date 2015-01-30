DIR="/home/z/Desktop/Zac/beetroot"
VID_NAME="video"
FRAME_RATE="8"

CURRENT_DIR=$(pwd)
cd $DIR
mkdir temp

echo "copying images"
idx=1
for i in *.png; do
  new=$(printf "%04d.png" "$idx")
  cp -- "$i" "./temp/$new"
  let idx=idx+1
done

echo "generating video"
avconv -r $FRAME_RATE -i ./temp/%04d.png -loglevel 'panic' ./temp/temp.mkv
avconv -i ./temp/temp.mkv -loglevel 'panic' $VID_NAME.mp4

rm -R ./temp

cd $CURRENT_DIR

echo "finished"
