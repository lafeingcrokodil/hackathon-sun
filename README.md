# Show me the sun!

## Installation

1. Clone the repository.
1. Make sure that you have the right version of Node.js installed (see `package.json`).
1. Run `npm install`.
1. Make sure that the environment variables listed below are defined.
1. Run `npm start`.

### Environment variables

- `AMADEUS_API_KEY` - key for the [Amadeus API](https://sandbox.amadeus.com/api-catalog)
- `OPENWEATHERMAP_API_KEY` - key for the [OpenWeatherMap API](http://openweathermap.org/api)
- `DEBUG` - optional; can be set to something like `'hackathon-sun:*'` to enable more verbose logging

## API

### GET /flights

There are two required query parameters:

- `latitude` - floating-point number between -180 and 180
- `longitude` - floating-point number between -90 and 90

If all goes well, the response looks as follows:

```
{
  "data": {
    "price": "106.04", # total price for return trip
    "currency": "EUR",
    "temperature": 23.76666666666671, # temperature in °C
    "origin": "London",
    "destination": "Alicante",
    "deepLink": "https://...", # redirect users here for booking
    "outbound": {
      "airlineName": "Air Europa",
      "flightNumber": "UX 1014",
      "date": "2017-10-20",
      "departureTime": "10:05",
      "arrivalTime": "16:05"
    },
    "inbound": {
      "airlineName": "Air Europa",
      "flightNumber": "UX 4042",
      "date": "2017-10-22",
      "departureTime": "12:30",
      "arrivalTime": "16:20"
    }
  }
}
```

If something goes wrong, it includes an `error` field in place of the `data` field:

```
{
  "error": {
    "name": "BadRequestError",
    "message": "Bad Request: missing longitude"
  }
}
```
