#process sick-h
echo "Processing horizontal sick"
mkdir sick-h
cd sick-h
cat $SOURCE_DIR/sick-h/*.bin | sick-to-csv --fields='t,x,y,reflectivity,scan' --binary > sick-h.bin
cd ../
