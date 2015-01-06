#process novatel nav
echo "Processing Novatel nav solution"
mkdir novatel
cd novatel
cat $SOURCE_DIR/novatel/*.bin | novatel-to-csv --fields=t,position,velocity,rate > NavData.csv
cd ../
