here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(pwd)/../tools/srload-noice"`
mos=`cygpath -w "$(pwd)/../../mos/beeb6809-mos"`
cat >loadUSBFS.noi <<EOF
LOAD $here\\USBFS.bin 4000 B
LOAD $there\\srload.hex
REG B 0A
GO 3F00
EOF

