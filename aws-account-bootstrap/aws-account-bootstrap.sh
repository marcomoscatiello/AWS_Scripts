#!/bin/sh
printf "this script creates the MyDriveSRE role to allow access to SRE team from the mydrive-aws-login account.\n"
#printf "insert the aws profile where you want to allow the assume_role access: "
#read profile
#printf "this is the profile you selected: \e[32m$profile\e[0m\n"

printf "Insert the AWS_Access_Key: "
read access_key
printf "Insert the AWS_Secret_Key: "
read secret_key

printf "you selected the the following AWS_Access_key: \e[32m$access_key\e[0m and the AWS_Secret_key: \e[32m$secret_key\e[0m\n"

read -p "Type yes/no to continue.. [yes/no]" answer
if [[ $answer = yes ]] ; then
  
  printf "Creating profile .... "
  AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_key aws iam create-role --role-name MyDriveTEST --assume-role-policy-document file://aws-sts-policy.json --output text
  if [ $? != 0 ]; then
    printf "\e[91mOperation Failed\e[0m\n"
    exit 1
  else
    printf "\e[32mOperation Successful\e[0m\n"
  fi

  printf "Attaching AdministratorAccess policy to the role .... "
  AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_key aws iam attach-role-policy --role-name MyDriveTEST  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --output text
  if [ $? != 0 ]; then
    printf "\e[91mOperation Failed\e[0m\n"
    exit 1
  else
    printf "\e[32mOperation Successful\e[0m\n"
  fi
  
else printf "Operation Aborted.\n"
fi
