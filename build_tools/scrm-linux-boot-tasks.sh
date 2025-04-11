#!/bin/bash
#--------------------------------------------------------------------------------------------------------------------------
#  Script to create a script that run at instance bootup after network is ready. Used to update things before we use it.
# 
#  
#  curl -Lfk https://github.com/alvaria-com/scrm_public_scripts/raw/refs/heads/main/build_tools/scrm-linux-boot-tasks.sh | sudo bash
# 
# Note!  This script read AWS to get some 
#
#
# Created: Apr-10-2025 Hubers
# Updates: xxx
#--------------------------------------------------------------------------------------------------------------------------


### Main variables
  SERVICE_NAME="scrm-linux-boot-tasks"
  SCRIPT_PATH="/usr/local/bin/scrm-boot-tasks.sh"
  SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"


### Create the script that runs after system boots and network ready
cat <<- 'EOF' > $SCRIPT_PATH
  #!/bin/bash


  ### Get Nexus readonly user and password from AWS Secret and change it to base64
  nxrm_readonly_data=$(aws secretsmanager get-secret-value \
                    --secret-id 'arn:aws:secretsmanager:us-east-2:018805767579:secret:scrm/nexus/serviceid/nexus-readonly' \
                    --query SecretString \
                    --region us-east-2 \
                    --output text )

  ### Extract and encode the credentials using jq and base64
  encoded_cred=$(echo $nxrm_readonly_data | jq -r '[.id, .pw] | join(":")' | base64)

  ### Export the secret as an environment variable
  export NEXUS_RO_PW=$encoded_cred

  ### save where it get pick up by any shell or login
  echo "NEXUS_RO_PW=$encoded_cred" > /etc/environment
EOF


# Create the systemd service file
cat <<- EOF > $SERVICE_FILE
  [Unit]
  Description=Run SCRM System Boot Tasks
  Wants=network-online.target
  After=network-online.target

  [Service]
  ExecStart=$SCRIPT_PATH
  EnvironmentFile=/etc/environment

  [Install]
  WantedBy=multi-user.target
EOF

### Make the script executable
chmod +x $SCRIPT_PATH
chmod +x $SERVICE_FILE

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable $SERVICE_NAME.service
systemctl start $SERVICE_NAME.service

echo "Setup complete. The service $SERVICE_NAME has been created and started."
