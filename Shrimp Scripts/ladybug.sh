#process ladybug
echo "Processing Ladybug"
mkdir ladybug
cd ladybug

for i in {0..5}
do
   echo "Camera $i"
   mkdir camera_$i
   cd camera_$i
	
   cat $SOURCE_DIR/ladybug/*.bin | cv-cat "bayer=1;crop-tile=0,$i,1,6;undistort=$CONFIG_DIR/ladybug/shrimp.ladybug.camera-$i.bin;transpose;flop;file=jpg;null"

cd ..

done

echo "Timestamps"
cat $SOURCE_DIR/ladybug/*.bin | cv-cat --output="header-only;fields=t" > timestamps.bin

cd ../
