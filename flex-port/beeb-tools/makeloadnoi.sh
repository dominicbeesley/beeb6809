here=`cygpath -w "$(pwd)"`
there=`cygpath -w "$(dirname "$1")"`
bin=`cygpath -a -w "$2"`
cat >$1 <<EOF
LOAD $bin
EOF

