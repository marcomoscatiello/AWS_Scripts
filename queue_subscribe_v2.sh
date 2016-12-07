#!/bin/bash

# This new version of queue subscribe is able to create topics and queues if not existing and also set the permissions for the new queue to everybody.

#for each line of the source file, get the topic name, protocol and the endpoint name
# example of a line in the source file:
# dev1-living-social-subscription : Queue : dev1-living-social-sailthru-unsubscription
#the queue_name can be a queue endpoint or an email that need to be subsbribed

#define as source file the first argument passed to the script
source_file="$1"

while read line; 

do 
  topic_name=`echo $line | awk -F " : " '{print $1}'`
  protocol=`echo $line | awk -F " : " '{print $2}'`
  endpoint_name=`echo $line | awk -F " : " '{print $3}'`  	


#Get the topic_arn from the topic name
#topic_arn=$(aws --output text sns list-topics | grep  "\<$topic_name\>"  |awk '{print $NF}' )
#aws --output text sns list-topics | grep  \<$topic_name\> |awk '{print $NF}' 
#echo $topic_arn
#echo $?
#if  "$?" = "1" ]; then
#if [[ -n "$(ls -A)" ]]; then
#  echo "Creating new Topic $topic_name"
#  aws sns create-topic --name $topic_name
#else
#  echo "Already existing"
#fi


#if aws return a null topic_arn because of the non existing topic, it creates the topic based on the topic name
if  topic_arn=$(aws --output text sns list-topics | grep  "\<$topic_name\>"  |awk '{print $NF}' ) > /dev/null; then
    aws sns create-topic --name $topic_name
    echo TOPIC $topic_name created.

fi

#Get the topic_arn
topic_arn=$(aws --output text sns list-topics | grep  "\<$topic_name\>"  |awk '{print $NF}' )

if [ $protocol = "Queue" ];
  then

  #If the queue is not existing, it gets created. After, Gets the queue endpoint_url from the queue name

  endpoint_url=$(aws sqs get-queue-url --queue-name  $endpoint_name | grep QueueUrl | awk -F ": " '{print$2}' | sed 's/"//g' )
  #check if the endpoint is empty. If yes, means the queue does not exist and needs to be created.
    if [ -z $endpoint_url ]; then
      aws sqs create-queue --queue-name $endpoint_name --attributes DelaySeconds=3
      echo "$endpoint_name was not existing. It has now been created."
      #calculate endpoint_arn. Calculate again the endpoint_url now that is existing.
      endpoint_url=$(aws sqs get-queue-url --queue-name  $endpoint_name | grep QueueUrl | awk -F ": " '{print$2}' | sed 's/"//g' )
      #calculate endpoint_arn of the queue created to set the permissions
      endpoint_arn=$(aws sqs get-queue-attributes --queue-url $endpoint_url --attribute-names QueueArn | grep QueueArn | awk -F ": " '{print $2}' |sed 's/"//g' )
      sqs_policy='{
      "Version": "2012-10-17",
      "Id": "$endpoint_arn/SQSDefaultPolicy",
      "Statement": [
      {
      "Sid": "AllowAllMessages",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
      "SQS:SendMessage",
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage"
      ],
      "Resource": "$endpoint_arn"
      }
      ]
      }'
      sqs_policy_escaped=$(echo $sqs_policy | perl -pe 's/"/\\"/g')
      sqs_attributes='{"Policy":"'$sqs_policy_escaped'"}'
      aws sqs set-queue-attributes --queue-url $endpoint_url  --attributes "$sqs_attributes"
    fi


#get the endpoint_arn to then subscribe the queue to the topic
  endpoint_arn=$(aws sqs get-queue-attributes --queue-url $endpoint_url --attribute-names QueueArn | grep QueueArn | awk -F ": " '{print $2}' |sed 's/"//g' )

  command="aws sns subscribe --topic-arn $topic_arn --protocol sqs --notification-endpoint $endpoint_arn"


#in the case of the email, you don't need to get the email arn as it doesn't exists

elif [ $protocol = "Email" ];
    then command="aws sns subscribe --topic-arn $topic_arn --protocol email --notification-endpoint $endpoint_name"

else 
    command="error: Protocol not supported."
fi

echo topic_name:$topic_name
echo topic_arn:$topic_arn
echo protocol:$protocol
echo endpoint:$endpoint_name
echo endpoint_url:$endpoint_url
echo endpoint_arn:$endpoint_arn
$command
echo ""

#define the source file
done < $source_file



