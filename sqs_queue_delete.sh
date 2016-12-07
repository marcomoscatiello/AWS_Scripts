#!/bin/bash

#this script is used to delete the existing queues from aws. It gets a source file as argument where each line contains the name of the queues to delete.

source_file=$1

while read line;

do
  queue_name=`echo $line | awk '{print $1}'`


  #Get queue url
  queue_url=$(aws sqs get-queue-url --queue-name  $queue_name | grep QueueUrl | awk -F ": " '{print$2}' | sed 's/"//g' )

  echo Queue_name $queue_name
  echo Queue_URL $queue_url
  aws sqs delete-queue --queue-url $queue_url

done < $source_file
