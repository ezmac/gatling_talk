#!/bin/bash
set -x


## Yeah this is hacky, but probably good enough..


chromium=`which chromium-browser`
googlechrome=`which google-chrome`
if [ -z "$chromium" ] && [ -z "$googlechrome" ]; then
  echo "neither chrome/chromium found."
  exit -1
else
  # default to chromium cause if you have it you went through the trouble to use it.
  chrome=$chromium
fi

if [[ -z $chromium ]]; then
  chrome=$googlechrome
fi

profile=`date +%Y%m%d%H%M`
mkdir -p /tmp/.chromium_profiles/$profile/{profile,user_data}





$chrome --profile-directory=/tml/.chromium_profiles/$profile/profile --user-data-dir=/tmp/.chromium_profiles/$profile/user_data --proxy-server=${DOCKER_PROXY_IP-localhost}:8000  --ignore-certificate-errors &
docker run -it -p 8000:8000 -v $PWD/gatlingconf/:/opt/gatling/conf/:ro -v $PWD/user-files:/opt/gatling/user-files --entrypoint bash gatling /opt/gatling/bin/recorder.sh -cli true -cn "RecordedSimulation_$profile" $@


## options to use with gatling recorder: `-ihr false` or `-ihr true` Infer Html Resources
# unfortunately missing is the white/black list domain option

