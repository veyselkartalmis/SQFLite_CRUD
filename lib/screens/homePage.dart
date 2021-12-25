// ignore_for_file: prefer_const_constructors_in_immutables, file_names, prefer_const_constructors, unnecessary_new, unused_field, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unused_local_variable, avoid_unnecessary_containers, avoid_function_literals_in_foreach_calls, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_sqflite/models/car.dart';
import 'package:flutter_sqflite/utils/db_helper.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Car> cars = [];
  List<Car> carsByName = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController milesUpdateController = TextEditingController();
  TextEditingController idDeleteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Car App - SQFLite"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Insert"),
              Tab(text: "View"),
              Tab(text: "Query"),
              Tab(text: "Update"),
              Tab(text: "Delete"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //Add cars
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Car Name",
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: milesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Car Miles",
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        String name = nameController.text;
                        int miles = int.parse(milesController.text);
                        _insert(name, miles);
                      });
                    },
                    child: Text("Insert Car Details"),
                  ),
                ],
              ),
            ),
            //All cars
            Container(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: cars.length + 1,
                itemBuilder: (context, index) {
                  if (index == cars.length) {
                    return ElevatedButton(
                      onPressed: () {
                        _queryAll();
                      },
                      child: Text("Refresh"),
                    );
                  }
                  return Container(
                    height: 40,
                    child: Center(
                      child: Text(
                        "[${cars[index].id}] - ${cars[index].name} - ${cars[index].miles} miles",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            //Search car
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: queryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Car Name",
                      ),
                      onChanged: (text) {
                        if (text.length >= 2) {
                          setState(() {
                            _query(text);
                          });
                        } else {
                          setState(() {
                            carsByName.clear();
                          });
                        }
                      },
                    ),
                    height: 100,
                  ),
                  Expanded(
                    child: Container(
                      height: 300,
                      child: ListView.builder(
                        itemCount: carsByName.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 50,
                            margin: EdgeInsets.all(2),
                            child: Center(
                              child: Text(
                                "${carsByName[index].id}] - ${carsByName[index].name} - ${carsByName[index].miles} miles",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Update car
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: TextField(
                            controller: idUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car ID",
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: TextField(
                            controller: nameUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car Name",
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: TextField(
                            controller: milesUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car Miles",
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              int id = int.parse(idUpdateController.text);
                              String name = nameUpdateController.text;
                              int miles = int.parse(milesUpdateController.text);
                              _update(id, name, miles);
                            });
                          },
                          child: Text("Update Car Details"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //Delete car
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: idDeleteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Car ID",
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int id = int.parse(idDeleteController.text);
                      _delete(id);
                    },
                    child: Text("Delete Car Details"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //DB'ye ekleme işlemini gerçekleştiriyorum
  void _insert(String name, int miles) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles,
    };

    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    nameController.clear();
    milesController.clear();
    debugPrint("Inserted row id: $id");
  }

  //DB'den bütün datayı çekiyorum
  void _queryAll() async {
    //bütün rowları çekiyorum
    final allRows = await dbHelper.queryAllRows();
    //listemi temizliyorum
    cars.clear();
    //cars dizisi içerisine cars değişkenlerini yazdığım methodla aktarıyorum
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    debugPrint("Query done.");
    setState(() {});
  }

  //DB'de arama işlemi gerçekleştiriyorum
  void _query(String text) async {
    final allRows = await dbHelper.queryRows(text);
    carsByName.clear();
    allRows.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  //DB'de güncelleme işlemi gerçekleştiriyorum
  void _update(int id, String name, int miles) async {
    Car car = Car(id, name, miles);
    final rowsAffected = await dbHelper.update(car);
    idUpdateController.clear();
    nameUpdateController.clear();
    milesUpdateController.clear();
    debugPrint("Updated $rowsAffected row(s)");
  }

  //DB'den ID'ye göre silme işlemi gerçekleştiriyorum
  void _delete(int id) async {
    final rowsDeleted = await dbHelper.delete(id);
    idDeleteController.clear();
    debugPrint("Deleted $rowsDeleted row(s)");
  }
}
