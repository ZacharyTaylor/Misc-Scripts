#process velodyne
echo "Procissing velodyne points"
mkdir velodyne
cd velodyne
cat $SOURCE_DIR/velodyne/*.bin | velodyne-to-csv --db "$CONFIG_DIR/velodyne/db.xml" --fields=x,y,z,intensity,scan,id,t,valid --binary --output-invalid-points > velodyne.bin
cd ../
