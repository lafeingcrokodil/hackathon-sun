var csvParser = require('csvParser');

csvParser.getRoutes()
  .then(function(res){
    console.log(res !== null)
  });
