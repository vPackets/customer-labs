import json
import time
from datetime import datetime, timedelta
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

# === Configuration ===
json_file_path = "BF3_Host_PreFEC.json"  # Path to your JSON file
influx_url = "http://localhost:9086"
influx_token = "C1sco12345!"
influx_org = "lab"
influx_bucket = "telemetry"
interval_seconds = 5
duration_hours = 96

# === Time control ===
start_time = datetime.utcnow()
end_time = start_time + timedelta(hours=duration_hours)

# === Connect to InfluxDB ===
client = InfluxDBClient(url=influx_url, token=influx_token, org=influx_org)
write_api = client.write_api(write_options=SYNCHRONOUS)

try:
    while datetime.utcnow() < end_time:
        # === Load JSON file ===
        with open(json_file_path, "r") as f:
            data = json.load(f)

        bins_data = data["result"]["output"]["Histogram of FEC Errors"]

        # === Extract and send each bin ===
        for bin_name in [f"Bin {i}" for i in range(16)]:
            if bin_name in bins_data:
                bin_values = bins_data[bin_name]["values"]

                bin_index_raw = int(bin_values[0].strip("[]"))
                bin_index = f"{bin_index_raw:02d}"
                occurrences = int(bin_values[1])

                point = (
                    Point("fec_error_histogram")
                    .tag("bin", bin_index)
                    .field("occurrences", occurrences)
                    .time(datetime.utcnow(), WritePrecision.NS)
                )

                write_api.write(bucket=influx_bucket, org=influx_org, record=point)
                print(f"[{datetime.utcnow()}] Pushed Bin {bin_index} -> {occurrences}")

        time.sleep(interval_seconds)

except KeyboardInterrupt:
    print("Script interrupted by user.")

finally:
    client.close()
    print("InfluxDB connection closed.")