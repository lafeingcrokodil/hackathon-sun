/*
// Welcome to the front end.
// By Keone Martin 15/10/2017
// Bring me the sun app for hack like a girl - travel.
//
*/
$(document).ready(function(){
  var LONDON = { latitude: 51.5074, longitude: 0.1278 };
  // first grab the users location data
  // NOTE we will force a value since the apis have a limited number of starting locations on the free model
  // if we were actually using the geolocation for the display obviously we'd have to set up permission handling etc
  // var location = null;
  // if (navigator.geolocation){
  //   location = navigator.geolocation.getCurrentPosition(getFlightData)
  // }

  getFlightData(LONDON);

  $('.leaving').on('click', function(){
    $('.flight_out').show();
    $('.flight_in').hide();
    $('.leaving').css('opacity', '1');
    $('.coming').css('opacity', '0.25');
    $('.travel_status_div_1').css('opacity', '0');
    $('.travel_status_div').css('opacity', '1');
  });

  $('.coming').on('click', function(){
    $('.flight_out').hide();
    $('.flight_in').show();
    $('.leaving').css('opacity', '0.25');
    $('.coming').css('opacity', '1');
    $('.travel_status_div_1').css('opacity', '1');
    $('.travel_status_div').css('opacity', '0');
  });

});


var getFlightData = function (location){
  $.ajax({
    // url: 'http://hackathon-sun.herokuapp.com/flights',
    url: 'http://localhost:3000/flights',
    data: { latitude: location.latitude, longitude: location.longitude }
  })
  .done(function(res){
    displayInfo(res);
  })
}

var displayInfo = function (details) {
  var data = details.data || {};
  // HACK i'm going to assign a price cos the apis are a little limited and the example we're using costs over 1000 euro >.>
  data.price = "156";
  $('.price').text(data.price.replace(/\..+/, '') + ' ' + data.currency);
  $('.temperature').text(Math.round( data.temperature * 10) / 10);
  $('.suggestedCity').text(data.destination);
  $('.flight_in .travel_weekday_and_date').text(data.inbound.date);
  $('.flight_in .airportlocation').text(data.destination);
  $('.flight_in .departurecity').text(data.destination);
  $('.flight_in .arrivalcity').text(data.origin);
  $('.flight_in .traveldate').text(data.inbound.date);
  $('.flight_in .arrivaltime').text(data.inbound.arrivalTime);
  $('.flight_in .departure.traveltime').text(data.inbound.departureTime);
  $('.flight_in .airlineName').text(data.inbound.airlineName);
  $('.flight_in .flightNumber').text(data.inbound.flightNumber);
  $('.flight_out .travel_weekday_and_date').text(data.outbound.date);
  $('.flight_out .airportlocation').text(data.origin);
  $('.flight_out .departurecity').text(data.destination);
  $('.flight_out .arrivalcity').text(data.origin);
  $('.flight_out .traveldate').text(data.outbound.date);
  $('.flight_out .arrivaltime').text(data.outbound.arrivalTime);
  $('.flight_out .departure.traveltime').text(data.outbound.departureTime);
  $('.flight_out .airlineName').text(data.outbound.airlineName);
  $('.flight_out .flightNumber').text(data.outbound.flightNumber);

  $('.bookFlights').on('click', function() {
    window.location.replace(data.deepLink);
  });

}
