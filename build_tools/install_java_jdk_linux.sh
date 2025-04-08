#-----------------------------------------------------------------------------------------------
#  Copy Azul Zulu of OpenJDK to Linux host from Nexus
# 
#  Run this script on a new linux system is to run the following command. You can pass arguments to the shell using the -s option:
#   curl -Lfk https://github.com/alvaria-com/scrm_public_scripts/raw/refs/heads/main/build_tools/install_java_jdk_linux.sh | sudo bash -s <java_8|java_11|java_17|java_21|ANT_110|all>
#
# Created: Mar-31-2025 Hubers
# Updates: xxx
#-----------------------------------------------------------------------------------------------

JAVA_08_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu8.84.0.15-ca-jdk8.0.442-linux_x64.tar.gz'
JAVA_11_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu11.78.15-ca-jdk11.0.26-linux_x64.tar.gz'
JAVA_17_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu17.56.15-ca-jdk17.0.14-linux_x64.tar.gz'
JAVA_21_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_jdk/zulu/zulu21.40.17-ca-jdk21.0.6-linux_x64.tar.gz'
JAVA_05_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-iq-hosted/com/alvaria/thirdparty/java/jdk/java/1.5/java-1.5.tar.gz'

ANT_10_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_ant/apache-ant-1.10.15-bin.tar.gz'
ANT_IVY_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_ant/apache-ivy-2.5.3-bin.tar.gz'
ANT_CONTRIB_NEXUS_FILE='https://nexus.aws.alvaria.com/nexus/repository/alvaria-raw-prod-hosted/scrm/build_tools/java_ant/ant-contrib-1.0b3.jar'

JDK_INSTALL_PATH='/usr/lib/java/jdk'
ANT_INSTALL_PATH='/usr/lib/ant'

# check if command line argument is empty or not present
if [ -z $1 ]; then
   echo "Info: No task was listed, default to 'download'"
   task="download"
else
   task="$1"
fi

echo ' '
echo "-- Start of Java JDKs install and is doing task: '$task'"
echo ' '


### Create the main folders.
sudo mkdir -p $JDK_INSTALL_PATH
sudo mkdir -p $ANT_INSTALL_PATH

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
    if [[ "$task" =~ java_5|all ]]; then
    JAVA_JDK_INSTALL_PATH=$JDK_INSTALL_PATH/jdk_5
    mkdir -p $JAVA_JDK_INSTALL_PATH
    download_nexus_file  "$JAVA_05_NEXUS_FILE"  "$JAVA_JDK_INSTALL_PATH/java_jdk.tar.gz"
    tar -xzf $JAVA_JDK_INSTALL_PATH/java_jdk.tar.gz  --strip-components=1 -C $JAVA_JDK_INSTALL_PATH

    ## Let create a file to show what the full version of this java is:
    tar -tf $JAVA_JDK_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1 > $JAVA_JDK_INSTALL_PATH/java_version

    rm $JAVA_JDK_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export JAVA_HOME_5=${JAVA_JDK_INSTALL_PATH}" | sudo tee /etc/profile.d/java_home_5_env.sh
    echo "Created env: JAVA_HOME_5=${JAVA_JDK_INSTALL_PATH} for next bootup."
    echo "If you want to use this version of JDK, export JAVA_HOME=\$JAVA_HOME_5"
    
    echo "Done installing Java 1.5 at ${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}"
    else
        echo "** Not set to install this Java version.  Skipping this step."
    fi
    echo ''


echo "--- Install Java 8   -----------------------------"
    if [[ "$task" =~ java_8|all ]]; then
    JAVA_VER='08'

    NEXUS_FILE_VAR="JAVA_${JAVA_VER}_NEXUS_FILE"
    download_nexus_file "$(eval echo \$$NEXUS_FILE_VAR)"  "$JDK_INSTALL_PATH/java_jdk.tar.gz"

    
    tar -xzf $JDK_INSTALL_PATH/java_jdk.tar.gz -C $JDK_INSTALL_PATH
    ## Let create a file to show what the full version of this java is:
    JAVA_VERSION_FOLDER=$(tar -tf $JDK_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1)
    rm $JDK_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}" | sudo tee /etc/profile.d/java_home_${JAVA_VER}_env.sh > /dev/null
    echo "Created env: JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER} for next bootup."
    echo "If you want to use this version of JDK, export JAVA_HOME=\$JAVA_HOME_${JAVA_VER}"

    echo "Done installing Java $JAVA_VER at ${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}"
    else
        echo "** Not set to install this Java version.  Skipping this step."
    fi
    echo ''


echo "--- Install Java 11   ----------------------------"
    if [[ "$task" =~ java_11|all ]]; then
    JAVA_VER='11'

    NEXUS_FILE_VAR="JAVA_${JAVA_VER}_NEXUS_FILE"
    download_nexus_file "$(eval echo \$$NEXUS_FILE_VAR)"  "$JDK_INSTALL_PATH/java_jdk.tar.gz"

    tar -xvf $JDK_INSTALL_PATH/java_jdk.tar.gz -C $JDK_INSTALL_PATH
    ## Let create a file to show what the full version of this java is:
    JAVA_VERSION_FOLDER=$(tar -tf $JDK_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1)
    rm $JDK_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}" | sudo tee /etc/profile.d/java_home_${JAVA_VER}_env.sh > /dev/null
    echo "Created env: JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER} for next bootup."
    echo "If you want to use this version of JDK, export JAVA_HOME=\$JAVA_HOME_${JAVA_VER}"

    echo "Done installing Java $JAVA_VER at ${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}"
    else
        echo "** Not set to install this Java version.  Skipping this step."
    fi
    echo ''


echo "--- Install Java 17   ----------------------------"
    if [[ "$task" =~ java_17|all ]]; then
    JAVA_VER='17'

    NEXUS_FILE_VAR="JAVA_${JAVA_VER}_NEXUS_FILE"
    download_nexus_file "$(eval echo \$$NEXUS_FILE_VAR)"  "$JDK_INSTALL_PATH/java_jdk.tar.gz"

    tar -xzf $JDK_INSTALL_PATH/java_jdk.tar.gz -C $JDK_INSTALL_PATH
    ## Let create a file to show what the full version of this java is:
    JAVA_VERSION_FOLDER=$(tar -tf $JDK_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1)
    rm $JDK_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}" | sudo tee /etc/profile.d/java_home_${JAVA_VER}_env.sh > /dev/null
    echo "Created env: JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER} for next bootup."
    echo "If you want to use this version of JDK, export JAVA_HOME=\$JAVA_HOME_${JAVA_VER}"

    echo "Done installing Java $JAVA_VER at ${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}"
    else
        echo "** Not set to install this Java version.  Skipping this step."
    fi
    echo ''


echo "--- Install Java 21   ----------------------------"
    if [[ "$task" =~ java_21|all ]]; then
    JAVA_VER='21'

    NEXUS_FILE_VAR="JAVA_${JAVA_VER}_NEXUS_FILE"
    download_nexus_file "$(eval echo \$$NEXUS_FILE_VAR)"  "$JDK_INSTALL_PATH/java_jdk.tar.gz"

    tar -xzf $JDK_INSTALL_PATH/java_jdk.tar.gz -C $JDK_INSTALL_PATH
    ## Let create a file to show what the full version of this java is:
    JAVA_VERSION_FOLDER=$(tar -tf $JDK_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1)
    rm $JDK_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}" | sudo tee /etc/profile.d/java_home_${JAVA_VER}_env.sh > /dev/null
    echo "Created env: JAVA_HOME_${JAVA_VER}=${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER} for next bootup."
    echo "If you want to use this version of JDK, export JAVA_HOME=\$JAVA_HOME_${JAVA_VER}"

    echo "Done installing Java $JAVA_VER at ${JDK_INSTALL_PATH}/${JAVA_VERSION_FOLDER}"
    else
        echo "** Not set to install this Java version.  Skipping this step."
    fi
    echo ''


echo "--- Install ANT 1.10  ----------------------------"
    if [[ "$task" =~ ant_110|all ]]; then
    ANT_VER='10'

    NEXUS_FILE_VAR="ANT_${ANT_VER}_NEXUS_FILE"

    download_nexus_file "$(eval echo \$$NEXUS_FILE_VAR)"  "$ANT_INSTALL_PATH/ant.tar.gz"
    download_nexus_file $ANT_IVY_NEXUS_FILE  "$ANT_INSTALL_PATH/ivy.tar.gz"
    download_nexus_file $ANT_CONTRIB_NEXUS_FILE  "$ANT_INSTALL_PATH/ant.contrib.jar"


    tar -xzf $ANT_INSTALL_PATH/ant.tar.gz -C $ANT_INSTALL_PATH
    ANT_VERSION_FOLDER=$(tar -tf $ANT_INSTALL_PATH/java_jdk.tar.gz | awk -F/ '{print $1}' | uniq | head -n 1)
    rm $ANT_INSTALL_PATH/java_jdk.tar.gz

    ## Set an env to this for ref
    echo "export ANT_HOME_${ANT_VER}=${ANT_INSTALL_PATH}/${ANT_VERSION_FOLDER}" | sudo tee /etc/profile.d/ant_home_${ANT_VER}_env.sh > /dev/null
    echo "Created env: ANT_HOME_${ANT_VER}=${ANT_INSTALL_PATH}/${ANT_VERSION_FOLDER} for next bootup."
    echo "If you want to use this version of ANT, export ANT_HOME=\$ANT_HOME_${ANT_VER}"

    echo "Done installing ANT $ANT_VER at ${ANT_INSTALL_PATH}/${ANT_VERSION_FOLDER}"
    else
        echo "** Not set to install this ANT version.  Skipping this step."
    fi
    echo ''
