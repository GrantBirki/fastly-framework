import json
import os
import requests
import sys

FASTLY_API_KEY = sys.argv[1].replace('"', '')
FASTLY_SERVICE = sys.argv[2].replace('"', '')
CI_COMMIT_SHORT_SHA = sys.argv[3].replace('"', '')
CI_PIPELINE_URL = sys.argv[4].replace('"', '')

# ------------- Fastly Activation -------------
try:
    with open(f'{FASTLY_SERVICE}_output.json', 'r') as f:
        data = f.read()

    json_data = json.loads(data)

    service_id = json_data['service_id']['value']

    if json_data['active_version']['value'] == 0:
        version = 1
    else:
        version = json_data['cloned_version']['value']

    headers = {'Fastly-Key': FASTLY_API_KEY}
    r = requests.put(f'https://api.fastly.com/service/{service_id}/version/{version}/activate',
                     headers=headers)

except Exception as error:
    print(f'Error: {error}')
    sys.exit(1)

# For debugging and ensuring you don't get close to your API write limits (1,000 per hour)
print('[#] Fastly Activation Status Code', r.status_code)
print('[#] Fastly Rate Limit Remaining', r.headers['Fastly-RateLimit-Remaining'])
print('[#] Fastly Rate Limit Reset', r.headers['Fastly-RateLimit-Reset'])

# ---------------- Slack Post ----------------

if r.status_code != 200:
    print(f'[!] Bad Status Code from Fastly {r.status_code} - Resp:\n{r.content}')
    sys.exit(1)

text = f">🟢 *Activated:* `{FASTLY_SERVICE}` - {CI_COMMIT_SHORT_SHA} - v{version} - <{CI_PIPELINE_URL}|Link>"

SLACK_URL = os.environ['SLACK_URL']
slack = requests.post(url=SLACK_URL, json={'text': text})

print(f'Slack Status: {slack.status_code}')
