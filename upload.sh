#! /bin/bash

zip -r archiveLambda.zip index.js dumpDataToS3.coffee node_modules lib
archive=$( base64 archiveLambda.zip )
dir=$(pwd)

echo ''
echo 'Uploading new archive from $dir'
aws lambda update-function-code --region us-east-1 --function-name myFirstFunction --zip-file fileb://${dir}/archiveLambda.zip

echo ''
echo 'Executing'
aws lambda invoke --region us-east-1 --invocation-type RequestResponse --function-name myFirstFunction --log-type Tail --payload '{}' output.txt