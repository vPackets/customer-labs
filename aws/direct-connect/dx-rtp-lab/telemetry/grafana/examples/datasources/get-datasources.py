import requests
import json
from requests.auth import HTTPBasicAuth

# Your Grafana instance details
url = "http://localhost:3000/api/datasources"
username = "netadmin"
password = "C1sco12345!"

# Make the GET request with HTTP Basic Authentication
response = requests.get(
    url,
    auth=HTTPBasicAuth(username, password),
    headers={"Accept": "application/json", "Content-Type": "application/json"}
)

# Check if the request was successful
if response.status_code == 200:
    # Parse the JSON response
    data_sources = response.json()
    
    # Define the filename where the output will be saved
    output_filename = "data_sources.json"
    
    # Write the formatted JSON data to the file
    with open(output_filename, 'w') as f:
        json.dump(data_sources, f, indent=4, sort_keys=True)
    
    print(f"Data sources have been written to {output_filename} in a pretty format.")
else:
    print("Failed to fetch data sources. Status code:", response.status_code)

