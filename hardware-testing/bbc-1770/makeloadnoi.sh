here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(dirname "$1")"`
cat >$1 <<EOF
LOAD $there\\bbc-1770.hex
EOF

