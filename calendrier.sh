#!/bin/bash
date=$(for (( i=0; i<=6; i++ ))
do
    date=$(date -d "$debu -$i day" +%u)
    if [ $date -eq 1 ]
    then
        echo $(date -d "$debu -$i day" +%Y-%m-%d)
    fi
done)
d=$(./del0.sh $(date -d "$date" +%d))
m=$(./del0.sh $(date -d "$date" +%m))
y=$(date -d "$date" +%Y)
debu=$(zenity --calendar --date-format=%Y-%m-%d --text=debu --day="$d" --month="$m" --year="$y")
date=$(date -d "$debu +7 day")
d=$(./del0.sh $(date -d "$debu +7 day" +%d))
m=$(./del0.sh $(date -d "$debu +7 day" +%m))
y=$(date -d "$debu +7 day" +%Y)
fin=$(zenity --calendar  --day="$d" --month="$m" --year="$y" --date-format=%Y-%m-%d --text=fin)


login=$(cat test.json)
id=$(tr -d '"-"' <<< $(echo $login| jq ".id"))
mdp=$(tr -d '"-"' <<< $(echo $login| jq ".mdp"))
if [ -n "$id" ]; then
    i=0
else
    export login=$(zenity --password --username)
    id=$(echo $login | cut -d"|" -f1)
    mdp=$(echo $login | cut -d"|" -f2)
    if [$login -eq ""]; then
            exit
    fi
    echo '{"id":"'$id'","mdp":"'$mdp'"}'>test.json
fi
if [ -n "$mdp" ]; then
    i=0
else
    export login=$(zenity --password --username)
    id=$(echo $login | cut -d"|" -f1)
    mdp=$(echo $login | cut -d"|" -f2)
    echo '{"id":"'$id'","mdp":"'$mdp'"}'>test.json
    if [$login -eq ""]; then
            exit
    fi
fi



code=505
while [ $code -eq 505 ]; do
    login=$(curl 'https://api.ecoledirecte.com/v3/login.awp?v=1.8.28' --data-raw $'data={    "uuid": "",    "identifiant":"'$id'","motdepasse":"'$mdp'","isReLogin": false}'   --compressed) 
    code=$(tr -d '"-"' <<< $(echo $login| jq ".code"))
    message=$(tr -d '"-"' <<< $(echo $login| jq ".message"))
    echo $code
    if [ $code -eq 505 ]; then
        zenity --error --text="$message"
        export login=$(zenity --password --username)
        if [$login -eq ""]; then
            exit
        fi
        id=$(echo $login | cut -d"|" -f1)
        mdp=$(echo $login | cut -d"|" -f2)
        echo '{"id":"'$id'","mdp":"'$mdp'"}'>test.json
    fi
done
gcalcli calendar
gcalcli list --client-id=912668712778-c6pekdlbq3fqdmpd656qdj56g7p4ggnj.apps.googleusercontent.com --client-secret=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



token=$(tr -d '"-"' <<< $(echo $login| jq ".token"))
calendier=$(curl 'https://api.ecoledirecte.com/v3/E/9369/emploidutemps.awp?verbe=get&v=1.8.28' -H "x-token: $token" --data-raw $'data={    "dateDebut": "'$debu'",    "dateFin": "'$fin'",    "avecTrous": false}'    --compressed)

i=null
echo "________________________________"$i"________________________________"

for (( i=0; i<=30; i++ ))
do
debuEvent=$(echo $calendier | jq ".data | .[$i] | .start_date")
debuEvent=$(tr -d '"-"' <<< ${debuEvent})
finEvent=$(echo $calendier | jq ".data | .[$i] | .end_date")
finEvent=$(tr -d '"-"' <<< ${finEvent})
hDE=$(./del0.sh $(date --date="$debuEvent" +%H))
hFE=$(./del0.sh $(date --date="$finEvent" +%H))
mDE=$(./del0.sh $(date --date="$debuEvent" +%M))
mFE=$(./del0.sh $(date --date="$finEvent" +%M))
echo debue $debuEvent fin $finEvent
duration=$((($hFE*60+$mFE)-($hDE*60+$mDE)))
date=$debuEvent
title=$(echo $calendier | jq ".data | .[$i] | .text")
title=$(tr -d '"-"' <<< ${title})
echo duration $duration date $date title $title
gcalcli add --calendar "yuhanpaire@gmail.com" --when "$date" --duration "$duration" --title "$title" --noprompt
echo "________________________________"$i"________________________________"
done
