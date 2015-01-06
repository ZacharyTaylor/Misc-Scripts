#convert all data to format ready for matlab

export MATLAB="/usr/local/MATLAB/R2013b/bin/matlab"
export SOURCE_DIR="/home/z/Documents/Datasets/Shrimp/high-clutter/Raw"
export CONFIG_DIR="/home/z/Documents/Datasets/Shrimp/config"
export WRITE_DIR="/home/z/Documents/Datasets/Shrimp/high-clutter/Processed"

cd $WRITE_DIR

#convert each sensor (comment lines of sensors that are not needed)
. "$CONFIG_DIR/velodyne.sh" &
. "$CONFIG_DIR/ladybug.sh" &
. "$CONFIG_DIR/novatel.sh" &
. "$CONFIG_DIR/sick-v.sh" &
. "$CONFIG_DIR/sick-h.sh" &

wait
echo "Script complete"
