import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {

  final _apiKey = "";
  final _baseUrl = "https://api.openweathermap.org/data/2.5/";
  final _units = "metric";
  String _location = "";
  final _locationLat = "51,812565";
  final _locationLon = "5,837226";
  final _excludeData = "current,minutely,alerts";
  final _daysOfTheWeek = Map();
  
  String get Location => _location;

  WeatherService(){
    _daysOfTheWeek[DateTime.monday] = "Mon";
    _daysOfTheWeek[DateTime.tuesday] = "Tue";
    _daysOfTheWeek[DateTime.wednesday] = "Wed";
    _daysOfTheWeek[DateTime.thursday] = "Thu";
    _daysOfTheWeek[DateTime.friday] = "Fri";
    _daysOfTheWeek[DateTime.saturday] = "Sat";
    _daysOfTheWeek[DateTime.sunday] = "Sun";
  }

  void changeLocation(String location){
    print("$_location | $location");
    _location = location;
  }

  Future<double> getCurrentTemperature() async {

    final url = Uri.parse("${_baseUrl}weather?q=$_location&appid=$_apiKey&units=$_units");
    
    final response = await http.get(url);

    final rawJson = jsonDecode(response.body);

    final temperature = jsonDecode(rawJson["main"]["temp"].toString());

    return temperature;
  }

  Future<List<HourlyTemperature>> getHourlyWeatherForecast() async {

    List<HourlyTemperature> hourlyTemperatures = [];

    final url = Uri.parse("${_baseUrl}onecall?lat=$_locationLat&lon=$_locationLon&exclude=$_excludeData&appid=$_apiKey&units=$_units");

    final response = await http.get(url);

    final rawJson = jsonDecode(response.body);

    for (var hourly in rawJson["hourly"]) {
     
      var dt = DateTime.fromMillisecondsSinceEpoch((hourly["dt"] as int) * 1000);
      
      var temperature = hourly["temp"];
      
      hourlyTemperatures.add(HourlyTemperature(dt.hour.toString(), temperature));
    }

    return hourlyTemperatures;
  }

    Future<List<DailyTemperature>> getDailyWeatherForecast() async {

    List<DailyTemperature> hourlyTemperatures = [];

    final url = Uri.parse("${_baseUrl}onecall?lat=$_locationLat&lon=$_locationLon&exclude=$_excludeData&appid=$_apiKey&units=$_units");

    final response = await http.get(url);

    final rawJson = jsonDecode(response.body);

    for (var hourly in rawJson["daily"]) {

      var dt = DateTime.fromMillisecondsSinceEpoch((hourly["dt"] as int) * 1000);
      
      var temperatures = hourly["temp"];
      
      var dow =_daysOfTheWeek[dt.weekday];
      
      hourlyTemperatures.add(DailyTemperature(dow, temperatures["max"]));
    }

    return hourlyTemperatures;
  }
}

class HourlyTemperature {
  final String time;
  final double temperature;
  HourlyTemperature(this.time, this.temperature);
}

class DailyTemperature {
  final String day;
  final double temperature;
  DailyTemperature(this.day, this.temperature);
}
