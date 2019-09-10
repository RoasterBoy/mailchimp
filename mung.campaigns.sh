#!/bin/bash
#
thisDir="$( cd "$(dirname "$0")" ; pwd -P )"
thisOut=bulletin.index.txt
thisDate=$(date)
echo "Page created on $thisDate" > $thisOut
indexFile=camp.txt
    verbose=false
#
# MC_key is stored in .bashrc
#
setup ()
{
#
    tmp=working
    if [ ! -d $tmp ]; then
	echo "tmp directory $tmp doesn\'t exist. Exiting ..."
	exit
    fi 
}
getDetails()
{
    thisCampaign=$1
    curl -s  --request GET \
	 --url 'https://us5.api.mailchimp.com/3.0/campaigns/'$thisCampaign'/content' \
	 --user 'anystring:'$MC_key'' --output $tmp/$thisCampaign.json
    doVerbose "Writing $thisCampaign.json to $thisOut"
    jq -r '.html' working/$thisCampaign.json | pup 'h2 text{}' >> $thisOut
#    wkhtmltopdf $thisCampaign.html $thisCampaign.pdf
    #
}
#--------------------------------------------------------- 

doVerbose()
{
    if [  "$verbose" = true ];
    then
	thisString=$@
	echo "%%- $thisString"
    fi
}
mungIt()
{
while IFS='' read -r thisLine ; do
echo "+--------------------+" >> $thisOut
    getDetails $thisLine
done  < working/campaigns.list
}
cleanUp()
{
    iconv -c -f utf-8 -t ascii  $thisOut > final.txt
    sed -ibak "/MC:SUBJECT/d" final.txt 
    sed -ibak2 "s/(In this issue|Contents)//g" final.txt
    sed -ibak3 '/^$/d' final.txt
    cat final.txt | tr -d '\t' > wise.bulletin.index.txt
}
#
msg()
{
echo  "[$@]" 
}

getHelp()
{
printf "Help would be here if it was here\n"
exit
}
while getopts "vs:n:h" opt; do
    case ${opt} in
	v ) # Verbose mode
	    verbose=true
	    ;;
	s ) # Date of first campaign in series
	    msg "Not yet implemented"
	    exit
	    startDate=$GETOPT
	    ;;
	n ) # Get this many campaigns. Manx is 100
	    msg "Not yet implemented"
	    exit
	    campaignCount=$GETOPT 
	    if [campaignCount -gt 100];
		then 
		msg "Campaign count exceeds 100 (MailChimp limit). Reduced to 100"
		campaignCount=100
	    fi 
	    ;;
	h) # Print help and exit
	    getHelp
	    ;;
	?)
	    getHelp
	    ;;
	
    esac
done
# 

setup
mungIt
cleanUp


