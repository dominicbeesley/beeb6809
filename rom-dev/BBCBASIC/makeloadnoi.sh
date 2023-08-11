here=$(../../scripts/winpath.sh "$1")
there=$(../../scripts/winpath.sh "$(dirname $1)/../tools/srload-noice")
ROMNO=$3
cat >$2 <<EOF
LOAD $here 4000 B
LOAD $there\\srload.hex
REG B \$$ROMNO
GO 3F00
EOF
