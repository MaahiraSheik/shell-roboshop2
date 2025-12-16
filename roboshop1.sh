#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-074bbf13eb04da445"
#INSTANCES=("mangodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
INSTANCES=("mangodb" "redis" "mysql")
ZONE_ID="Z03411543BSLBE0GBV4TS"
DOMAIN_NAME="miasha84s.site"

#- ${INSTANCES[@]} expands to all elements of the array.
#- The for loop takes each element one by one and assigns it to the variable instance
# - First iteration:
# instance="mangodb"
# → Executes the block of code for mangodb.
# - Second iteration:
# instance="redis"
# → Executes the block of code for redis.
# - Third iteration:
# instance="mysql"
# → Executes the block of code for mysql.
# That’s how the script knows which service name to use when:
# - Tagging the EC2 instance (--tag-specifications "Name=$instance")
# - Printing the IP address (echo "$instance ip address: $INSTANCE_IP")
# So the service names come directly from the array INSTANCES you defined at the top
# The array INSTANCES is the source of the service names. The for loop iterates over each element of that array,
# and the variable instance holds one service name at a time.
# - Launch an EC2 instance for the service.
# - Get its Instance ID.
# - If it’s a backend service → fetch private IP.
# - If it’s frontend → fetch public IP.
# - Print the service name and IP.


# for instance in ${INSTANCES[@]}
# do
# #- An Instance ID is a unique identifier automatically assigned by AWS to every EC2 instance you launch.

# INSTANCE_ID=$(aws ec2 run-instances \
#     --image-id ami-09c813fb71547fc4f \
#     --instance-type t3.micro \
#     --security-group-ids sg-074bbf13eb04da445 \
#     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
#     --query "Instances[0].InstanceId" \
#     --output text)

#     #- If the instance name is not "frontend", you fetch its private IP; otherwise, you fetch its public IP.

# if [ $instance != "frontend" ]
# then 
# INSTANCE_IP=$(aws ec2 describe-instances \
#     --instance-ids $INSTANCE_ID \
#     --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
#     RECORD_NAME="$instance.$DOMAIN_NAME"
#     else
#     INSTANCE_IP=$(aws ec2 describe-instances \
#     --instance-ids $INSTANCE_ID \
#     --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
#     RECORD_NAME="$DOMAIN_NAME"
#     fi
#     #Print the instance name and its IP.
#     echo "$instance ip address: $INSTANCE_IP"

# aws route53 change-resource-record-sets \
#     --hosted-zone-id $ZONE_ID \
#     --change-batch '
#     {
#         "Comment": "Creating or Updating a record set for cognito endpoint"
#         ,"Changes": [{
#         "Action"              : "UPSERT"
#         ,"ResourceRecordSet"  : {
#             "Name"              : "'$RECORD_NAME'"
#             ,"Type"             : "A"
#             ,"TTL"              : 1
#             ,"ResourceRecords"  : [{
#                 "Value"         : "'$IP'"
#             }]
#         }
#         }]
#     }'

# done 

for instance in "${INSTANCES[@]}"
do
  # Launch instance and capture ID
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-09c813fb71547fc4f \
    --instance-type t3.micro \
    --security-group-ids sg-074bbf13eb04da445 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  # Fetch IP depending on role
  if [ "$instance" != "frontend" ]; then
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
    RECORD_NAME="$DOMAIN_NAME"
  fi

  echo "$instance IP address: $INSTANCE_IP"

  # Update Route53 record
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch "{
      \"Comment\": \"Creating or Updating a record set for $instance\",
      \"Changes\": [{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$RECORD_NAME\",
          \"Type\": \"A\",
          \"TTL\": 300,
          \"ResourceRecords\": [{\"Value\": \"$INSTANCE_IP\"}]
        }
      }]
    }"
done