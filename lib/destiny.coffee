http = require('http')
fs = require('fs')

request = require('request-promise')
unzip = require 'unzip'
Promise = require 'bluebird'

# sqlite3Native = require 'node-sqlite-purejs'
SQL = require('sql.js')
_ = require("underscore")

zipPath = ''
MANIFEST_URL = 'http://www.bungie.net/platform/Destiny/Manifest/'
ROOT = root

downloadArchive = (manifest) -> new Promise (resolve, reject) ->
    zipUrl = 'http://www.bungie.net' + manifest.Response.mobileWorldContentPaths.en

    console.log '\nManifest recieved.'

    zipPath = ROOT + 'archive.zip'
    zipFileStream = fs.createWriteStream zipPath

    req = http.get zipUrl, (resp) ->
        resp.pipe zipFileStream

        resp.on 'end', ->
            zipFileStream.close()
            resolve zipPath


extractArchive = (zipPath) -> new Promise (resolve, reject) ->
    wroteFile = false
    destFile = ROOT + 'worldContentEn.sql'
    destFileStream = fs.createWriteStream destFile

    console.log 'Archive downloaded to', zipPath
    console.log 'Unzipping archive to', destFile

    fs.createReadStream zipPath
        .pipe unzip.Parse()
        .on 'entry', (entry) ->

            if wroteFile
                entry.autodrain()
                wroteFile = true
                return

            entry.pipe destFileStream

    destFileStream.on 'close', ->
        resolve(destFile)

openDatabase = (dbPath) -> new Promise (resolve, reject) ->
    console.log '\nOpening database at', dbPath

    dbFileBuffer = fs.readFileSync dbPath
    db = new SQL.Database dbFileBuffer
    resolve db

saveData = (db) ->
    console.log '\nExtracting and saving data from database...'

    tables = {
        'DestinyActivityDefinition':        'activityHash'
        'DestinyActivityTypeDefinition':    'activityTypeHash'
        'DestinyClassDefinition':           'classHash'
        'DestinyDestinationDefinition':     'destinationHash'
        'DestinyDirectorBookDefinition':    'bookHash'
        'DestinyFactionDefinition':         'factionHash'
        'DestinyGenderDefinition':          'genderHash'
        'DestinyGrimoireCardDefinition':    'cardId'
        'DestinyHistoricalStatsDefinition': 'statId'
        'DestinyInventoryBucketDefinition': 'bucketHash'
        'DestinyInventoryItemDefinition':   'itemHash'
        'DestinyPlaceDefinition':           'placeHash'
        'DestinyProgressionDefinition':     'progressionHash'
        'DestinyRaceDefinition':            'raceHash'
        'DestinySandboxPerkDefinition':     'perkHash'
        'DestinySpecialEventDefinition':    'eventHash'
        'DestinyStatDefinition':            'statHash'
        'DestinyStatGroupDefinition':       'statGroupHash'
        'DestinyTalentGridDefinition':      'gridHash'
        'DestinyUnlockFlagDefinition':      'flagHash'
        'DestinyVendorCategoryDefinition':  'categoryHash'
    }

    promises = []
    for tableName, id of tables
        promises.push extractData db, tableName, {id}

    Promise.all promises

extractData = (db, tableName, {id}) -> new Promise (resolve, reject) ->
    query = "select * from #{tableName}"
    console.log "Processing #{tableName}"
    [{values}] = db.exec query

    data = {}
    values.forEach ([colId, json]) ->
        item = JSON.parse json
        data[item[id]] = item

    resolve {
        table: tableName
        data: data
    }

module.exports.downloadData = (root) ->
    ROOT = root
    console.log '\nDownloading manifest', MANIFEST_URL
    request MANIFEST_URL
        .then JSON.parse
        .then downloadArchive
        .then extractArchive
        .then openDatabase
        .then saveData
