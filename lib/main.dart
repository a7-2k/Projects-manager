import 'package:day9/mking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sp;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sp = await SharedPreferences.getInstance();
  // sp.clear();
  print(sp.getKeys());
  runApp(MaterialApp(
    title: 'Project Manager',
    home: Scaffold(
      body: Place(),
      //  bottomNavigationBar: Container()
    ),
  ));
}

class Place extends StatefulWidget {
  const Place({Key? key}) : super(key: key);

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  late var points = <Point>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(sp.getKeys().length);
    // points.length = sp.getKeys().length;
    for (var i = 0; i < sp.getKeys().length; i++) {
      points.add(Point(x: i + 10, y: i + 10));
    }
  }

  int counter = -1;
  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < sp.getKeys().length; i++) {
      points.add(Point(x: i + 10, y: i + 10));
    }
    counter = -1;
    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext bc) => MakingProgress(
                              projectName: '',
                              viewing: false,
                            ))).then((value) {
                  print('am home');
                  setState(() {});
                });
              },
              label: Text("Add new Project"),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SvgPicture.asset(
              "svgs/btm.svg",
              fit: BoxFit.fill,
              height: MediaQuery.of(context).size.height * .2,
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .2),
                child: Wrap(
                  spacing: 40,
                  children: sp.getKeys().map((e) {
                    return Project(
                      projectName: e,
                      action: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext bc) => MakingProgress(
                                      projectName: e,
                                      viewing: true,
                                    ))).then((value) {
                          setState(() {});
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Project extends StatefulWidget {
  final projectName;
  final Function action;
  const Project({Key? key, required this.projectName, required this.action})
      : super(key: key);

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(widget.projectName, style: TextStyle(color: Colors.white)),
            SizedBox(
              height: 20,
            ),
            Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  calc(sp.getString(widget.projectName)!).toString() + '%',
                  style: TextStyle(color: Colors.white),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 255, 193, 59)),
                onPressed: () {
                  widget.action();
                },
                child: Text(
                  'View',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}

double calc(String data) {
  if (data.isEmpty) return 0;
  print(data);
  print(data.split(','));
  print(data.split(',').map((e) => e.split(':')));
  double num = data
      .split(',')
      .map((e) => e.split(':')[1])
      .where((element) => element == '1')
      .length
      .toDouble();
  return 100 * (num / data.split(',').length.toDouble());
}

class Point {
  double x;
  double y;
  Point({required this.x, required this.y});
}
