#!/usr/bin/env bash

CSV_PATH="${1:-/c/Users/Administrator/Desktop/CMI_MCC_col_2_row.csv}"
OUT_PATH="${2:-/c/Users/Administrator/Desktop/mcc_import_commands.sh}"

cat > "$OUT_PATH" <<'EOF'
#!/usr/bin/env bash
export AUTHORIZATION="Bearer REPLACE_WITH_REAL_TOKEN"

EOF

awk -v out="$OUT_PATH" '
function parse_csv(line, a,    i,ch,in_q,field,n,nextch) {
  n=0
  field=""
  in_q=0
  for (i=1; i<=length(line); i++) {
    ch=substr(line,i,1)
    if (in_q) {
      if (ch=="\"") {
        nextch=substr(line,i+1,1)
        if (nextch=="\"") {
          field=field "\""
          i++
        } else {
          in_q=0
        }
      } else {
        field=field ch
      }
    } else {
      if (ch=="\"") {
        in_q=1
      } else if (ch==",") {
        a[++n]=field
        field=""
      } else {
        field=field ch
      }
    }
  }
  a[++n]=field
  return n
}

function jesc(s) {
  gsub(/\\/,"\\\\",s)
  gsub(/"/,"\\\"",s)
  gsub(/\r/,"\\r",s)
  gsub(/\n/,"\\n",s)
  gsub(/\t/,"\\t",s)
  return s
}

function sh_dq_esc(s) {
  gsub(/\\/,"\\\\",s)
  gsub(/"/,"\\\"",s)
  gsub(/\$/,"\\$",s)
  gsub(/`/,"\\`",s)
  return s
}

NR==1 { next }
{
  n=parse_csv($0,f)
  if (n < 4) next

  mcc=f[1]
  en=f[2]
  hs=f[3]
  ht=f[4]
  gsub(/\$/,"_",mcc)

  code="mcc" mcc
  en=jesc(en)
  hs=jesc(hs)
  ht=jesc(ht)

  payload="{\"dictCode\":\"" code "\",\"dictLabel\":\"" hs "\",\"sortOrder\":0,\"status\":1,\"remark\":\"\",\"parentId\":616,\"i18nList\":[{\"langCode\":\"zh-Hans\",\"dictLabel\":\"" hs "\"},{\"langCode\":\"en\",\"dictLabel\":\"" en "\"},{\"langCode\":\"zh-Hant\",\"dictLabel\":\"" ht "\"}]}"
  payload=sh_dq_esc(payload)
  cmd="curl -X POST \"https://testapi.esimtours.com/admin/system/dict-data\" -H \"accept: application/json, text/plain, */*\" -H \"accept-language: zh-CN,zh;q=0.9\" -H \"authorization: $AUTHORIZATION\" -H \"content-type: application/json\" -H \"x-client-lang: zh-Hans\" --data-raw \"" payload "\""
  print cmd >> out
}
' "$CSV_PATH"

echo "Generated: $OUT_PATH"
