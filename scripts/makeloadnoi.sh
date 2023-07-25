export MY_FILE="`readlink -f "$0"`"
export MY_DIR="`dirname "$MY_FILE"`"
local=$($MY_DIR/winpath.sh "$(pwd)")
cat >$1.noi <<EOF
LOAD $local\\$1.hex
EOF

D=\$
cat $1.noi $1.sym > $1andsyms.noi
echo "REG PC $D$2" >> $1andsyms.noi

