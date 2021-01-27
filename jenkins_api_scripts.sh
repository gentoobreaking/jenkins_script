#!/bin/bash

set_my_token()
{
export JENKINS_USER_ID='david'
export JENKINS_API_TOKEN='11ce7b19463b347734efd71c342d02xxxx' # david token at davidtest
export JENKINS_URL='http://192.168.100.190:8080/'
export MY_STORE='davidtest'
}

set_my_token_fp()
{
export JENKINS_USER_ID='david'
export JENKINS_API_TOKEN='11055fc81d0ee397330acf8c0f8478yyyy' # david token at jenkins.funpodium.net
export JENKINS_URL='http://jenkins.funpodium.net:8080/'
export MY_STORE='jenkins.funpodium.net'
}

download_jenkins-cli()
{
wget "${JENKINS_URL}"jnlpJars/jenkins-cli.jar
}

backup_status()
{
[ ! -d "${MY_STORE}" ] && mkdir "${MY_STORE}"
java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket list-jobs > ./"${MY_STORE}"/list-jobs.txt
java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket list-plugins > ./"${MY_STORE}"/list-plugins.txt
java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket list-credentials system::system::jenkins > ./"${MY_STORE}"/list-credentials-id.txt
# java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket list-credentials-as-xml system::system::jenkins
}

backup_all_jobs()
{
[ ! -d "${MY_STORE}/jobs" ] && mkdir -p "${MY_STORE}"/jobs

#IFS for jobs with spaces.
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for i in $(java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket list-jobs);
do
  java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket get-job ${i} > ./"${MY_STORE}"/jobs/${i}.xml;
done
IFS=$SAVEIFS
}

import_all_jobs()
{
for f in ./jenkins.funpodium.net/jobs/*.xml;
do
  export job_name=$(echo $f|awk -F'/' '{print $NF}'|sed 's|.xml||g')
  echo "Processing $f file for ${job_name}."; # truncate the .xml extention and load the xml file for job creation
  java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket create-job "${job_name}" < "$f"
done
}

backup_all_view()
{
export input="./jenkins.funpodium.net/viewlist.txt" # it can't get by api.
[ ! -d "${MY_STORE}/view" ] && mkdir -p "${MY_STORE}"/view

while IFS= read -r target
do
  echo "Processing ${target}"
  java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket get-view "${target}" > ./"${MY_STORE}"/view/"${target}".xml &
done < "$input"
}

import_all_views()
{
for f in ./jenkins.funpodium.net/view/*.xml;
do
  export view_name=$(echo $f|awk -F'/' '{print $NF}'|sed 's|.xml||g')
  echo "Processing $f file for ${view_name}."; # truncate the .xml extention and load the xml file for view creation
  java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket create-view "${view_name}" < "$f"
done
}


#java -jar jenkins-cli.jar -s http://server get-job myjob > myjob.xml
#java -jar jenkins-cli.jar -s http://server create-job newmyjob < myjob.xml

#download_jenkins-cli
set_my_token
#set_my_token_fp
#backup_status
#backup_all_jobs
#backup_all_view
#import_all_views
import_all_jobs

#java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket help

#java -jar jenkins-cli.jar -s "${JENKINS_URL}" -webSocket get-view VIEW

# --- END --- #
