#/bin/bash
echo -n "SELECT OPTION : RESET TERMINAL ENV [1]  /  CONTINUTE [2] : "
read VAR

if [[ $VAR -eq 1 ]]
then
    echo "Unsetting terminal ENV"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SECURITY_TOKEN
else
    echo -n "Enter CUSTOMER ID : "
    read cusid

    # read cusfile.json and define values to variables
    v1=`cat cusfile.json | jq -r .Customer${cusid}.role | cut -d'"' -f2`
    v2=`cat cusfile.json | jq -r .Customer${cusid}.externalid | cut -d'"' -f2`
    v3=`cat cusfile.json | jq -r .Customer${cusid}.arn | cut -d'"' -f2`

    # run sts command for requesting assume role permission and output file 
    aws sts assume-role --role-session-name $v1 --external-id $v2 --role-arn $v3 > stsassumerole.json

    # read otput file and define values to variables
    AccessKeyId=`cat stsassumerole.json | jq -r .Credentials.AccessKeyId | cut -d'"' -f2`
    SecretAccessKey=`cat stsassumerole.json | jq .Credentials.SecretAccessKey | cut -d'"' -f2`
    SessionToken=`cat stsassumerole.json | jq .Credentials.SessionToken | cut -d'"' -f2`

    # export aws credeintials 
    export AWS_ACCESS_KEY_ID=$AccessKeyId
    export AWS_SECRET_ACCESS_KEY=$SecretAccessKey
    export AWS_SESSION_TOKEN=$SessionToken
    export AWS_SECURITY_TOKEN=$SessionToken
fi
# # varify 

aws sts get-caller-identity | jq
aws s3 ls

# source assumerole.sh  
# prageeth pk arn:aws:iam::621073710421:role/my-assume-role
