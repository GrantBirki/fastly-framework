# This file goes along with the code/ci/approval/approval.sh file.
# This script posts a message into a desired Slack channel that a
# change request has been generated and is awaiting for approval.
# This helps get eyes on your Fastly changes :)

import requests
import os, sys
from datetime import datetime, timedelta
from dateutil import parser

sn_id = sys.argv[1].replace('"', '')
sn_link = sys.argv[2].replace('"', '')
sn_status = sys.argv[3].replace('"', '').replace('-', ' ')
now = parser.parse(str(sys.argv[4])) - timedelta(hours=7)
now_plus_one_hour = parser.parse(str(sys.argv[5])) - timedelta(hours=7)
pipeline_url = sys.argv[6].replace('"', '')
sha = sys.argv[7]

now_str = f'{now.hour}:{now.minute} {now.day}-{now.month}-{now.year}'
now_plus_one_hour_str = f'{now_plus_one_hour.hour}:{now_plus_one_hour.minute} {now_plus_one_hour.day}-{now_plus_one_hour.month}-{now_plus_one_hour.year}'

text = f'📯 *Approval Requested:*\n>*Service Now Link:* <{sn_link}|Link>\n>*Pipeline:* {sha} <{pipeline_url}|Link>\n>*Service Now CR ID:* {sn_id}\n>*Service Now Status:* {sn_status}\n>*Change Window:* {now_str} - {now_plus_one_hour_str} PST'

SLACK_URL = os.environ['SLACK_URL']
slack = requests.post(url=SLACK_URL, json={'text': text})

print(f'Slack Status: {slack.status_code}')