import json
import sys, os
import requests

service_name = sys.argv[1].replace('"', '')
fastlykey = sys.argv[2].replace('"', '')
sha = sys.argv[3].replace('"', '')
pipeline_url = sys.argv[4].replace('"', '')

with open('plan-apply.json', 'r') as f:
    data = f.read()

planned_values = json.loads(data)['planned_values']['outputs']
active_version = planned_values['active_version']['value']
service_id = planned_values['service_id']['value']

headers = {'Fastly-Key': fastlykey}
r = requests.put(f'https://api.fastly.com/service/{service_id}/version/{active_version}/activate', headers=headers)

if r.status_code != 200:
    print(f'[!] ERROR: {r.status_code}')
    print(r.json())
    sys.exit(1)

print(f'[#] Rollback Request Successful - Version: {active_version} activated')

text = f'🔄 *Rapid Rollback Completed:* `{service_name}`\n>*Rollback Version [Fastly]:* v{active_version}\n>Details: {sha} - <{pipeline_url}|Link>\n>Now that Rapid Rollback has completed, please view the following runbook on what to do next.\n><add_a_runbook_link_here|Runbook 📘>'

SLACK_URL = os.environ['SLACK_URL']
slack = requests.post(url=SLACK_URL, json={'text': text})

print(f'Slack Status: {slack.status_code}')