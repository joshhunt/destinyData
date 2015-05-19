#! /bin/bash

zip -r archiveLambda.zip index.js dumpDataToS3.coffee node_modules lib
archive=$( base64 archiveLambda.zip )
dir=$(pwd)

echo ''
echo 'Uploading new archive...'
aws lambda update-function-code --region us-east-1 --function-name destinyPlumbing --zip-file fileb://${dir}/archiveLambda.zip

echo 'Done. Lambda function ready to be executed.'