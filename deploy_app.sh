#!/usr/bin/env bash 

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace 


target_app='my-app-demo.zip'
target_bucket='fmbah-dev-env-logs'
target_app_version='version-2'

eb_app_name='fmbah-dev-app'
eb_env_name='fmbah-dev-env' 
eb_region='eu-west-1'

# Copy bundled zip file to s3
aws s3 cp ${target_app} s3://${target_bucket}


# Create new app version 
aws elasticbeanstalk create-application-version --application-name ${eb_app_name} --version-label ${target_app_version} --source-bundle S3Bucket="${target_bucket}",S3Key="${target_app}" --region ${eb_region}

# Update app - aka deploy app 
aws elasticbeanstalk update-environment --application-name ${eb_app_name}  --environment-name ${eb_env_name} --version-label ${target_app_version} --region ${eb_region}

