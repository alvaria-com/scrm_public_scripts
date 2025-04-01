#-----------------------------------------------------------------------------------------------
#  Copy Azul Zulu Builds of OpenJDK to Linux host form Nexus
# 
#
#  Run this script on a new linux system is to run the following command. You can pass arguments to the shell using the -s option:
#   curl -Lfk https://github.com/alvaria-com/scrm_public_scripts/raw/refs/heads/main/build_tools/zulu_java_jdk_linux.sh | sudo bash -s <java_8|java_11|java_17|java_21|all>
#
# Created: Mar-31-2025 Hubers
#-----------------------------------------------------------------------------------------------

JAVA_08_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu8.84.0.15-ca-jdk8.0.442-linux_x64.tar.gz'
JAVA_11_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu11.78.15-ca-jdk11.0.26-linux_x64.tar.gz'
JAVA_17_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu17.56.15-ca-jdk17.0.14-linux_x64.tar.gz'
JAVA_21_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu21.40.17-ca-jdk21.0.6-linux_x64.tar.gz'


INSTALL_PATH='/usr/lib/jvm/zulu'


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



echo "--- Install Java 8   -----------------------------"
if [[ "$task" =~ java_8|all ]]; then
   mkdir -p $INSTALL_PATH/jdk_8/
   download_nexus_file  "$JAVA_08_NEXUS_FILE"  "$INSTALL_PATH/jdk_8/java_jdk.tar.gz"
   tar -xzvf $INSTALL_PATH/jdk_8/java_jdk.tar.gz -C $INSTALL_PATH/jdk_8
   rm $INSTALL_PATH/jdk_8/java_jdk.tar.gz
   echo "  Done installing Java 8 at $INSTALL_PATH/jdk_8"
else
    echo "  Not set to install this Java version.  Skipping this step."
fi
