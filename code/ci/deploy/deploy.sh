# deploy.sh file
# Makes an API call to Fastly to toggle the service from the Apply stage to "activated".

# Get Top Level Directory
rdir=`pwd`

# Get's the FASTLY_SERVICE without the leading "deploy:" bit
FASTLY_SERVICE=`echo $CI_JOB_NAME | sed s/"deploy:"//`

echo "\033[34;1m ########## Starting Deploy stage for $FASTLY_SERVICE ##########\033[0;m"

# Enters config folder for related JOB
cd services/$FASTLY_SERVICE

pip3 -q install requests==2.23.0
python3 $rdir/code/ci/deploy/deploy.py $FASTLY_API_KEY $FASTLY_SERVICE $CI_COMMIT_SHORT_SHA $CI_PIPELINE_URL

echo "\033[32;1mDeploy stage for $CI_JOB_NAME Succeeded!\033[0;m"