#!/bin/bash

pandoc AWS-DX-RTP-LAB.md -s -o AWS-DX-RTP-LAB.html -c style.css

pandoc AWS-DX-Topology.md -s -o AWS-DX-Topology.html -c style.css

pandoc AWS-DX-Telemetry.md -s -o AWS-DX-Telemetry.html -c style.css

