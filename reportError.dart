import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:alert_dialog/alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pt_bisa/Report/Report.dart';
import 'package:pt_bisa/Report/reportrekapbonus.dart';
import 'package:pt_bisa/ui/datepicker.dart';
import 'package:pt_bisa/ui/navbar.dart';

import '../HomePage.dart';
import '../Login.dart';

class RekapBonus extends StatefulWidget {
  final User isi;
  const RekapBonus({Key key, this.isi}) : super(key: key);

  @override
  _RekapBonusState createState() => _RekapBonusState();
}

class _RekapBonusState extends State<RekapBonus> {
  String dropdownValue;
  DateTime time = new DateTime.now();
  DateTime tgl = new DateTime.now();
  void initstate(){
    super.initState();
    tgl = DateTime.now();
    time = DateTime.now();
  }

  _pickedDate() async { //datetime picker
    DateTime date = await pickedDate(time: time, context: context);
    if(date != null)
      setState(() {
        time = date;
      });
  }
  _pickedDateAkhir() async { //datetime picker
    DateTime date = await pickedDateAkhir(tgl: tgl, context: context);
    if(date != null)
      setState(() {
        tgl = date;
      });
  }
  bool _loading = false;
  String page = "Rekap Bonus";
  search()async{ // check to server
    try {
      var url = Uri.http('${widget.isi.ipServer}', '/api_bisa/api_bisa/rekap_bonus');
      final response = await http.post(url, body: {
        "start_date": "$time",
        "end_date": "$tgl",
        "userid": "$dropdownValue",
      }).timeout(Duration(seconds: 15));
      final data = jsonDecode(response.body);
      var statusApi = data['status'];
      var msgApi = data['message'];
      var str = jsonEncode(data['data']);
      var str2 = jsonEncode(data['data2']);

      if (statusApi == 1 && str != '[]' && str2 !='[]') { //sukses
        print(str);
        print(str2);
        setState(() => _loading = false);
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> Report(isi: User(
            userid: "${widget.isi.userid}",
            ipServer: "${widget.isi.ipServer}",
            internet1: "${widget.isi.internet1}",
            internet2: "${widget.isi.internet2}",
            idMember: "${widget.isi.idMember}",
            isiData: "$str2",
            page: "$page" )
        )));
      }else if(statusApi == 1 && str == '[]' && str2 != '[]'){
        setState(() => _loading = false);
        return alert(context, title: Text(msgApi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[850]), maxLines: 20,),);
      } else if (statusApi == 0) {
        print(msgApi);
        setState(() => _loading = false);
        return alert(context, title: Text(msgApi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[850]), maxLines: 20,),);
      } else {
        setState(() => _loading = false);
        throw (response.statusCode);
      }
    }on SocketException catch(_){
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Sorry, Failed Connect To Server", style: TextStyle(fontSize: 16),),
            actions: <Widget>[
              ElevatedButton(
                child: new Text("OK"),
                onPressed: () {
                  setState(() => _loading = false );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }on TimeoutException catch(_){
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Sorry, Failed Connect To Server. Try Some Time Later",style: TextStyle(fontSize: 16),),
            actions: <Widget>[
              ElevatedButton(
                child: new Text("OK"),
                onPressed: () {
                  setState(() => _loading = false );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  List statesList ;
  Widget _userId(){ //userid
    var member = jsonDecode("${widget.isi.idMember}");
    statesList = member;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: dropdownValue,
          iconSize: 30,
          icon: Icon(Icons.keyboard_arrow_down_outlined),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          underline: Container(
            height: 2,
            color: Colors.blue,
          ),
          hint: Text("Pilih User ID"),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
              print(dropdownValue);
            });
          },
          items: statesList?.map((item) {
            return new DropdownMenuItem(
              child: new Text(item['user_name']),
              value: item['mem_id'].toString(),
            );
          })?.toList() ??
              [],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF434f70),
        shadowColor: Colors.blue,
        title: Text("Rekap Bonus", style: TextStyle(color: Color(0xFFfbfbfb)),),
      ),
      body: StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
          builder: (BuildContext context,
              AsyncSnapshot<ConnectivityResult> snapshot) {
            if (snapshot != null && snapshot.data != ConnectivityResult.none){
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(
                            color: Colors.grey[300],
                            offset: Offset(1,1),
                            blurRadius: 5,
                          )],
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Tanggal Awal",style: TextStyle(fontSize: 16),),
                            ],
                          ),
                          Card(
                            color: Colors.blue[50],
                            shadowColor: Colors.blue,
                            child: ListTile(
                              title: Text("${DateFormat.yMMMd().format(time)}"),
                              trailing: Icon(Icons.date_range_outlined),
                              onTap: _pickedDate,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 20.0),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Tanggal Akhir"),
                            ],
                          ),
                          Card(
                            color: Colors.blue[50],
                            shadowColor: Colors.blue,
                            child: ListTile(
                              title: Text("${DateFormat.yMMMd().format(tgl)}"),
                              trailing: Icon(Icons.date_range_outlined),
                              onTap: _pickedDateAkhir,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 20.0),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("User ID :",style: TextStyle(fontSize: 16),),
                            ],
                          ),
                          _userId(),
                          new Padding(padding :new EdgeInsets.only(top: 10.0)),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                !_loading? ElevatedButton( //button login
                                  child: new Text("Search", style: TextStyle(fontSize: 18),),
                                  onPressed: (){
                                    search();
                                    setState(() => _loading = true);
                                  }, //onPressed:
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(Colors.white),
                                    backgroundColor: MaterialStateProperty.all(Color(0xFF434f70)),
                                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                                  ),
                                ): CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_outlined,
                      size: 50,
                      semanticLabel: 'Not Connection!',
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

      bottomNavigationBar: NavBar(),
    );
  }
}
