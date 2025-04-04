#-----------------------------------------------------------------------------------------------
#  Copy Azul Zulu Builds of OpenJDK to Linux host from Nexus
# 
#
#  Run this script on a new linux system is to run the following command. You can pass arguments to the shell using the -s option:
#   curl -Lfk https://github.com/alvaria-com/scrm_public_scripts/raw/refs/heads/main/build_tools/install_java_jdk_linux.sh | sudo bash -s <java_8|java_11|java_17|java_21|all>
#
# Created: Mar-31-2025 Hubers
# Updates: xxx
#-----------------------------------------------------------------------------------------------

JAVA_08_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu8.84.0.15-ca-jdk8.0.442-linux_x64.tar.gz'
JAVA_11_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu11.78.15-ca-jdk11.0.26-linux_x64.tar.gz'
JAVA_17_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu17.56.15-ca-jdk17.0.14-linux_x64.tar.gz'
JAVA_21_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu21.40.17-ca-jdk21.0.6-linux_x64.tar.gz'

JAVA_05_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-iq-hosted/com/alvaria/thirdparty/java/jdk/java/1.5/java-1.5.tar.gz'

INSTALL_PATH='/usr/lib/java/jdk'

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

## Basic function to download file from Nexus using curl and some error check.
download_nexus_file() {
    local url=$1
    local output_path=$2

    HTTP_STATUS=$(curl -Is -o /dev/null -w "%{http_code}" "$url")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "  URL for $url exists. Let's download it..."
        curl -o "$output_path" "$url"
        chmod +x "$output_path"
    else
        echo "-ERROR-  URL for $url does NOT exist. Status code: $HTTP_STATUS"
        exit 1
    fi
}


echo "--- Install Java 5   -----------------------------"
if [[ "$task" =~ java_5 ]]; then
   JAVA_INSTALL_PATH=$INSTALL_PATH/jdk_5
   mkdir -p $JAVA_INSTALL_PATH
   download_nexus_file  "$JAVA_05_NEXUS_FILE"  "$JAVA_INSTALL_PATH/java_jdk.tar.gz"
   tar -xzvf $JAVA_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_INSTALL_PATH

   ## Let create a file to show what the full version of this java is:
   tar -tf $JAVA_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_INSTALL_PATH/java_version

   rm $JAVA_INSTALL_PATH/java_jdk.tar.gz

   ## Set an env to this for ref
   echo "export JAVA_HOME_5=${JAVA_INSTALL_PATH}/bin" | sudo tee /etc/profile.d/java_home_5_env.sh > /dev/null
   
   echo "  Done installing Java 5 at $JAVA_INSTALL_PATH"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi



echo "--- Install Java 8   -----------------------------"
if [[ "$task" =~ java_8|all ]]; then
   JAVA_INSTALL_PATH=$INSTALL_PATH/jdk_8
   mkdir -p $JAVA_INSTALL_PATH
   download_nexus_file  "$JAVA_08_NEXUS_FILE"  "$JAVA_INSTALL_PATH/java_jdk.tar.gz"
   tar -xzvf $JAVA_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_INSTALL_PATH

   ## Let create a file to show what the full version of this java is:
   tar -tf $JAVA_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_INSTALL_PATH/java_version

   rm $JAVA_INSTALL_PATH/java_jdk.tar.gz

   ## Set an env to this for ref
   echo "export JAVA_HOME_8=${JAVA_INSTALL_PATH}/bin" | sudo tee /etc/profile.d/java_home_8_env.sh > /dev/null
   
   echo "  Done installing Java 8 at $JAVA_INSTALL_PATH"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi


echo "--- Install Java 11   ----------------------------"
if [[ "$task" =~ java_11|all ]]; then
   JAVA_INSTALL_PATH=$INSTALL_PATH/jdk_11
   mkdir -p $JAVA_INSTALL_PATH
   download_nexus_file  "$JAVA_11_NEXUS_FILE"  "$JAVA_INSTALL_PATH/java_jdk.tar.gz"
   tar -xzvf $JAVA_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_INSTALL_PATH

   ## Let create a file to show what the full version of this java is:
   tar -tf $JAVA_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_INSTALL_PATH/java_version

   rm $JAVA_INSTALL_PATH/java_jdk.tar.gz
   
   ## Set an env to this for ref
   echo "export JAVA_HOME_11=${JAVA_INSTALL_PATH}/bin" | sudo tee /etc/profile.d/java_home_11_env.sh > /dev/null
   
   echo "  Done installing Java 11 at $JAVA_INSTALL_PATH"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi

echo "--- Install Java 17   ----------------------------"
if [[ "$task" =~ java_17|all ]]; then
   JAVA_INSTALL_PATH=$INSTALL_PATH/jdk_11
   mkdir -p $JAVA_INSTALL_PATH
   download_nexus_file  "$JAVA_17_NEXUS_FILE"  "$JAVA_INSTALL_PATH/java_jdk.tar.gz"
   tar -xzvf $JAVA_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_INSTALL_PATH

   ## Let create a file to show what the full version of this java is:
   tar -tf $JAVA_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_INSTALL_PATH/java_version

   rm $JAVA_INSTALL_PATH/java_jdk.tar.gz

   ## Set an env to this for ref
   echo "export JAVA_HOME_17=${JAVA_INSTALL_PATH}/bin" | sudo tee /etc/profile.d/java_home_17_env.sh > /dev/null
   
   echo "  Done installing Java 17 at $JAVA_INSTALL_PATH"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi


echo "--- Install Java 21   ----------------------------"
if [[ "$task" =~ java_21|all ]]; then
   JAVA_INSTALL_PATH=$INSTALL_PATH/jdk_11
   mkdir -p $JAVA_INSTALL_PATH
   download_nexus_file  "$JAVA_21_NEXUS_FILE"  "$JAVA_INSTALL_PATH/java_jdk.tar.gz"
   tar -xzvf $JAVA_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_INSTALL_PATH

   ## Let create a file to show what the full version of this java is:
   tar -tf $JAVA_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_INSTALL_PATH/java_version

   rm $JAVA_INSTALL_PATH/java_jdk.tar.gz

   ## Set an env to this for ref
   echo "export JAVA_HOME_21=${JAVA_INSTALL_PATH}/bin" | sudo tee /etc/profile.d/java_home_21_env.sh > /dev/null
   
   echo "  Done installing Java 21 at $JAVA_INSTALL_PATH"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi
