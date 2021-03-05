# plan.sh file
# Run a Terraform plan for a Fastly service

# Get Top Level Directory
rdir=`pwd`

# Get's the FASTLY_SERVICE without the leading "plan:" bit
FASTLY_SERVICE=`echo $CI_JOB_NAME | sed s/"plan:"//`

echo "\033[34;1m ########## Starting Plan stage for $FASTLY_SERVICE ##########\033[0;m"

# Copy all "shared" VCL, TF, log_format files, and VCL snippets into the working directory
cp $rdir/code/logs/log_format.json services/$FASTLY_SERVICE/log_format.json
cp -r $rdir/code/terraform/. services/$FASTLY_SERVICE
cp -r $rdir/code/vcl/. services/$FASTLY_SERVICE
cp -r $rdir/code/snippets/. services/$FASTLY_SERVICE

# Enters config folder for related JOB
cd services/$FASTLY_SERVICE

# Sets the version_comment variable in the config to the CI_COMMIT SHA
sed -i "/#ID0003/c\  version_comment = \"$CI_COMMIT_SHORT_SHA-APPLY\"" fastly.tf

# #### Setup AWS Creds Here ####
# Set your AWS creds here. I will not supply code for how to do this as it can be done in countless ways
# You can set access/secret keys from CICD variables, use a service like Vault, or another solution
# You will need to configure AWS to authenticate with your remote TF state in S3/DynamoDB (AWS)

# Runs TF init, plan, and show
TF_FILE="tfplan_"$FASTLY_SERVICE
terraform init
terraform plan -lock-timeout=240s -out=$TF_FILE > check # exports the plan file and check file
terraform show $TF_FILE -no-color > viewplan # saves a readable version of the plan as an artifact
terraform show -json $TF_FILE > plan.json # saves json version
cat check | grep -e '0 to destroy.' -z # runs a check to ensure nothing is being destroyed

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
            "text": ">❌ *Plan Stage Failed:* `'$FASTLY_SERVICE'`"
        }'

        exit 1
        
    else

        # Prints a warning if error was thrown and no changes found
        cat check
        echo "\033[34;1m[!] No Changes are being made. Are you really sure you wish to continue the pipeline? Please ensure your changes are correct. You may proceed with caution. \033[0;m"

        curl -v -X POST $SLACK_URL \
        -H "Content-Type: application/json" \
        -d \
        '{
            "text": ">⚠️ *Terraform Warnings:* `'$CI_JOB_NAME'` - <'$CI_PIPELINE_URL'|Link>"
        }'

    fi
else

    # Checks passed
    cat check
    echo "\033[32;1mPlan stage for $CI_JOB_NAME Succeeded!\033[0;m"

fi
