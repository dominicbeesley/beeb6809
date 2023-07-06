here=`../../scripts/winpath.sh "$1"`
there=`../../scripts/winpath.sh "$1/../beebMOSloader-noice"`
cat <<EOF
LASTFILELOADED
L $there\\mosloader.hex
L $here\\$2 4000 B
EOF
