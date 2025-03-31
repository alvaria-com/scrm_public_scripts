#-----------------------------------------------------------------------------------------------
# Fortify client install for Linux base.  Can 
# 
#
#  Run this script on a new linux system is to run the following command. You can pass arguments to the shell using the -s option:
#   curl -Lfk https://github.com/alvaria-com/scrm_public_scripts/raw/refs/heads/main/build_tools/fortify_client_linux.sh | bash -s <download|install|both>
#
# Created: Mar-31-2025 Hubers
#-----------------------------------------------------------------------------------------------

FORTIFY_FILE_URL='https://nexus.aws.alvaria.com/nexus/repository/alvaria-prod-hosted/scrm/build_tools/fortify/client/Fortify_SCA_24.4.0_linux_x64.run'
FORTIFY_LICENSE_FILE_URL='https://nexus.aws.alvaria.com/nexus/repository/alvaria-prod-hosted/scrm/build_tools/fortify/license/fortify.license'
TEMP_PATH='/tmp'
INSTALL_PATH='/opt/fortify/sca_client'


echo "--------------------------------------------------------"
echo "- Start of script and is doing task '$task'"
echo "--------------------------------------------------------"
echo " "

# check if command line argument is empty or not present
if [ -z $1 ]; then
   echo "Info: No task was listed, default to 'download'"
   task="download"
else
   task="$1"
fi


### Download Fortify client files
echo "Download Fortify client files for Lunix..."
if [[ "$task" =~ download|both ]]; then
   HTTP_STATUS=$(curl -Is -o /dev/null -w "%{http_code}" "$FORTIFY_FILE_URL")
   if [ "$HTTP_STATUS" -eq 200 ]; then
      echo "  URL for FORTIFY_FILE_URL exist. Let download it...";
      curl -o $TEMP_PATH/fortify-client.run "$FORTIFY_FILE_URL"
      chmod +x $TEMP_PATH/fortify-client.run
   else
      echo "-ERROR-  URL for FORTIFY_FILE_URL does NOT exist. Status code: $HTTP_STATUS";
      exit 1;
   fi
   HTTP_STATUS=$(curl -Is -o /dev/null -w "%{http_code}" "$FORTIFY_LICENSE_FILE_URL")
   if [ "$HTTP_STATUS" -eq 200 ]; then
      echo "  URL for FORTIFY_LICENSE_FILE_URL exist. Let download it...";
      curl -o $TEMP_PATH/fortify-license "$FORTIFY_LICENSE_FILE_URL"
   else
      echo "-ERROR-  URL for FORTIFY_LICENSE_FILE_URL does NOT exist. Status code: $HTTP_STATUS";
      exit 1;
   fi
else
    echo "  Task is not set to download fortify.  Skipping this step."
fi


echo "Install Fortify client for Lunix..."
if [[ "$task" =~ install|both ]]; then
   ## Install client
   $TEMP_PATH/fortify-client.run --mode unattended \
      --fortify_license_path $TEMP_PATH/fortify-license \
      --install_dir $INSTALL_PATH

   ## Set some main settings for Fortify using a properties file
   echo 'com.fortify.sca.limiters.MaxSink=256'.          >  $INSTALL_PATH/Core/config/fortify-sca.properties
   echo 'com.fortify.sca.limiters.MaxSource=256'         >> $INSTALL_PATH/Core/config/fortify-sca.properties
   echo 'com.fortify.sca.limiters.MaxNodesForGlobal=256' >> $INSTALL_PATH/Core/config/fortify-sca.properties
   echo 'com.fortify.sca.hoa.Enable=false'               >> $INSTALL_PATH/Core/config/fortify-sca.properties
   echo 'com.fortify.sca.Phase0HigherOrder.Level=0'      >> $INSTALL_PATH/Core/config/fortify-sca.properties
   echo 'com.fortify.sca.Phase0HigherOrder.Languages=""' >> $INSTALL_PATH/Core/config/fortify-sca.properties

   ## Update path to fortify cleint and make it work on reboots
   echo 'export PATH="$INSTALL_PATH/bin:$PATH"' | sudo tee /etc/profile.d/fortify_env.sh > /dev/null

   ## Updte the client with latest data from fortify site
   fortifyupdate

else
    echo "  Task is not set to install fortify.  Skipping this step."
fi
