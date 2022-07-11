here=`cygpath -w "$(pwd)"`
there="$1"
cat >"$1/$2.noi" <<EOF
LOAD $(cygpath -w "$there")\\$2.hex
EOF

D=\$
cat "$there/$2.noi" "$there/$2.sym" > "$there/$2andsyms.noi"
echo "REG PC $D$3" >> "$there/$2andsyms.noi"

