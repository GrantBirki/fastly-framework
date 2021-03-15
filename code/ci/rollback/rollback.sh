# rollback.sh file
# Rolls back a Fastly service to its previous active version
# via the Fastly API.

# Get Top Level Directory
rdir=`pwd`

# Get's the FASTLY_SERVICE without the leading "rapid-rollback:" bit
FASTLY_SERVICE=`echo $CI_JOB_NAME | sed s/"rapid-rollback:"//` || exit 1

echo "\033[34;1m ########## Starting RAPID ROLLBACK stage for $FASTLY_SERVICE ##########\033[0;m" || exit 1

cd services/$FASTLY_SERVICE

pip3 -q install requests==2.23.0
python3 $rdir/code/ci/rollback/rollback.py $FASTLY_SERVICE $FASTLY_API_KEY $CI_COMMIT_SHORT_SHA $CI_PIPELINE_URL

if [ $? -ne 0 ];
    then

        echo "\033[31;1mERROR: Could not complete RAPID ROLLBACK.\033[0;m\n"

        # Uncomment this block if you are using the Slack integration
        # CURL to post Slack message
        # curl -v -X POST $SLACK_URL \
        # -H "Content-Type: application/json" \
        # -d \
        # '{
        #     "text": ">❌ *Rapid Rollback Failed:* `'$FASTLY_SERVICE'` - '$CI_COMMIT_SHORT_SHA' - <'$CI_PIPELINE_URL'|Link>"
        # }'

        exit 1

fi

echo "\033[32;1mRapid Rollback for $FASTLY_SERVICE Complete\033[0;m"