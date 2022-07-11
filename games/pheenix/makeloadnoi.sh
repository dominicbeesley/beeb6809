here=`cygpath -w "$(pwd)"`
cat >loadgame.noi <<EOF
LOAD $here\\game.hex
EOF

