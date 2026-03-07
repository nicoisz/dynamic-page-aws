import boto3
import os

ssm = boto3.client('ssm')

def handler(event, context):
    parameter = ssm.get_parameter(Name='/app/dynamic-string')
    value = parameter['Parameter']['Value']

    html = f"""<!DOCTYPE html>
<html>
  <head><title>Dynamic Page</title></head>
  <body>
    <h1>The saved string is {value}</h1>
    <script>
        fetch(window.location.href)
          .then(r => r.text())
          .then(html => {{
            const parser = new DOMParser()
            const doc = parser.parseFromString(html, 'text/html')
            document.querySelector('h1').textContent = doc.querySelector('h1').textContent
          }})
    </script>
  </body>
</html>"""

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/html'},
        'body': html
    }