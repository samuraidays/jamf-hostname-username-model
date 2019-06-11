#!/bin/sh

jssUser=$4
jssPass=$5
jssHost=$6

serial=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}')

username=$(/usr/bin/curl -H "Accept: text/xml" -sfku "${jssUser}:${jssPass}" "${jssHost}/JSSResource/computers/serialnumber/${serial}/subset/location" | xmllint --format - 2>/dev/null | awk -F'>|<' '/<username>/{print $3}')

modelName=`ioreg -c IOPlatformExpertDevice | grep MacBook | awk -F"= " '/model/{ print $2 }' | sed -e 's/^..//;s/..$//;s/[0,-9]*//g'`

## If either the username or model name came back blank from the above API calls, exit
if [[ "$username" == "" ]] || [[ "$modelName" == "" ]]; then
    echo "Error: The Username or Model Name field is blank."
    exit 1
else
    fullCompName="${username}-${modelName}"

    echo $fullCompName
    /usr/sbin/scutil --set HostName "$fullCompName"
    /usr/sbin/scutil --set LocalHostName "$fullCompName"
    /usr/sbin/scutil --set ComputerName "$fullCompName"
fi
