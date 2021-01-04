import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _taskList = [];
  Map<String, dynamic> _lastItemRemoved = Map();
  TextEditingController _controllerTask = TextEditingController();

  Future<File> _getFile() async {

    final directory = await getApplicationDocumentsDirectory();
    return File( "${directory.path}/data.json" );

  }

  _saveTask(){

    String textTyped = _controllerTask.text;

    //Create Data
    Map<String, dynamic> task = Map();
    task["title"] = textTyped;
    task["status"] = false;
    setState(() {
      _taskList.add( task );
    });
    _saveFile();
    _controllerTask.text = "";

  }

  _saveFile() async {

    var file = await _getFile();

    String data = json.encode( _taskList );
    file.writeAsString( data );

  }

  _readFile() async {

    try{

      final file = await _getFile();
      return file.readAsString();

    }catch(error){
      return null;
    }

  }

  @override
  void initState() {
    super.initState();

    _readFile().then( ( data ){
      setState(() {
        _taskList = json.decode( data );
      });
    } );

  }

  Widget createItemList(context, index){

    final item = _taskList[index]['title'] ;

    return Dismissible(
        key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
        direction: DismissDirection.endToStart,

        onDismissed: (direction){

          //get the last item removed
          _lastItemRemoved = _taskList[index];

          //Remove a list item
          _taskList.removeAt(index);
          _saveFile();

          //Snackbar
          final snackbar = SnackBar(
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            content: Text("Task removed!!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){

                  //Put the removed item in the list
                  setState(() {
                    _taskList.insert(index, _lastItemRemoved);
                  });
                  _saveFile();

                }
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);

        },

        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text( _taskList[index]['title'] ),
          value: _taskList[index]['status'],
          onChanged: (changedValue){
            setState(() {
              _taskList[index]['status'] = changedValue;
            });
            _saveFile();

          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    _saveFile();

    return Scaffold(
      appBar: AppBar(
        title: Text("Task List"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){

          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Add task"),
                  content: TextField(
                    controller: _controllerTask,
                    decoration: InputDecoration(
                      labelText: "Type your task"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel")
                    ),
                    FlatButton(
                        onPressed: () {
                          _saveTask();
                          Navigator.pop(context);
                        },
                        child: Text("Save")
                    )
                  ],
                );
              }
          );

        }
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _taskList.length,
              itemBuilder: createItemList
            ),
          )
        ],
      )
    );
  }
}
