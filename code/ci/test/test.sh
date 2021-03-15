# test.sh file
# Creates an ephemeral Fastly Service.
# In this example the service is created and then instantly destroyed.
# In the real world you could run tests against this service to ensure your changes
# are working as expected.

# Get Top Level Directory
rdir=`pwd`

# Get's the FASTLY_SERVICE without the leading "test:" bit
FASTLY_SERVICE=`echo $CI_JOB_NAME | sed s/"test:"//`

echo "\033[34;1m ########## Starting Test Stage for $FASTLY_SERVICE ##########\033[0;m"

# Copy all "shared" VCL, TF, log_format files, and VCL snippets into the working directory
cp $rdir/code/logs/log_format.json services/$FASTLY_SERVICE/log_format.json
cp -r $rdir/code/terraform/. services/$FASTLY_SERVICE
cp -r $rdir/code/vcl/. services/$FASTLY_SERVICE
cp -r $rdir/code/snippets/. services/$FASTLY_SERVICE
cp $rdir/code/ci/test/test.tf services/$FASTLY_SERVICE/test.tf # config for test Fastly Services

# #### Setup AWS Creds Here ####
# Set your AWS creds here. I will not supply code for how to do this as it can be done in countless ways
# You can set access/secret keys from CICD variables, use a service like Vault, or another solution
# You will need to configure AWS to authenticate with your remote TF state in S3/DynamoDB (AWS)

# Enters config folder for related JOB
cd services/$FASTLY_SERVICE
rm config.tf # removes old config.tf and since we are using test.tf

# Sets the version_comment variable in the config to the CI_COMMIT SHA
sed -i "/#ID0003/c\  version_comment = \"$CI_COMMIT_SHORT_SHA-TEST\"" fastly.tf

# Sets the key variables to TEST-{FASTLY_SERVICE} for TF state in dynamoDB and S3
sed -i "/#ID0001/c\      key            = \"fastly/services/TEST-$FASTLY_SERVICE/terraform.tfstate\"" test.tf

# Replace service name with TEST-$CI_COMMIT_SHORT_SHA-ci-$servicename - This is for the temp service and testing
sed -i "/#ID0001/c\  name = \"TEST-$CI_COMMIT_SHORT_SHA-ci-$FASTLY_SERVICE\"" fastly.tf

# Runs TF init, plan, and show - then checks output
TF_FILE="tfplan_"$FASTLY_SERVICE
terraform init
terraform plan -lock-timeout=240s -out=$TF_FILE -var "FastlyEnv=TEST-$CI_COMMIT_SHORT_SHA" > check
terraform show $TF_FILE -no-color > viewplan

# Checks the output of TF plan
cat check | grep -e '0 to destroy.' -z # If noting is being destroyed, continue
if [ $? -ne 0 ]; 
then
  cat check
  echo "\033[31;1mERROR: Terraform should not destroy Fastly services - especially in the test stage. Expected results are Add/Change only.\033[0;m\n"
  exit 1
else
  # If checks succeed, run TF apply
  terraform apply -lock-timeout=240s -input=false $TF_FILE
  if [ $? -ne 0 ];
  then
    echo "\033[31;1m[!] ERROR: An error occured when running 'Terraform apply' for [$FASTLY_SERVICE]. You may view the error above for troubleshooting. Since an error occured, this stage will now fail and hault the pipeline. The corresponding Fastly test service will now be destroyed.\033[0;m\n"
    terraform destroy -auto-approve
    exit 1
  fi

  # You could write a script to do automated testing against your service here...

  # Once testing is done we auto destroy the temporary service

  terraform destroy -auto-approve

  echo "\033[32;1m[+] Test stage for $FASTLY_SERVICE Succeeded!\033[0;m"

fi

cd $rdir
