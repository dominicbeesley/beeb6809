here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(dirname "$1")"`
cat >$1 <<EOF
LOAD $there\\modplay09.hex
EOF

