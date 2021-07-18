import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weatherapp/services/wheather_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF083D77),
  	    backgroundColor: Color(0xFF083D77),
        iconTheme: IconThemeData(color: Color(0xffCFDAE8)),
      ),
      home: MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _weatherService = WeatherService();
  final _locations = ["Nijmegen","Amsterdam","Tiel","Eindhoven"];
  int index = 0;
  late Timer timer;
  double _currentWeather = 0;

  _MyHomePageState(){
    timer = Timer.periodic(Duration(seconds: 3), timerUpdate);
    _weatherService.changeLocation(_locations[index]);
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentWeather();
  }

  void timerUpdate(Timer time) async {
    _weatherService.changeLocation(_locations[index++]);

    _currentWeather = await _weatherService.getCurrentTemperature();
    
    if(index > _locations.length-1)
        index = 0;

    setState(() {});
  }

  void fetchCurrentWeather() async {
    _currentWeather = await _weatherService.getCurrentTemperature();
    setState(() {});
  }

  Future<List<Widget>> createHourlyForcast() async {
    final List<Widget> _children = [];

    final _forecasts = await _weatherService.getHourlyWeatherForecast();

    for(var hourlyForecast in _forecasts) {
      _children.add(Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xff6D86A1), width: 3, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(15)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height:10),
              Text("${hourlyForecast.time}:00", style: TextStyle(fontSize: 18, color: Colors.white)),
              const Icon(FontAwesomeIcons.cloud, size: 32),
              Text("°C ${hourlyForecast.temperature}",  style: TextStyle(fontSize: 18, color: Colors.white))
            ],
          ),
        ),
      ));
    }

    return _children;
  }

    Future<List<Widget>> createDailyForcast() async {
    final List<Widget> _children = [];

    final _forecasts = await _weatherService.getDailyWeatherForecast();

    for(var hourlyForecast in _forecasts) {
      _children.add(Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xff6D86A1), width: 3, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(15)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height:10),
              Text("${hourlyForecast.day}", style: TextStyle(fontSize: 18, color: Colors.white)),
              const Icon(FontAwesomeIcons.cloud, size: 32),
              Text("°C ${hourlyForecast.temperature}",  style: TextStyle(fontSize: 18, color: Colors.white))
            ],
          ),
        ),
      ));
    }

    return _children;
  }

  @override
  Widget build(BuildContext context) {

    var maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: Center(child: Text(widget.title),),
      // ),
      body: Container(
    width: double.infinity,
    height: double.infinity,
    color: Color(0x0021518e),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
            Container(
                width: double.infinity,
                height: 180,
                color: Colors.transparent,
                child: Icon(FontAwesomeIcons.cloud, size: 125),
            ),
            SizedBox(height: 25),
            SizedBox(
                width: double.infinity,
                height: 37,
                child: Text(
                    "°C $_currentWeather ${_weatherService.Location}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                    ),
                ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
              width: maxWidth,
              height: 400,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 25, top: 5),
                      child: Text("Next 24 hours", 
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                        ))
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: SizedBox(
                        width:  maxWidth,
                        height: 100,
                        child: FutureBuilder<List<Widget>>(
                          future: createHourlyForcast(),
                          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                            
                            if(snapshot.connectionState == ConnectionState.waiting)
                              return LinearProgressIndicator();

                            if(snapshot.hasError)
                              return Center(child: Text("Oops something went wrong, try again later"));

                            if(snapshot.hasData)
                              return ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: snapshot.requireData,
                              );
                              
                              // Hmmm
                              return Text("You are special");
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.only(left: 25, top: 5),
                      child: Text("Daily Forecast", 
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                        ))
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: SizedBox(
                        width:  maxWidth,
                        height: 100,
                        child: FutureBuilder<List<Widget>>(
                          future: createDailyForcast(),
                          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                            
                            if(snapshot.connectionState == ConnectionState.waiting)
                              return LinearProgressIndicator();

                            if(snapshot.hasError)
                              return Center(child: Text("Oops something went wrong, try again later"));

                            if(snapshot.hasData)
                              return ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: snapshot.requireData,
                              );
                              
                              // Hmmm
                              return Text("You are special");
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            )
        ],
    ),
),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
