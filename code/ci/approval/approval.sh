# approval.sh file
# This script is completely optional
# If you are using ServiceNow for approval requests of services,
# you can adapt this script to automatically generate a change request
# directly from this pipeline.
# This is just an example of how that could be done with Company X

# This script assumes usernames and passwords for service now are in your environment variables.
usage="$(basename "$0") [-h] [-e] -- send Service Now change request

where:
   -h  show this help text
   -e  (required) the DeployEnv (prod, nonprod, dev, or test)"

DEPLOY_ENV=$1

shift "$((OPTIND - 1))"

case $DEPLOY_ENV in
   "")
     echo "A DeployEnv is required (e.g. prod, nonprod, dev or test)"
     echo "$usage" >&2
     exit 1
     ;;
   # Accessible with prod credentials.
   prod)
     SERVICE_NOW_URL="https://<service_now_url_here>/api/"
     ;;
   # We are using nonprod credentials which will work for nonprod, dev, and test apis. Need to be in env variables
   nonprod)
     SERVICE_NOW_URL="https://<service_now_url_here>/api/"
     ;;
   dev)
     SERVICE_NOW_URL="https://<service_now_url_here>/api/"
     ;;
   test)
     SERVICE_NOW_URL="https://<service_now_url_here>/api/"
     ;;
esac

if [[ "${DEPLOY_ENV}" = "prod" ]]; then
  SERVICE_NOW_USER=${SERVICENOW_PROD_USER}
  SERVICE_NOW_PASSWORD=`echo ${SERVICENOW_PROD_PASSWORD} | base64 -d`
  # The above line is base64 encoded so it can be masked
else
  # Eventually, we will want to use different gitlab var names for prod and nonprod.
  SERVICE_NOW_USER=${SERVICENOW_NONPROD_USER}
  SERVICE_NOW_PASSWORD=${SERVICENOW_NONPROD_PASSWORD}
fi

# Planning for changes to happen 8 hours from now
NOW_PLUS_ONE_HOUR="$(date --date="+1 Hours" '+%Y-%m-%dT%H:%M:%Sz')"
NOW="$(date '+%Y-%m-%dT%H:%M:%Sz')"

echo "Send Service Now Request"

echo " Project URL: $CI_MERGE_REQUEST_PROJECT_URL"
echo " Source Branch: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME"
echo " CI COMMIT MESSAGE: $CI_COMMIT_MESSAGE"

SERVICE_NOW_RESPONSE=$(curl --silent /dev/null-X POST \
  "$SERVICE_NOW_URL" \
  --user "$SERVICE_NOW_USER":"$SERVICE_NOW_PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{ "entity": "change",
    "input": {
      "short_description":"Fastly - Change Requested - Commit: '$CI_COMMIT_SHORT_SHA'",
      "description":"Pipeline URL: '$CI_PIPELINE_URL' | Branch: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'\nFastly Pipeline Managed by the X Team\nContact: x@email.com & #slack_channel",
      "assignment_group":"x group",
      "start_date":"'"$NOW"'",
      "end_date":"'"$NOW_PLUS_ONE_HOUR"'",
      "production_system":"'"$DEPLOY_ENV"'"
       }
     }'
 )

SERVICE_NOW_ERROR="$(echo "${SERVICE_NOW_RESPONSE}" | jq '.error.detail')"

# Confirming link to the change request was created and not null
SN_CHANGE_LINK="$(echo "${SERVICE_NOW_RESPONSE}" | jq '.result.link')"
SN_CHANGE_REQUEST_ID="$(echo "${SERVICE_NOW_RESPONSE}" | jq '.result.number')"
SN_CHANGE_STATUS="$(echo "${SERVICE_NOW_RESPONSE}" | jq '.result.state.displayValue')"

if [[ ${SERVICE_NOW_ERROR} != null ]]; then
  echo "Error [ServiceNow]: ${SERVICE_NOW_ERROR}"
  exit 1
elif [[ "$SN_CHANGE_LINK" != null && "$SN_CHANGE_LINK" != "" ]]; then
  echo "View Service Now change request: ${SN_CHANGE_LINK}"
  echo "Service Now change request ID: ${SN_CHANGE_REQUEST_ID}"
  echo "Service Now change request status: ${SN_CHANGE_STATUS}"
  echo "You must wait for approval before deploying change"

  SN_CHANGE_STATUS=$(echo $SN_CHANGE_STATUS | tr " " "-")

  pip3 -q install requests==2.23.0
  pip3 -q install python-dateutil==2.8.1
  python3 code/ci/slack/approve.py $SN_CHANGE_REQUEST_ID $SN_CHANGE_LINK $SN_CHANGE_STATUS $NOW $NOW_PLUS_ONE_HOUR $CI_PIPELINE_URL $CI_COMMIT_SHORT_SHA

else
  echo "Error: Unable to send change request."
  echo  "${SERVICE_NOW_RESPONSE}" | jq '.error.message'
  echo "$SERVICE_NOW_RESPONSE"
  exit 1
fi
