var path = require('path')
var Promise = require('bluebird')
var fs = require('fs');
var parse = require('../node_modules/csv-parser');

module.exports.parseFile = function(input){
  return new Promise(function(resolve, reject) {

    var inputFile = path.join(__dirname, '../data/flight-search-cache-origin-destination');
    var destinations = {};
    var origins = {};

    fs.createReadStream(inputFile)
    .pipe(parse({delimiter: ','}))
    .on('data', function(csvrow) {
      var destination = csvrow.destination;
      var origin = csvrow.origin;
      var currency = csvrow.currency;

      destinations[csvrow.destination] = true;
      if (origins[origin]){
        origins[origin].destinations.push(destination);
      } else {
        origins[origin] = {
          destinations: [destination],
          currency: currency
        };
      }

    })
    .on('end',function() {
      var output = {
        destinations: destinations,
        origins: origins
      }
      resolve(output);
    })
    .on('error', function(error) {
      reject(error);
    });
  });
}
