here=`cygpath -w "$1"`
there=`cygpath -w "$(dirname $1)/../tools/srload-noice"`
mos=`cygpath -w "$1/../../mos/beeb6809-mos"`
ROMNO=$3
cat >$2 <<EOF
LOAD $here 4000 B
LOAD $there\\srload.hex
REG B \$$ROMNO
GO 3F00
EOF

