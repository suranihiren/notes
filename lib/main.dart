import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notesv/splash.dart';
import 'package:notesv/update.dart';
import 'package:sqflite/sqflite.dart';
import 'addnote.dart';
import 'dbclass.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: splash(),
  ));
}

class notes extends StatefulWidget {

  static SharedPreferences? preferences;

  const notes({Key? key}) : super(key: key);

  @override
  State<notes> createState() => _notesState();
}

class SharedPreferences {}

class _notesState extends State<notes> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    forviewdb();
  }

  forviewdb() {
    dbclass().getdb().then((value) {
      setState(() {
        db = value;
      });
      dbclass().viewdata(db!).then((value) {
        setState(() {
          details = value;
          searchlist = value;
        });
      });
    });
  }

  List<Map> notedata = [];
  Database? db;
  bool Issearch = false;
  Color current = Colors.orange;
  List<Map> details = [];
  List<Map> searchlist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Issearch
          ? AppBar(
              backgroundColor: Colors.white,
              title: TextField(
                onChanged: (value) {
                  print("===$value");

                  setState(() {
                    if (value.isNotEmpty) {
                      searchlist = [];
                      for (int u = 0; u < details.length; u++) {
                        String title = details[u]['TITLE'];
                        String contant = details[u]['CONTENT'];

                        if (title.toLowerCase().contains(value.toLowerCase()) ||
                            contant
                                .toString()
                                .toUpperCase()
                                .contains(value.toUpperCase())) {
                          searchlist.add(details[u]);
                        } else {}
                      }
                    } else {
                      searchlist = details;
                    }
                  });
                },
                autofocus: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.contact_mail_outlined),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            Issearch = false;
                            searchlist = details;
                          });
                        },
                        icon: Icon(Icons.close)),
                    border: OutlineInputBorder()),
              ),
            )
          : AppBar(
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        Issearch = true;
                      });
                    },
                    icon: Icon(Icons.search)),
              ],
            ),
      body: Container(
        child: GridView.builder(
            itemCount: Issearch ? searchlist.length : details.length,
            itemBuilder: (context, index) {
              int ss = details[index]['COLOR'];
              Map map = Issearch ? searchlist[index] : details[index];

              return AnimationLimiter(
                key: ValueKey("${details[index]}"),
                child: AnimationConfiguration.staggeredGrid(
                  columnCount: 2,
                  position: index,
                  child: ScaleAnimation(
                    delay: Duration(seconds: 5),
                    duration: Duration(seconds: 3),
                    child: FadeInAnimation(
                      delay: Duration(seconds: 5),
                      duration: Duration(seconds: 3),
                      child: Card(
                        color: Color(ss),
                        shadowColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        margin: EdgeInsets.all(15),
                        elevation: 20,
                        child: ListTile(
                          trailing: PopupMenuButton(onSelected: (value) {
                            if (value == 1) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                builder: (context) {
                                  return update(details[index]);
                                },
                              ));
                            }
                          }, itemBuilder: (context) {
                            return [
                              PopupMenuItem(value: 1, child: Text("Update")),
                              PopupMenuItem(
                                  value: 2,
                                  onTap: () {
                                    int idd = details[index]['ID'];
                                    print("====$idd");
                                    dbclass().delete(idd, db!).then((value) {
                                      forviewdb();
                                    });
                                  },
                                  child: Text("Delete"))
                            ];
                          }),
                          subtitle: Text("\n${map['TITLE']}"),
                          title: Text("${map['CONTENT']}"),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return addnote();
            },
          ));
        },
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
