AWS = require 'aws-sdk'
sns = new AWS.SNS({region: 'us-east-1'})

params =
    Message: 'update'
    TopicArn: 'arn:aws:sns:us-east-1:167180637055:destinyPlumbing'

sns.publish params, (err, data) ->
    if err
        console.log err, err.stack
        return

    console.log 'Created SNS notification'
    console.log data
