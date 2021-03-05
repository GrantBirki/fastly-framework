# apply.sh file
# Use to run Terraform Apply to send up changes to Fastly.
# This does not activate the service, it simply stages it for deployment.

# Get Top Level Directory
rdir=`pwd`

# Get's the JOB_NAME without the leading "apply:" bit
JOB_NAME=`echo $CI_JOB_NAME | sed s/"apply:"//`

echo "\033[34;1m ########## Starting Apply stage for $FASTLY_SERVICE ##########\033[0;m"

cp $rdir/code/logs/log_format.json services/$FASTLY_SERVICE/log_format.json
cp -r $rdir/code/terraform/. services/$FASTLY_SERVICE
cp -r $rdir/code/vcl/. services/$FASTLY_SERVICE
cp -r $rdir/code/snippets/. services/$FASTLY_SERVICE

# Enters config directory for JOB
cd services/$FASTLY_SERVICE/

# Sets the version_comment variable in the config to the CI_COMMIT SHA
sed -i "/#ID0003/c\  version_comment = \"$CI_COMMIT_SHORT_SHA\"" fastly.tf

# #### Setup AWS Creds Here ####
# Set your AWS creds here. I will not supply code for how to do this as it can be done in countless ways
# You can set access/secret keys from CICD variables, use a service like Vault, or another solution
# You will need to configure AWS to authenticate with your remote TF state in S3/DynamoDB (AWS)

# Runs TF init, plan, and show - then checks output
TF_FILE="tfplan_apply_"$FASTLY_SERVICE
terraform init
terraform plan -lock-timeout=240s -out=$TF_FILE > check
terraform show -json $TF_FILE > plan-apply.json # saves json version
terraform show $TF_FILE -no-color > viewplan

cat check | grep -e '0 to destroy.' -z #checks output

if [ $? -ne 0 ]; 
then

    # Checks to see if return code of != 0 was due to no changes
    cat check | grep -e 'No changes.' -z

    if [ $? -ne 0 ];
    then

        # Throws an error and exits if error seen and changes found
        cat check
        echo "\033[31;1mERROR: Terraform should not destroy Fastly services. Expected results are Add/Change only.\033[0;m\n"

        # CURL to post Slack message
        curl -v -X POST $SLACK_URL \
        -H "Content-Type: application/json" \
        -d \
        '{
            "text": ">❌ *Apply Stage Failed:* `'$FASTLY_SERVICE'`"
        }'

        exit 1
        
    else

        # Prints a warning if error was thrown and no changes found
        cat check
        echo "\033[34;1m[!] No Changes are being made. Are you really sure you wish to continue the pipeline? Please ensure your changes are correct. You may proceed with caution. \033[0;m"

        terraform apply -lock-timeout=240s -input=false $TF_FILE
        terraform output -json > $FASTLY_SERVICE"_output.json"

        # CURL to post Slack message
        curl -v -X POST $SLACK_URL \
        -H "Content-Type: application/json" \
        -d \
        '{
            "text": ">🟢 *Apply Stage Completed with Warnings:* `'$FASTLY_SERVICE'` - '$CI_COMMIT_SHORT_SHA' - <'$CI_PIPELINE_URL'|Link>"
        }'

    fi
    
else
    # Succeeds Checks
    terraform apply -lock-timeout=240s -input=false $TF_FILE
    terraform output -json > $FASTLY_SERVICE"_output.json"
    echo "\033[32;1mApply stage for $CI_JOB_NAME Succeeded!\033[0;m"
fi