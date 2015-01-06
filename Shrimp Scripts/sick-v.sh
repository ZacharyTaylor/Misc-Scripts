#process sick-v
echo "Processing vertical sick"
mkdir sick-v
cd sick-v
cat $SOURCE_DIR/sick-v/*.bin | sick-to-csv --fields='t,x,y,reflectivity,scan' --binary > sick-v.bin
cd ../
