sqs_policy='{
"Version": "2012-10-17",
"Id": "arn:aws:sqs:eu-west-1:147453477443:test-marco/SQSDefaultPolicy",
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
"Resource": "arn:aws:sqs:eu-west-1:147453477443:dev1-wowcher-sailthru-subscription"
}
]
}'
sqs_policy_escaped=$(echo $sqs_policy | perl -pe 's/"/\\"/g')
sqs_attributes='{"Policy":"'$sqs_policy_escaped'"}'
aws sqs set-queue-attributes --queue-url https://sqs.eu-west-1.amazonaws.com/147453477443/test-marco  --attributes "$sqs_attributes"
