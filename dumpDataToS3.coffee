AWS = require 'aws-sdk'
rimraf = require 'rimraf'
mkdirp = require 'mkdirp'
Promise = require 'bluebird'
destiny = require './lib/destiny'


bucketName = 'lambda-test'
region = 'us-east-1'
key = 'testData.json'

s3 = new AWS.S3()

uploadToS3 = (key, data) -> new Promise (resolve, reject) ->
    s3.putObject {
        Bucket: bucketName
        Key: key
        ContentType: 'application/json'
        Body: JSON.stringify data
    }, (err) ->
        if err
            console.log 'Error uploading'
            console.log err
            reject(err)
            return

        console.log "Successfully uploaded to s3:#{region}:#{bucketName}/#{key}"
        resolve()

module.exports = (event, context) ->
    isOnLambda = context.awsRequestId?
    root = '/tmp/'

    rimraf.sync root + 'worldContentEn.sql'
    rimraf.sync root + 'archive.zip'

    console.log 'Starting destiny.downloadData()'
    destiny.downloadData root
        .then (allData) ->
            promises = []

            for dataSet in allData
                key = "raw/#{dataSet.table}.json"
                promises.push uploadToS3 key, dataSet.data

            Promise.all(promises)
        .then ->
            console.log 'All data has uploaded!'
            context.succeed()
        .catch (err) ->
            console.log 'Error with destiny.downloadData!'
            console.log err.stack
            context.fail err