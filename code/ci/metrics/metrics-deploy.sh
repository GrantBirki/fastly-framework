# metrics-deploy.sh file
# This job deploys the Fastly-to-Insights ECS Cluster to AWS

# Used to update New Relic ECS cluster for sending Fastly metrics to New Relic Insights

echo "\033[34;1m ########## Starting METRICS DEPLOY stage ##########\033[0;m"

# #### Setup AWS Creds Here ####
# Set your AWS creds here. I will not supply code for how to do this as it can be done in countless ways
# You can set access/secret keys from CICD variables, use a service like Vault, or another solution
# You will need to configure AWS to authenticate with your remote TF state in S3/DynamoDB (AWS)

# Enter TF Directory

cd code/logs/fastly-to-insights/infrastructure

# Runs TF init, plan, and show - then checks output
terraform init
terraform plan -lock-timeout=240s -out="metrics_plan" > check
terraform show "metrics_plan" -no-color > viewplan

if [ $? -ne 0 ]; 
then

    # Prints a warning if error was thrown
    cat check

    # CURL to post Slack message
    curl -v -X POST $SLACK_URL \
    -H "Content-Type: application/json" \
    -d \
    '{
        "text": ">❌ Metrics Stage Failed: <'$CI_PIPELINE_URL'|Link>"
    }'

    exit 1
    
else

    # Succeeds checks
    cat check
    terraform apply -lock-timeout=240s -input=false "metrics_plan"

    # CURL to post Slack message
    curl -v -X POST $SLACK_URL \
    -H "Content-Type: application/json" \
    -d \
    '{
        "text": ">🟢 Metrics Stage Deployed to AWS <'$CI_PIPELINE_URL'|Link>"
    }'

    echo "\033[32;1mPlan stage for $CI_JOB_NAME Succeeded!\033[0;m"
fi