#!/usr/bin/env bash

GITHUB_API_TOKEN="your token here"
GITHUB_ORG_REPO="some org/repo name"

GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
GITHUB_API_HEADER_AUTHORIZATION="Authorization:token ${GITHUB_API_TOKEN}"




temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1
OUTFILE=./scrape-pulls.out


last_count=`curl -s -I "https://api.github.com/repos/${GITHUB_ORG_REPO}/pulls?state=closed&per_page=100" -H "${GITHUB_API_HEADER_ACCEPT}" -H "${GITHUB_HEADER_AUTHORIZATION}" | grep -i '^link:' | sed -e 's/^[Ll]ink:.*[Pp]age=//g' -e 's/>.*$//g'`

if [ -z $last_count ]; then
    `curl -s "https://api.github.com/repos/${GITHUB_ORG_REPO}/pulls?state=closed&per_page=100" -H "${GITHUB_API_HEADER_ACCEPT}" -H "${GITHUB_HEADER_AUTHORIZATION}" | sed -e 's/^\[$//g' -e 's/^\]$/,/g' >> "$TMPFILE"`
else
    # yes - this result is on multiple pages
    for p in `seq 1 $last_count`; do
	    `curl -s "https://api.github.com/repos/${GITHUB_ORG_REPO}/pulls?state=closed&per_page=100&page=${p}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "${GITHUB_HEADER_AUTHORIZATION}" | sed -e 's/^\[$//g' -e 's/^\]$/,/g' >> "$TMPFILE"`
    done
fi

line_counter=`wc -l $TMPFILE | sed -e 's/[/a-zA-Z].*$//g'`

echo "[" >> "$OUTFILE"
head -n $(($line_counter - 1)) $TMPFILE >> "$OUTFILE"
echo "]" >> "$OUTFILE"
