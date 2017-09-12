here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(pwd)/../beebMOSloader-noice"`
cat >mosloadandrun.noi <<EOF
LASTFILELOADED
L $there\\mosloader.hex
L $here\\mosrom-noice.bin 4000 B
GO 2000
EOF
