# project-stats



A ~~hacky~~ simple script that pulls the history of PR's to a github repo and stores the json in a local file for analysis. This was used to quickly create a means to capture historical stats by quarter and is quite basic. 


`scrape-pulls.sh`

A bash script that uses your github auth token to scrape all pages of results from the github API for your repo. Set `GITHUB_API_TOKEN` to your API token in quotes, also set `GITHUB_ORG_REPO` to the string representing the org/repo (like "ebeer/project-stats"). Output is stored in `scrape-pulls.out` in the same directory as the script.

You can then run analysis from the output file like the following using `jq`.



Pull Requests by user during a time period

```
jq --arg s '2021-02-01' --arg e '2021-04-31' 'map(select(.closed_at | . >= $s and . <= $e + "z")) | group_by(.user.login) | map({"user": .[0].user.login, "total":length})' scrape-pulls.out
```


Pull Request open to close time (average in days) during time period

```
jq  --arg s '2021-02-01' --arg e '2021-04-31'  'def duration($finish; $start): def twodigits: "00" + tostring | .[-2:]; [$finish, $start] | map(fromdate) | .[0] - .[1] ; map(select(.closed_at | . >= $s and . <= $e + "z")) | map( {time: duration(.closed_at;.created_at)}) |  { avgdays: (([.[].time] | add) / ([.[].time] | length) / 86400)}' scrape-pulls.out
```
