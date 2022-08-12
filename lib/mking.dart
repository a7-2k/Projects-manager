import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MakingProgress extends StatefulWidget {
  String projectName;
  final bool viewing;
  MakingProgress({Key? key, required this.viewing, required this.projectName})
      : super(key: key);

  @override
  State<MakingProgress> createState() => _MakingProgressState();
}

class _MakingProgressState extends State<MakingProgress> {
  var progress = <String>[];
  var controller = TextEditingController();
  var title = TextEditingController();
  var focus = FocusNode();
  var list = <Progress>[];
  late SharedPreferences sp;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.viewing) {
      update();
    } else {}
  }

  void update() {
    SharedPreferences.getInstance().then((value) {
      // print(value.getString(key));
      sp = value;
      list = ((value)
          .getString(widget.projectName)!
          .split(',')
          .map((e) => Progress(
              name: e.split(':')[0],
              state: e.split(':')[1] == '0' ? false : true))
          .toList());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * .8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: title,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: widget.viewing
                            ? 'rename project'
                            : "project's name"),
                    onSubmitted: (value) {
                      if (widget.viewing && value.isNotEmpty) {
                        sp.setString(value, sp.getString(widget.projectName)!);
                        sp.remove(widget.projectName);
                        widget.projectName = value;
                        setState(() {});
                      }
                    },
                  ),
                )),
            SizedBox(
              width: MediaQuery.of(context).size.width * .7,
              child: TextField(
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    focus.requestFocus();
                    controller.clear();

                    if (!widget.viewing) {
                      progress.add(value);
                      setState(() {});
                    } else {
                      list.add(Progress(name: value, state: false));
                      sp.setString(
                          widget.projectName,
                          list
                              .map((e) =>
                                  "${e.name}:${e.state == false ? '0' : '1'}")
                              .join(','));
                      update();
                    }
                  }
                },
                controller: controller,
                focusNode: focus,
                decoration: InputDecoration(
                  hintText: 'Sub process',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .7,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.viewing ? list.length : progress.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        // mainAxisSize: MainAxisSize.min,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: widget.viewing
                                      ? (list[i].state
                                          ? Colors.green
                                          : Colors.blue)
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Wrap(
                                children: [
                                  Text(
                                    (widget.viewing
                                        ? list[i].name
                                        : progress[i]),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 26),
                                  ),
                                  if (widget.viewing)
                                    IconButton(
                                        onPressed: () {
                                          list[i].state = !list[i].state;
                                          sp.setString(
                                              widget.projectName,
                                              list
                                                  .map((e) =>
                                                      "${e.name}:${e.state == false ? '0' : '1'}")
                                                  .join(','));

                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.check,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                        )),
                                  Padding(padding: EdgeInsets.all(8)),
                                  IconButton(
                                      onPressed: () {
                                        if (widget.viewing) {
                                          if (list.length < 2) return;

                                          list.remove(list[i]);
                                          sp.setString(
                                              widget.projectName,
                                              list
                                                  .map((e) =>
                                                      "${e.name}:${e.state == false ? '0' : '1'}")
                                                  .join(','));

                                          update();
                                        } else {
                                          progress.remove(progress[i]);
                                          setState(() {});
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ))
                                ],
                              ))
                        ],
                      ),
                    );
                  }),
            ),
            if (widget.viewing)
              Container()
            else
              ElevatedButton(
                  onPressed: () async {
                    if (progress.isNotEmpty && title.text.isNotEmpty) {
                      final sp = await SharedPreferences.getInstance();
                      if (sp.getString(title.text) == null) {
                        sp.setString(
                            title.text, progress.map((e) => '$e:0').join(','));
                        Navigator.pop(context);
                      }
                    } else {}
                  },
                  child: Text('submit'))
          ],
        ),
      ),
    );
  }
}

class Progress {
  final String name;
  var state;
  Progress({required this.name, required this.state});
}
