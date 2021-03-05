# This job shows you how you can post a merge_request update to a service like Slack

curl -v -X POST $SLACK_URL \
      -H "Content-Type: application/json" \
      -d \
      '{
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "New Merge Request for Fastly\nMR Author: '$GITLAB_USER_EMAIL'"
                }
            },
            {
                "type": "actions",
                "block_id": "actionBlockMR",
                "elements": [
                    {
                        "type": "button",
                        "text": {
                            "type": "plain_text",
                            "text": "View MR"
                        },
                        "style": "primary",
                        "url": "'$CI_MERGE_REQUEST_PROJECT_URL'/-/merge_requests/'$CI_MERGE_REQUEST_IID'"
                    }
                ]
            }
        ]
    }'