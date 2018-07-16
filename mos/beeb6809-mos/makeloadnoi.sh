here=`cygpath -w "$1"`
there=`cygpath -w "$1/../beebMOSloader-noice"`
cat <<EOF
LASTFILELOADED
L $there\\mosloader.hex
L $here\\$2 4000 B
GO 2000
EOF
