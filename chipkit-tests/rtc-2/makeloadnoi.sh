here=`cygpath -w "$(pwd)"`
cat >$1.noi <<EOF
LOAD $here\\$1.hex
EOF

D=\$
cat $1.noi $1.sym > $1andsyms.noi
echo "REG PC $D$2" >> $1andsyms.noi

