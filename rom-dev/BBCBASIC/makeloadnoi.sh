here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(pwd)/../tools/srload-noice"`
cat >loadbasic-chipkit.noi <<EOF
LOAD $here\\MAND2 E00 B
LOAD $here\\6809BAS.bin 4000 B
LOAD $there\\srload.hex
REG B 09
GO 3F00
EOF

cat >loadbasic.noi <<EOF
LOAD $here\\PROCS E00 B
LOAD $here\\6809BAS.bin 8000 B
EOF