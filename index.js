require('coffee-script/register')
exports.handler = require('./dumpDataToS3.coffee')


// // For local testing.
// stubbedContext = {
//     succeed: function()     { console.log('Called context.succeed()') },
//     fail:    function(err) { console.log('Called context.fail()', err) }
// }
// module.exports.handler({}, stubbedContext)