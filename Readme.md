# Destiny Data to S3 JSON files

This downloads the Destiny `mobileWorldContent` and extracts to a JSON file and uploads to S3.

AWS Lambda friendly.

To run yourself, try this:

```coffee
destiny = require './lib/destiny'
tmpDir = '/tmp/'

destiny.downloadData tmpDir
    .then (allData) ->
        console.log allData

```

If you want to run the script locally from your computer to upload to S3, just execute `dumpDataToS3.coffee`, making sure you pass in a stubbed `context` object (needed for AWS Lambda). You can find a commented out example in index.js