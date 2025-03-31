#-----------------------------------------------------------------------------------------------
# Fortify client install for Linux base.  Can 
# 
#
#  Run this script on a new linux system is to run the following command. You can pass arguments to the shell using the -s option:
#   curl -Lfk https://bitbucket.aws.alvaria.com/projects/SCRM/repos/newsystem/browse/SupportFiles/add_scrm_users.sh?raw | bash -s <download|install|both>
#
# Created: Mar-31-2025 Hubers
#-----------------------------------------------------------------------------------------------

FORTIFY_FILE_URL='https://nexus.aws.alvaria.com/nexus/repository/alvaria-prod-hosted/scrm/build_tools/fortify/client/Fortify_SCA_24.4.0_linux_x64.run'
FORTIFY_LICENSE_FILE_URL='https://nexus.aws.alvaria.com/nexus/repository/alvaria-prod-hosted/scrm/build_tools/fortify/license/fortify.license'
TEMP_PATH='/tmp'
INSTALL_PATH='/opt/fortify/sca_client'


# check if command line argument is empty or not present
if [ -z $1 ]; then
   echo "Info: No task was listed, default to 'download'"
   task="download"
else
   task="$1"
fi

echo "--------------------------------------------------------"
echo "- Start of script and is doing task '$task'"
echo "--------------------------------------------------------"
echo " "

### Download Fortify client files
echo "Download Fortify client files for Lunix..."
if [[ "$task" =~ download|both ]]; then
   HTTP_STATUS=$(curl -Is -o /dev/null -w "%{http_code}" "$FORTIFY_FILE_URL")
   if [ "$HTTP_STATUS" -eq 200 ]; then
      echo "  URL for FORTIFY_FILE_URL exist. Let download it...";
      curl -o $TEMP_PATH/fortify-client.run "$FORTIFY_FILE_URL"
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



exit 1



/home/$local_os_user_id/Fortify

        chmod +x fortify-client.run


/tmp/fortify-client.run --mode unattended --fortify_license_path /tmp/fortify-license --install_dir /opt/Fortify/Fortify_SCA_Client && \
cat /tmp/fortify-custom.properties.ini >> /opt/Fortify/Fortify_SCA_Client/Core/config/fortify-sca.properties && \
/opt/Fortify/Fortify_SCA_Client/bin/fortifyupdate

  echo 'export PATH="~/bin:$PATH"' | sudo tee /etc/profile.d/fortify_env.sh > /dev/null
  export PATH="~/bin:$PATH"


echo "--------------------------------------------------------"
echo "- Adding users that belong to group '$grp_to_add' "
echo "--------------------------------------------------------"
