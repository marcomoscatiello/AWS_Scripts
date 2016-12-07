#!/bin/bash

source_file="$1"

while read line;

do 
  topic_name=`echo $line | awk -F " : " '{print $1}'`

topic_arn=$(aws --output text sns list-topics | grep  "\<$topic_name\>"  |awk '{print $NF}' )

commnand="aws sns delete-topic --topic-arn $topic_arn"


#echo Topic Name: $topic_name
#echo Topic ARN: $topic_arn
$command
echo $topic_name deleted
echo ""
done < $source_file
