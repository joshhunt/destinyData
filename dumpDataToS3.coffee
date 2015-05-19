AWS = require 'aws-sdk'
rimraf = require 'rimraf'
mkdirp = require 'mkdirp'
Promise = require 'bluebird'
destiny = require './lib/destiny'

bucketName = 'destiny.plumbing'
region = 'us-east-1'

index = {raw:{}}
s3 = new AWS.S3()
publicPathRoot = 'http://destiny.plumbing/'

uploadDataset = ({table, data}) ->
    key = "raw/#{table}.json"

    uploadToS3 key, data
        .then ->
            index.raw[table] = publicPathRoot + key

uploadToS3 = (key, data) -> new Promise (resolve, reject) ->
    s3.putObject {
        Bucket: bucketName
        Key: key
        ContentType: 'application/json'
        Body: JSON.stringify data
        ACL: 'public-read'
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
                promises.push uploadDataset dataSet

            Promise.all(promises)
        .then ->
            console.log 'All data has uploaded. Uploading manifest.'
            key = 'index.json'
            uploadToS3 key, index
        .then ->
            context.succeed()
        .catch (err) ->
            console.log 'Error with destiny.downloadData!'
            console.log err.stack
            context.fail err