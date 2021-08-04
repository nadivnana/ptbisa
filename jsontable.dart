import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import '../Login.dart';

class Report extends StatefulWidget {
  final User isi;
  const Report({Key key, this.isi}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  bool toggle = true;
  @override
  Widget build(BuildContext context) {
    var json = jsonDecode("${widget.isi.isiData}"); //isi data
    print(json);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFffffff),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('${widget.isi.page}', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF434f70),
        shadowColor: Colors.blue,
      ),
      body: StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
          builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
            if (snapshot != null && snapshot.data != ConnectivityResult.none){
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: toggle
                      ? Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 25)),
                      JsonTable( //json tabel
                        json,
                        showColumnToggle: false,
                        allowRowHighlight: true,
                        rowHighlightColor: Colors.blue[800].withOpacity(0.7),
                        paginationRowCount: 20,
                        onRowSelect: (index, map) {
                          print(index);
                          print(map);
                        },
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ) : Center(
                    child: Text(getPrettyJSONString("${widget.isi.isiData}"),
                    ),
                  ),
                ),
              );
            }else{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_outlined,
                      size: 50,
                    ),
                    Text("${widget.isi.internet1}",style: TextStyle(fontSize: 18),),
                    Text("${widget.isi.internet2}",style: TextStyle(fontSize: 18),),
                    /*Text("Oops! Not Internet Connection",style: TextStyle(fontSize: 18),),
                      Text("Please Check Your Internet Connection",style: TextStyle(fontSize: 18),),*/
                  ],
                ),
              );
            }
          }
      ),
    );
  }

  String getPrettyJSONString(jsonObject) {
    //JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    //String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonObject;
  }
}
