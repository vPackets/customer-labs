{
  "id": 161,
  "gridPos": {
    "h": 11,
    "w": 4,
    "x": 16,
    "y": 9
  },
  "type": "gauge",
  "title": "Regional C emissions [g CO2 eq / kWh]",
  "repeatDirection": "v",
  "transformations": [],
  "datasource": {
    "type": "influxdb",
    "uid": "PAA239D41A0EF0C37"
  },
  "pluginVersion": "8.3.0",
  "description": "",
  "fieldConfig": {
    "defaults": {
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "#EAB839",
            "value": 150
          },
          {
            "color": "orange",
            "value": 300
          },
          {
            "color": "red",
            "value": 500
          },
          {
            "color": "dark-red",
            "value": 700
          }
        ]
      },
      "mappings": [],
      "color": {
        "mode": "thresholds"
      },
      "displayName": "${__field.labels}",
      "max": 804,
      "min": 0,
      "unit": "massg"
    },
    "overrides": []
  },
  "options": {
    "reduceOptions": {
      "values": false,
      "calcs": [
        "lastNotNull"
      ],
      "fields": ""
    },
    "orientation": "horizontal",
    "showThresholdLabels": false,
    "showThresholdMarkers": false,
    "text": {
      "valueSize": 20
    }
  },
  "targets": [
    {
      "datasource": "InfluxDB-2",
      "hide": false,
      "query": "src = from(bucket: \"bucket1\")\n  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)\n  |> filter(fn: (r) => \n    r.device_type == \"cisco-8k\" and\n    r._measurement == \"Cisco-IOS-XR-envmon-oper:power-management/rack/producers/producer-nodes/producer-node\" and \n    (\n    r._field == \"pem_info_array/current_in_a\" or\n    r._field == \"pem_info_array/voltage_in_a\" or \n    r._field == \"pem_info_array/current_in_b\" or\n    r._field == \"pem_info_array/voltage_in_b\"\n    ))\n  |> pivot(rowKey:[\"_time\"], columnKey: [\"_field\"], valueColumn: \"_value\")\n  |> rename(columns: {\"pem_info_array/voltage_in_a\": \"voltage_in_a\", \"pem_info_array/current_in_a\": \"current_in_a\", \"pem_info_array/voltage_in_b\": \"voltage_in_b\", \"pem_info_array/current_in_b\": \"current_in_b\"})\n  |> map(fn: (r) => ({\n    r with\n    power_in_a: (float(v: r.voltage_in_a)/1000.0) * (float(v: r.current_in_a)/1000.0),\n    power_in_b: (float(v: r.voltage_in_b)/1000.0) * (float(v: r.current_in_b)/1000.0),\n   }))\n  |> map(fn: (r) => ({\n    r with\n    in_power: r.power_in_a + r.power_in_b,\n  }))\n  |> last(column: \"in_power\")\n  |> keep(columns: [\"_time\", \"in_power\", \"_field\", \"_value\", \"source\", \"cc\"])\n  //|> keep(columns: [\"_time\", \"in_power\", \"_field\", \"_value\", \"source\", \"cc\", \"node\", \"name\", \"pem_info_array/node_name\"])\n  |> sum(column: \"in_power\")\n  |> map(fn: (r) => ({\n    r with\n    _value: r.in_power,\n  }))\n\nco2eqkwh = from(bucket: \"bucket1\")\n  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)\n  |> filter(fn: (r) =>\n  \t  r._measurement == \"electricity-map\" and\n      r._field == \"carbonIntensity\")\n  |> drop(columns: [\"_measurement\"])\n\nj = join(\n\ttables: {t1: src, t2: co2eqkwh},\n    on: [\"cc\"],\n\t)\n    |> map(fn: (r) => ({\n    r with\n    \t//system_power_input: r.in_power,\n    \t//carbonIntensity: r._value_t2,\n    \t//region: r.region_t1,\n    \t//country: r.country_t1,\n      _value: r._value_t2,\n    \t_time: r._time_t1\n\t}))\n    //|> keep(columns: [\"_value\", \"_time\", \"cc\", \"source\", \"subscription\", \"_measurement\", \"region_t1\", \"country_t1\"])\n    |> keep(columns: [\"_value\", \"_time\", \"cc\", \"source\", \"subscription\", \"_measurement\"])\n    \n    // For sorting data (replaces |>last())\n    |> group()\n    |> sort(columns: [\"_time\"], desc: true)\n    |> unique(column: \"source\")\n    |> sort(columns: [\"source\"], desc: false)\n    |> pivot(rowKey:[], columnKey: [\"source\", \"cc\"], valueColumn: \"_value\")\n  \t|> yield()\n    \n    ",
      "refId": "Dynamic measurements - Regional Carbon emissions - sorted"
    },
    {
      "datasource": "InfluxDB-2",
      "hide": true,
      "query": "from(bucket: \"bucket1\")\n  |> range(start: v.timeRangeStart)\n  |> filter(fn: (r) => r._measurement == \"Cisco-IOS-XR-envmon-oper:power-management/rack/producers/producer-nodes/producer-node\")\n  |> filter(fn: (r) => r._field == \"co2_emission\")\n  |> keep(columns: [\"_field\", \"_value\", \"_time\", \"source\", \"country\", \"region\"])\n  |> last()\n  //Grafana: ${__field.labels.source}: ${__field.labels.country} - ${__field.labels.region}",
      "refId": "Static measurements - Deprecated - Regional Carbon emissions"
    }
  ]
}