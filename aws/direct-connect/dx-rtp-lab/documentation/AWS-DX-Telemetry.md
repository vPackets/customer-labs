<img src="https://images.folloze.com/image/upload/v1623245899/oic1b8o6v91c1m2tnd4u.png" height="200" class="image-margin-right">
<span style="margin-right: 100px;"></span> <!-- Adjust the 20px to whatever space you need -->
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cisco_logo.svg/320px-Cisco_logo.svg.png" height="200"> 


<br>

# AWS Direct Connect - Telemetry


## Contact Information
  
- [Nicolas Michel, Solution Architect](nicmcl@cisco.com)

Revision information:

v0.1: Draft


## Revision History - Changelog

Document any changes made to the lab setup, including updates to configurations, hardware changes, or topology modifications.

| Date       | Description                                 | Author         |
|------------|---------------------------------------------|----------------|
| 2024-05-21 | Initial document revision                   | Nicolas MICHEL |
| 2024-08-14 | Added Power - Platform and  DX Topology     | Nicolas MICHEL |
*Last Updated: [2024-08-14]*

## Lab Backlog for DX

- Add Power Efficiency
- Add Co2
- Add Cost calculation



Check these sensors paths:


	•	Cisco-IOS-XR-envmon-oper:environmental-monitoring
	•	Cisco-IOS-XR-envmon-oper:power-management/rack/chassis
	•	Cisco-IOS-XR-envmon-oper:power-management/rack/consumers
	•	Cisco-IOS-XR-invmgr-oper:inventory/entities/entity/attributes/env-sensor-info
	•	Cisco-IOS-XR-controller-optics-oper:optics-oper/optics-ports/optics-port/optics-info
	•	Cisco-IOS-XR-invmgr-oper:inventory/entities/entity/attributes/inv-basic-bag/power-capacity
	•	Cisco-IOS-XR-infra-statsd-oper:infra-statistics/interfaces/interface/total/data-rate/input-data-rate
	•	Cisco-IOS-XR-infra-statsd-oper:infra-statistics/interfaces/interface/total/data-rate/output-data-rate


## General Backlog


##  Telemetry

### Containerized Telemetry


The docker compose file looks like this:

```

version: "2"
services:
  grafana:
    image: grafana/grafana:10.2.1
    container_name: DX-grafana
    ports:
      - '3000:3000'
    volumes:
      #- ~/code/telemetry/grafana/data:/var/lib/grafana
      #- ~/code/telemetry/grafana/provisioning:/etc/grafana/provisioning
      #- ~/code/telemetry/grafana/data/plugins:/var/lib/grafana/plugins
      - ~/code/telemetry/grafana/provisioning/dashboards/:/var/lib/grafana/dashboards
      - ~/code/telemetry/grafana/provisioning/datasources/datasource.yaml:/etc/grafana/provisioning/datasources/datasource.yaml:ro
      - ~/code/telemetry/grafana/provisioning/dashboards/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml
      #- type: bind
      #  source: ~/code/telemetry/grafana/data/plugins
      #  target: /var/lib/grafana/plugins
      #  bind:
      #    create_host_path: true
    #user: "472:472"
    environment:
      - GF_SECURITY_ADMIN_USER=netadmin
      - GF_SECURITY_ADMIN_PASSWORD=C1sco12345!
      - GF_AUTH_ANONYMOUS_ENABLED= true
      - GF_AUTH_ANONYMOUS= true
      - INFLUX_DB_TOKEN=C1sco12345!
      - GF_INSTALL_PLUGINS=https://algenty.github.io/flowcharting-repository/archives/agenty-flowcharting-panel-1.0.0d.220606199-SNAPSHOT.zip;agenty-flowcharting-panel
    deploy:
      resources:
        reservations:
          cpus: "4"
    networks:
      - telemetry_network



  influxdb:
    image: influxdb:latest
    container_name: DX-influxdb
    ports:
      - '8086:8086'
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_BUCKET=telemetry
      - DOCKER_INFLUXDB_INIT_USERNAME=netadmin
      - DOCKER_INFLUXDB_INIT_PASSWORD=C1sco12345!
      - DOCKER_INFLUXDB_INIT_ORG=lab
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=C1sco12345!
    volumes:
      - ~/code/telemetry/influxdb/data:/var/lib/influxdb2
    networks:
      - telemetry_network
    deploy:
      resources:
        reservations:
          cpus: "8"
    

  telegraf:
    image: telegraf:latest
    container_name: DX-telegraf
    depends_on:
      - influxdb
    ports:
      - '57500:57500'
    volumes:
      - ~/code/telemetry/telegraf/telegraf_dial_out.conf:/etc/telegraf/telegraf.conf:ro
      #- ./telegraf_dial_in.conf:/etc/telegraf/telegraf.conf:ro
      #- ./embedded_tag.star:/etc/telegraf/embedded_tag.star:ro
    networks:
      - telemetry_network

networks:
  telemetry_network:
    driver: bridge
```

launch the containers using 

```
netadmin@srv-ubuntu-01:/home/netadmin/code/telemetry $ docker compose up -d
WARN[0000] /home/netadmin/code/telemetry/docker-compose.yml: `version` is obsolete
...                                                                                                                                                                          
 ✔ Container DX-influxdb  Started                                                                                                                                                                                                                          
 ✔ Container DX-grafana   Started                                                                                                                                                                                                                          
 ✔ Container DX-telegraf  Started
```


Verify the containers are running:

```
netadmin@srv-ubuntu-01:/home/netadmin/code/telemetry $ docker ps -a | grep DX
5099b8c83cad   grafana/grafana:latest       "/run.sh"                14 minutes ago   Up 14 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp            DX-grafana
2926672e944d   telegraf:latest              "/entrypoint.sh tele…"   14 minutes ago   Up 14 minutes   8092/udp, 8125/udp, 8094/tcp, 0.0.0.0:57500->57500/tcp, :::57500->57500/tcp          DX-telegraf
013f49fb15ca   influxdb:latest              "/entrypoint.sh infl…"   14 minutes ago   Up 14 minutes   0.0.0.0:8086->8086/tcp, :::8086->8086/tcp            DX-influxdb
```

The credentials are both :

- netadmin / C1sco12345!

Grafana is reachable [here](http://198.18.140.3:3000).<br>
InflucDB is reachable [here](http://198.18.140.3:8086/orgs/) <br>
Telegraf can be access throught the container directly: 

```
docker exec -it DX-telegraf /bin/
```


### Telegraf Configuration


Here is the telegraf configuration for reference and analysis:

```

netadmin@srv-ubuntu-01:/home/netadmin/code/telemetry $ cat telegraf_dial_out.conf
# Telegraf Configuration
#
# Telegraf is entirely plugin driven. All metrics are gathered from the
# declared inputs, and sent to the declared outputs.
#
# Plugins must be declared in here to be active.
# To deactivate a plugin, comment out the name and any variables.
#
# Use 'telegraf -config telegraf.conf -test' to see what metrics a config
# file would generate.
#
# Environment variables can be used anywhere in this config file, simply surround
# them with ${}. For strings the variable must be within quotes (ie, "${STR_VAR}"),
# for numbers and booleans they should be plain (ie, ${INT_VAR}, ${BOOL_VAR})


# Global tags can be specified here in key="value" format.
[global_tags]
  # dc = "us-east-1" # will tag all metrics with dc=us-east-1
  # rack = "1a"
  ## Environment variables can be used as tags, and throughout the config file
  # user = "$USER"


# Configuration for telegraf agent
[agent]
  ## Default data collection interval for all inputs
  interval = "10s"
  ## Rounds collection interval to 'interval'
  ## ie, if interval="10s" then always collect on :00, :10, :20, etc.
  round_interval = true

  ## Telegraf will send metrics to outputs in batches of at most
  ## metric_batch_size metrics.
  ## This controls the size of writes that Telegraf sends to output plugins.
  metric_batch_size = 1000

  ## Maximum number of unwritten metrics per output.  Increasing this value
  ## allows for longer periods of output downtime without dropping metrics at the
  ## cost of higher maximum memory usage.
  metric_buffer_limit = 10000

  ## Collection jitter is used to jitter the collection by a random amount.
  ## Each plugin will sleep for a random time within jitter before collecting.
  ## This can be used to avoid many plugins querying things like sysfs at the
  ## same time, which can have a measurable effect on the system.
  collection_jitter = "0s"

  ## Default flushing interval for all outputs. Maximum flush_interval will be
  ## flush_interval + flush_jitter
  flush_interval = "10s"
  ## Jitter the flush interval by a random amount. This is primarily to avoid
  ## large write spikes for users running a large number of telegraf instances.
  ## ie, a jitter of 5s and interval 10s means flushes will happen every 10-15s
  flush_jitter = "0s"

  ## By default or when set to "0s", precision will be set to the same
  ## timestamp order as the collection interval, with the maximum being 1s.
  ##   ie, when interval = "10s", precision will be "1s"
  ##       when interval = "250ms", precision will be "1ms"
  ## Precision will NOT be used for service inputs. It is up to each individual
  ## service input to set the timestamp at the appropriate precision.
  ## Valid time units are "ns", "us" (or "µs"), "ms", "s".
  precision = ""

  ## Log at debug level.
  debug = false
  ## Log only error level messages.
  quiet = false

  ## Log target controls the destination for logs and can be one of "file",
  ## "stderr" or, on Windows, "eventlog".  When set to "file", the output file
  ## is determined by the "logfile" setting.
  logtarget = "file"

  ## Name of the file to be logged to when using the "file" logtarget.  If set to
  ## the empty string then logs are written to stderr.
  logfile = ""

  ## The logfile will be rotated after the time interval specified.  When set
  ## to 0 no time based rotation is performed.  Logs are rotated only when
  ## written to, if there is no log activity rotation may be delayed.
  # logfile_rotation_interval = "0d"

  ## The logfile will be rotated when it becomes larger than the specified
  ## size.  When set to 0 no size based rotation is performed.
  # logfile_rotation_max_size = "0MB"

  ## Maximum number of rotated archives to keep, any older logs are deleted.
  ## If set to -1, no archives are removed.
  # logfile_rotation_max_archives = 5

  ## Override default hostname, if empty use os.Hostname()
  hostname = ""
  ## If set to true, do no set the "host" tag in the telegraf agent.
  omit_hostname = false


###############################################################################
#                            OUTPUT PLUGINS                                   #
###############################################################################


# Configuration for sending metrics to InfluxDB
[[outputs.influxdb_v2]]
    ## The URLs of the InfluxDB cluster nodes.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
  urls = ["http://198.18.140.3:8086"]

  ## Token for authentication.
  token = "C1sco12345!"

  ## Organization is the name of the organization you wish to write to.
  organization = "lab"

  ## Destination bucket to write into.
  bucket = "telemetry"

  ## The value of this tag will be used to determine the bucket.  If this
  ## tag is not set the 'bucket' option is used as the default.
  # bucket_tag = ""

  ## If true, the bucket tag will not be added to the metric.
  # exclude_bucket_tag = false

  ## Timeout for HTTP messages.
  # timeout = "5s"

  ## Additional HTTP headers
  # http_headers = {"X-Special-Header" = "Special-Value"}

  ## HTTP Proxy override, if unset values the standard proxy environment
  ## variables are consulted to determine which proxy, if any, should be used.
  # http_proxy = "http://corporate.proxy:3128"

  ## HTTP User-Agent
  # user_agent = "telegraf"

  ## Content-Encoding for write request body, can be set to "gzip" to
  ## compress body or "identity" to apply no encoding.
  # content_encoding = "gzip"

  ## Enable or disable uint support for writing uints influxdb 2.0.
  # influx_uint_support = false

  ## HTTP/2 Timeouts
  ## The following values control the HTTP/2 client's timeouts. These settings
  ## are generally not required unless a user is seeing issues with client
  ## disconnects. If a user does see issues, then it is suggested to set these
  ## values to "15s" for ping timeout and "30s" for read idle timeout and
  ## retry.
  ##
  ## Note that the timer for read_idle_timeout begins at the end of the last
  ## successful write and not at the beginning of the next write.
  # ping_timeout = "0s"
  # read_idle_timeout = "0s"

  ## Optional TLS Config for use on HTTP connections.
  # tls_ca = "/etc/telegraf/ca.pem"
  # tls_cert = "/etc/telegraf/cert.pem"
  # tls_key = "/etc/telegraf/key.pem"
  ## Use TLS but skip chain & host verification
  # insecure_skip_verify = false


###############################################################################
#                            PROCESSOR PLUGINS                                #
###############################################################################


# Rename measurements, tags, and fields that pass through this filter.
[[processors.rename]]
  namepass = ["StatsQosIn","StatsQosOut"]
  [[processors.rename.replace]]
    tag = "class_stats/class_name"
    dest = "class_name"

[[processors.regex]]
  namepass = ["StatsQosIn","StatsQosOut"]
   # Rename metric fields
  [[processors.regex.field_rename]]
    ## Regular expression to match on a field name
    pattern = "^class_stats\\/general_stats\\/(.*)$"
    ## Matches of the pattern will be replaced with this string.  Use ${1}
    ## notation to use the text of the first submatch.
    replacement = "${1}"
    ## If the new field name already exists, you can either "overwrite" the
    ## existing one with the value of the renamed field OR you can "keep"
    ## both the existing and source field.
    # result_key = "keep"

[[processors.converter]]
  namepass = ["StatsQosIn","StatsQosOut"]
  ## Tags to convert
  ##
  ## The table key determines the target type, and the array of key-values
  ## select the keys to convert.  The array may contain globs.
  ##   <target-type> = [<tag-key>...]
  [processors.converter.fields]
   ## measurement = []
   ## tag = []
   ## string = []
   ## integer = []
   ## unsigned = []
   ## boolean = []
   ## float = []
   unsigned = ["*bytes","*packets","*rate"]

    ## Optional field to use as metric timestamp
    # timestamp = []

    ## Format of the timestamp determined by the field above. This can be any
    ## of "unix", "unix_ms", "unix_us", "unix_ns", or a valid Golang time
    ## format. It is required, when using the timestamp option.
    # timestamp_format = ""

###############################################################################
#                            INPUT PLUGINS                                    #
###############################################################################

# Cisco model-driven telemetry (MDT) input plugin for IOS XR, IOS XE and NX-OS platforms
[[inputs.cisco_telemetry_mdt]]
 ## Telemetry transport can be "tcp" or "grpc".  TLS is only supported when
 ## using the grpc transport.
 transport = "grpc"

 ## Address and port to host telemetry listener
 service_address = ":57500"

 ## Grpc Maximum Message Size, default is 4MB, increase the size. This is
 ## stored as a uint32, and limited to 4294967295.
 max_msg_size = 4000000

 ## Enable TLS; grpc transport only.
 # tls_cert = "/etc/telegraf/cert.pem"
 # tls_key = "/etc/telegraf/key.pem"

 ## Enable TLS client authentication and define allowed CA certificates; grpc
 ##  transport only.
 # tls_allowed_cacerts = ["/etc/telegraf/clientca.pem"]

 ## Define (for certain nested telemetry measurements with embedded tags) which fields are tags
 embedded_tags = ["Cisco-IOS-XR-qos-ma-oper:qos/interface-table/interface/input/service-policy-names/service-policy-instance/statistics/class-stats/class-name",
 "Cisco-IOS-XR-qos-ma-oper:qos/interface-table/interface/output/service-policy-names/service-policy-instance/statistics/class-stats/class-name"]

  ## Include the delete field in every telemetry message.
  # include_delete_field = false

 ## Define aliases to map telemetry encoding paths to simple measurement names
  [inputs.cisco_telemetry_mdt.aliases]
   StatsQosIn = "Cisco-IOS-XR-qos-ma-oper:qos/interface-table/interface/input/service-policy-names/service-policy-instance/statistics"
   StatsQosOut = "Cisco-IOS-XR-qos-ma-oper:qos/interface-table/interface/output/service-policy-names/service-policy-instance/statistics"
 ## Define Property Xformation, please refer README and https://pubhub.devnetcloud.com/media/dme-docs-9-3-3/docs/appendix/ for Model details.
 [inputs.cisco_telemetry_mdt.dmes]
#    Global Property Xformation.
#    prop1 = "uint64 to int"
#    prop2 = "uint64 to string"
#    prop3 = "string to uint64"
#    prop4 = "string to int64"
#    prop5 = "string to float64"
#    auto-prop-xfrom = "auto-float-xfrom" #Xform any property which is string, and has float number to type float64
#    Per Path property xformation, Name is telemetry configuration under sensor-group, path configuration "WORD         Distinguished Name"
#    Per Path configuration is better as it avoid property collision issue of types.
#    dnpath = '{"Name": "show ip route summary","prop": [{"Key": "routes","Value": "string"}, {"Key": "best-paths","Value": "string"}]}'
#    dnpath2 = '{"Name": "show processes cpu","prop": [{"Key": "kernel_percent","Value": "float"}, {"Key": "idle_percent","Value": "float"}, {"Key": "process","Value": "string"}, {"Key": "user_percent","Value": "float"}, {"Key": "onesec","Value": "float"}]}'
#    dnpath3 = '{"Name": "show processes memory physical","prop": [{"Key": "processname","Value": "string"}]}'

 ## Additional GRPC connection settings.
 [inputs.cisco_telemetry_mdt.grpc_enforcement_policy]
  ## GRPC permit keepalives without calls, set to true if your clients are
  ## sending pings without calls in-flight. This can sometimes happen on IOS-XE
  ## devices where the GRPC connection is left open but subscriptions have been
  ## removed, and adding subsequent subscriptions does not keep a stable session.
  # permit_keepalive_without_calls = false

  ## GRPC minimum timeout between successive pings, decreasing this value may
  ## help if this plugin is closing connections with ENHANCE_YOUR_CALM (too_many_pings).
  # keepalive_minimum_time = "5m"


```


This Telegraf configuration file (telegraf_dial_out.conf) is set up to collect telemetry data from Cisco devices and send it to an InfluxDB database for storage and analysis. Here’s a breakdown of the configuration:

Global Tags

	•	[global_tags]: Allows you to define tags that will be applied to all metrics. These tags can help categorize and filter data in InfluxDB. In this configuration, global tags are commented out.

Agent Configuration

	•	[agent]: Configures the behavior of the Telegraf agent.
	•	interval: Sets the data collection interval to 10 seconds.
	•	round_interval: Ensures data collection happens on exact intervals (e.g., :00, :10, :20).
	•	metric_batch_size: Specifies the number of metrics to send in each batch (1000).
	•	metric_buffer_limit: Limits the number of unwritten metrics to 10000.
	•	collection_jitter: Adds a random delay to data collection to avoid spikes (set to 0s).
	•	flush_interval: Sets the interval for flushing data to outputs (10 seconds).
	•	flush_jitter: Adds a random delay to flush intervals (set to 0s).
	•	precision: Defines the timestamp precision (default is determined by the collection interval).
	•	logtarget: Specifies the log destination (file).
	•	logfile: Specifies the log file (empty, so logs go to stderr).
	•	hostname: Uses the OS hostname by default.
	•	omit_hostname: If true, does not set the “host” tag (false by default).

Output Plugins

	•	[[outputs.influxdb_v2]]: Configures Telegraf to send metrics to an InfluxDB instance.
	•	urls: Specifies the URL of the InfluxDB instance (http://198.18.140.3:8086).
	•	token: Sets the authentication token (C1sco12345!).
	•	organization: Specifies the organization name in InfluxDB (lab).
	•	bucket: Defines the bucket in InfluxDB to write metrics to (telemetry).

Processor Plugins

	•	[[processors.rename]]: Renames measurements, tags, and fields.
	•	namepass: Applies renaming only to specified metrics (StatsQosIn, StatsQosOut).
	•	tag: Renames a specific tag.
	•	[[processors.regex]]: Renames metric fields using regular expressions.
	•	namepass: Applies regex renaming to specified metrics (StatsQosIn, StatsQosOut).
	•	pattern: Matches field names using a regex pattern.
	•	replacement: Replaces matched field names with a specified format.
	•	[[processors.converter]]: Converts fields to different types.
	•	namepass: Applies conversion to specified metrics (StatsQosIn, StatsQosOut).
	•	unsigned: Converts fields matching specified patterns to unsigned integers.

Input Plugins

	•	[[inputs.cisco_telemetry_mdt]]: Configures the input plugin for Cisco Model-Driven Telemetry (MDT).
	•	transport: Uses gRPC for telemetry transport.
	•	service_address: Listens for telemetry on port 57500.
	•	max_msg_size: Sets the maximum message size to 4MB.
	•	embedded_tags: Specifies which fields are tags.
	•	aliases: Maps telemetry encoding paths to simple measurement names.
	•	grpc_enforcement_policy: Additional settings for the gRPC connection.

Summary

	1.	Data Collection: Telegraf collects telemetry data every 10 seconds from Cisco devices using the gRPC transport protocol.
	2.	Data Processing: The data is processed by renaming fields and converting data types to ensure consistency and readability.
	3.	Data Output: The processed data is sent to an InfluxDB instance at http://198.18.140.3:8086, authenticated with a token, and stored in the telemetry bucket under the lab organization.

This configuration ensures that telemetry data is collected efficiently, processed appropriately, and stored securely for analysis and monitoring in InfluxDB.

### Model Driven Telemetry Metrics

#### System Metrics

Platform 

    Chassis Hostname: 	Cisco-IOS-XR-um-hostname-cfg:hostname/system-network-name
    System Uptime
    Temperature Sensors
    Power Supply Status
    Power Supply Voltage
    Power Supply Current
    Power Supply Power Output
    Fan Status
    Chassis Temperature
    Chassis Fan Speed
    Chassis Power Consumption

CPU and Memory Metrics

    CPU Utilization
    Memory Utilization
    

Interface Metrics

    Interface Status (Up/Down)
    Interface Bandwidth Utilization (In/Out)
    Interface Error Rate (CRC Errors)
    Interface Discard Rate
    Interface Packet Drops (In/Out)
    Interface Queue Utilization
    Interface Congestion
    Interface MTU Size
    Interface Speed

Traffic Metrics

    Total Packets (In/Out)
    Total Bytes (In/Out)
    Packet Rate (PPS - Packets Per Second)
    Byte Rate (BPS - Bytes Per Second)

BGP Metrics

    BGP Peer Status (Established/Not Established)
    BGP Route Counts (IPv4/IPv6)
    BGP Prefixes Received
    BGP Prefixes Advertised
    BGP Updates Received
    BGP Updates Sent
    BGP AS Path Length
    BGP Route Age
    BGP Route Refresh Requests

VRF Metrics
    
    VRF Counts
    VRF Route Counts
    VRF Traffic Utilization
    VRF Specific Interface Utilization
    VRF Specific Error Rate

QoS Metrics (VALUABLE BUT NOT USED BY AWS TODAY)

    QoS Policy Drops
    QoS Policy Matches
    QoS Queue Length
    QoS Queue Drops
    QoS Marking Statistics


Platform and Optics Metrics

    Optics Power Levels (Transmit)
    Optics Power Levels (Receive)
    Optics Temperature
    Optics Voltage
    Transceiver Presence
    Transceiver Operational Status
    Transceiver Error Count
    Transceiver Module Type
    Transceiver Vendor
    Transceiver Serial Number
    Interface Light Levels

Example Grafana Dashboard Setup

    Interface Status Panel: Display the up/down status of critical interfaces.
    Bandwidth Utilization Panel: Graph showing the in/out bandwidth usage over time for key interfaces.
    Error Rate Panel: Highlight interfaces with high error rates.
    Packet Drops Panel: Show the number of dropped packets on each interface.
    Top Talkers Panel: List of top source and destination IPs based on traffic volume.
    BGP Peer Status Panel: Display the status of BGP peers.
    BGP Route Counts Panel: Number of routes received and advertised by BGP.
    CPU Utilization Panel: Graph of CPU usage over time.
    Memory Utilization Panel: Graph of memory usage over time.
    System Uptime Panel: Display the uptime of the PE router.
    Temperature Sensors Panel: Current temperature readings from various sensors.
    QoS Policy Drops Panel: Display drops due to QoS policies.
    Optics Power Levels Panel: Show transmit and receive power levels for optics.
    Optics Temperature Panel: Display temperature of optics.
    Optics Bias Current Panel: Show bias current of optics.
    Transceiver Status Panel: Display status of transceivers.
    Chassis Temperature Panel: Show temperature readings of the chassis.
    Power Supply Status Panel: Display status and metrics of power supplies.
    Fan Status Panel: Show the status and speed of fans.
    Line Card Status Panel: Display status and metrics of line cards.

