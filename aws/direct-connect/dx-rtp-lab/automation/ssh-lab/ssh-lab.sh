#!/bin/bash

while true; do
    echo "Which device do you want to access?"
    echo "1) AWS - Core 1"
    echo "2) AWS - Core 2"
    echo "3) AWS - Core 3"
    echo "4) AWS - Core 4"
    echo "5) AWS - Core 5"
    echo "6) AWS - Core 6"
    echo "7) AWS - Core 7"
    echo "8) AWS DX - VC EDGE"
    echo "9) AWS VPC - Router"
    echo "10) AWS EC2 - VPC 01 - 01"
    echo "11) AWS EC2 - VPC 02 - 01"
    echo "12) AWS EC2 - VPC 03 - 01"    
    echo "0) Exit"
    echo "Enter the number (e.g., 1):"
    read choice

    USERNAME="cisco"
    PASSWORD="cisco123"

    case $choice in
        1|01)
            SERVER_IP="clab-AWS-DX-Cisco8201-1"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        2|02)
            SERVER_IP="clab-AWS-DX-Cisco8201-2"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        3|03)
            SERVER_IP="clab-AWS-DX-Cisco8201-3"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        4|04)
            SERVER_IP="clab-AWS-DX-Cisco8201-4"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        5|05)
            SERVER_IP="clab-AWS-DX-Cisco8201-5"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        6|06)
            SERVER_IP="clab-AWS-DX-Cisco8201-6"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        7|07)
            SERVER_IP="clab-AWS-DX-Cisco8201-7"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        8|08)
            SERVER_IP="clab-AWS-DX-Cisco8201-8"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP
            ;;
        9|09)
            CONTAINER_NAME="clab-AWS-DX-vpc-router"
            docker exec -it $CONTAINER_NAME bash
            ;;
        10)
            CONTAINER_NAME="clab-AWS-DX-ec2-vpc01-01"
            docker exec -it $CONTAINER_NAME bash
            ;;
        11)
            CONTAINER_NAME="clab-AWS-DX-ec2-vpc02-01"
            docker exec -it $CONTAINER_NAME bash
            ;;
        12)
            CONTAINER_NAME="clab-AWS-DX-ec2-vpc03-01"
            docker exec -it $CONTAINER_NAME bash
            ;;            
        0|exit)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            continue
            ;;
    esac

    echo "Session has ended. You can choose another device or exit."
done
