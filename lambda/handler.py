import boto3
import os
import html

ssm = boto3.client('ssm')

def handler(event, context):
    try:
        param_name = os.environ.get('PARAM_NAME', '/app/dynamic-string')
        parameter = ssm.get_parameter(Name=param_name)
        raw_value = parameter['Parameter']['Value'].strip()
        
        if not raw_value:
            value = "Error: Input is empty"
        elif len(raw_value) > 50:
            value = "Error: Input too long (max 50 chars)"
        else:
            value = html.escape(raw_value)
    except Exception:
        value = "Error: Could not retrieve value"

    response_html = f"""<!DOCTYPE html>
<html>
  <head>
    <title>Dynamic Page</title>
    <style>
        body {{ font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f0f2f5; }}
        h1 {{ color: #1a73e8; background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
    </style>
  </head>
  <body>
    <h1>The saved string is {value}</h1>
    <script>
    setInterval(() => {{
        fetch(window.location.href)
          .then(r => r.text())
          .then(htmlText => {{
            const parser = new DOMParser()
            const doc = parser.parseFromString(htmlText, 'text/html')
            const newValue = doc.querySelector('h1').textContent
            document.querySelector('h1').textContent = newValue
          }})
          .catch(err => console.error('Polling error:', err))
    }}, 3000)
    </script>
  </body>
</html>"""

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/html'},
        'body': response_html
    }