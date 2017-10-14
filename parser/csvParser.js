var path = require('path')
var fs = require('fs');
var parse = require('../node_modules/csv-parser');
var inputFile = path.join(__dirname, '../data/flight-search-cache-origin-destination.csv');

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
        // console.log(origins[origin]);
        origins[origin].destinations.push(destination);
      } else {
        origins[origin] = {
          destinations: [destination],
          currency: currency
        };
      }

    })
    .on('end',function() {
      console.log(Object.keys(destinations));
      console.log(origins);
    });
