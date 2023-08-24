import 'dart:convert';

import 'package:e_ticket_booking/Pages/OpenTicket.dart';
import 'package:e_ticket_booking/Pages/userBanner.dart';
import 'package:e_ticket_booking/services/downloadFileService.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../constants/Theme.dart';
class ClientHODDashboard extends StatefulWidget {
  const ClientHODDashboard({Key? key , required this.userinfo , required this.graph , required this.reports}) : super(key: key);
  final Map userinfo;
  final Map graph;
  final Map reports;
  @override
  State<ClientHODDashboard> createState() => _ClientHODDashboardState();
}

class _ClientHODDashboardState extends State<ClientHODDashboard> {

  late DateTime _selectedDate1 = DateTime(2021) ;
  late DateTime _selectedDate2 = DateTime.now();
  Map graphdata = {};
  List<PieChartSectionData>? data;

  List<dynamic> items = [];
  List<dynamic> tickets = [];
  List<dynamic> mainticket = [];
  String _selectedItem = '';
  String _selectedStatus = '';
  void showGraphAlert(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text("Graph Data Insights"),
        content: Container(
          height: 70,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(graphdata['solved'].toString()  , style: TextStyle(color: ArgonColors.text , fontSize: 17),),
                  SizedBox(width: 6,),
                  Text(' Solved Tickets' , style: TextStyle(color: ArgonColors.success , fontSize: 17),)
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Text(graphdata['unsolved'].toString()  , style: TextStyle(color: ArgonColors.text , fontSize: 17),),
                  SizedBox(width: 6,),
                  Text(' UnSolved Tickets' , style: TextStyle(color: ArgonColors.error , fontSize: 17 , overflow: TextOverflow.ellipsis),maxLines: 1,)
                ],
              )
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  void calculategraph(){
    try {
      graphdata['solved'] = widget.graph['result'][0]['solved'];
      graphdata['unsolved'] = widget.graph['result'][0]['unsolved'];
      var total = graphdata['solved'] + graphdata['unsolved'];
      var solvedper = num.parse(
          ((graphdata['solved'] / total) * 100).toStringAsFixed(0));
      var unsolvedper = num.parse(
          ((graphdata['unsolved'] / total) * 100).toStringAsFixed(0));

      print(graphdata);
      data = [
        PieChartSectionData(
            value: graphdata['unsolved'] != null ? double.parse(
                graphdata['unsolved'].toString()) : 0.0,
            color: ArgonColors.secondarygreen,
            radius: 40,
            showTitle: false,
            // titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: Text(unsolvedper.toString() + '%', style: TextStyle(
                color: ArgonColors.white, fontWeight: FontWeight.bold),)
        ),
        PieChartSectionData(
            value: graphdata['solved'] != null ? double.parse(
                graphdata['solved'].toString()) : 0.0,
            color: ArgonColors.darkgreen,
            showTitle: false,
            radius: 40,
            // titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ArgonColors.text,
            // ),
            badgeWidget: Text(solvedper.toString() + '%', style: TextStyle(
                color: ArgonColors.white, fontWeight: FontWeight.bold),)
        ),

      ];
    }catch(e){}
  }

  void assignTickets(){
    try {
      tickets = jsonDecode(jsonEncode(widget.reports['result']));
      tickets.sort((a,b) {
        var adate = a['created_time'];
        var bdate = b['created_time'];
        return bdate.compareTo(adate);
      });
      mainticket = jsonDecode(jsonEncode(widget.reports['result']));
    }catch(e){}
  }
  bool isDateInRange(DateTime dateToCheck, DateTime startDate, DateTime endDate) {
    return dateToCheck.isAfter(startDate) && dateToCheck.isBefore(endDate);
  }
  void filterReports(){
    List currentlist = mainticket;
    if(_selectedItem !=''){
      setState(() {
        currentlist = currentlist.map((e) {
          if(e['client_id'].toString() == _selectedItem){
            return e;
          }
        }).toList();
        currentlist.removeWhere((element) => element == null);
        print(tickets);
        setState(() {
          tickets = currentlist;
          tickets.sort((a,b) {
            var adate = a['created_time'];
            var bdate = b['created_time'];
            return bdate.compareTo(adate);
          });
        });
      });
    }
    if(_selectedStatus != ''){
      setState(() {
        currentlist = currentlist.map((e) {
          if(e['ticket_state'].toString() == _selectedStatus){
            return e;
          }
        }).toList();
        currentlist.removeWhere((element) => element == null);
      });
      setState(() {
        tickets = currentlist;
        tickets.sort((a,b) {
          var adate = a['created_time'];
          var bdate = b['created_time'];
          return bdate.compareTo(adate);
        });
      });
    }
    if(_selectedDate1!=null && _selectedDate2!=null){
      setState(() {


        currentlist = currentlist.map((e) {
          print(DateTime.parse(e['created_time'].toString()));
          if(isDateInRange(DateTime.parse(e['created_time'].toString()), _selectedDate1, _selectedDate2)){
            return e;
          }
        }).toList();

        currentlist.removeWhere((element) => element == null);

      });
      setState(() {
        tickets = currentlist;
        tickets.sort((a,b) {
          var adate = a['created_time'];
          var bdate = b['created_time'];
          return bdate.compareTo(adate);
        });
      });
    }


  }
  @override
  void initState() {
    print(widget.reports);
    setState(() {


      calculategraph();

      assignTickets();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // UserBanner(userinfo: widget.userinfo),
          Row(

            children: [

              Container(
                padding: EdgeInsets.only(left: 10),
                // decoration: BoxDecoration(color: Colors.black),
                width: MediaQuery.of(context).size.width / 2,
                height: 220,
                child: InkWell(
                  onTap: showGraphAlert,
                  child: PieChart(
                    PieChartData(
                      sections: data,
                      centerSpaceRadius: 44,
                      sectionsSpace: 0,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                      // sectionsTextStyle: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: showGraphAlert,
                child: Container(
                  width: MediaQuery. of(context). size. width  / 2,
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(color: ArgonColors.darkgreen),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Solved Tickets' , style: TextStyle( color: ArgonColors.text , fontSize: 15),),
                          )
                        ],

                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(color: ArgonColors.secondarygreen),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Unsolved Tickets' , style: TextStyle( color: ArgonColors.text , fontSize: 15 , overflow: TextOverflow.fade),maxLines: 1,),
                          )
                        ],

                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          // Text('Clent Wise Dashboard' ,
          //   style: TextStyle(
          //       color: ArgonColors.text,
          //       fontSize: 25
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(4.0),
          //   child: Container(
          //     width: MediaQuery. of(context). size. width ,
          //     height: 67,
          //     child: Card(
          //       color: ArgonColors.darkgreen,
          //       elevation: 3,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //
          //           Container(
          //             width: MediaQuery.of(context).size.width/2.5,
          //             child: Padding(padding: EdgeInsets.all(8),
          //                 child:Text('Client', style: TextStyle(  color: ArgonColors.white   , fontWeight: FontWeight.w700),textAlign: TextAlign.center,)
          //             ),
          //           ),
          //
          //           Container(
          //             width: MediaQuery.of(context).size.width / 4,
          //             child: Padding(padding: EdgeInsets.all(8),
          //                 child:Text('Opened Tickets', textAlign:TextAlign.center,style: TextStyle( fontSize: 13.8, color: ArgonColors.white   , fontWeight: FontWeight.w700),)
          //             ),
          //           ),
          //           Container(
          //             width: MediaQuery.of(context).size.width / 4,
          //             child: Padding(padding: EdgeInsets.all(8),
          //                 child:Text('Closed Tickets', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.8, color: ArgonColors.white  , fontWeight: FontWeight.w700),)
          //             ),
          //           ),
          //
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 5.0),
          //   child: Column(
          //     children: [
          //       Container(
          //         constraints:BoxConstraints(
          //             maxHeight: MediaQuery.of(context).size.height /3.45
          //         ),
          //         child: items.length!=0?ListView(
          //             scrollDirection: Axis.vertical,
          //             shrinkWrap: true,
          //             children: items.map((e) => makecards(data: e,),).toList()
          //
          //         ):Padding(padding: EdgeInsets.all(8),
          //           child: Center(
          //             child: Text('No Client Found' , style: TextStyle(color: ArgonColors.text , fontSize: 20),),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Reports' ,
                style: TextStyle(
                    color: ArgonColors.text,
                    fontSize: 25
                ),
              ),

            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(

                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(padding: EdgeInsets.only(left: 5),
                            child: Container(
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: DropdownButton<String>(
                                    value: _selectedStatus.isNotEmpty?_selectedStatus:null,
                                    hint: Text('Ticket Status' , style: TextStyle(color: ArgonColors.text , fontSize: 16),),
                                    // dropdownColor: ArgonColors.darkgreen,
                                    // value: _selectedItem.isNotEmpty ? _selectedItem : null,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(color: ArgonColors.text),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                    onChanged: (String? newValue) {

                                      _selectedStatus = newValue!.toString();
                                      filterReports();

                                      setState(() {

                                      });
                                    },
                                    items: <String>['Open' , 'Pending' , 'Closed']
                                        .map<DropdownMenuItem<String>>(( value) {
                                      return DropdownMenuItem<String>(
                                        value: value.toLowerCase(),
                                        child: Text(value, style: TextStyle(color: ArgonColors.text , fontSize: 17),),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding:
                            const EdgeInsets.only(left: 0, right: 0, top: 8 , bottom: 8),
                            child: RaisedButton(
                              textColor: ArgonColors.white,
                              color: ArgonColors.white,
                              onPressed: () async {
                                await DownloadService().downloadFile(username: widget.userinfo['name'].toString(), data: tickets, id:widget.userinfo['id'].toString(), context: context);
                                // Map response = await MessageService().GetMsg(id: ticket_data['ticket_id']);


                                // Navigator.push<dynamic>(
                                //   context,
                                //   MaterialPageRoute<dynamic>(
                                //     builder: (BuildContext context) => Messagehome(ticketinfo: ticket_data, solutions: response, userinfo: widget.userinfo,),
                                //   ),
                                // );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 0, right: 0, top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.download , color: ArgonColors.text,),

                                    ],
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Row(
                      children: [Text('From'),
                        Padding(padding: EdgeInsets.all(0),
                          child: IconButton(
                            onPressed: _showDatePicker, icon: Icon(Icons.calendar_month_outlined , color: ArgonColors.text,), // Call the method to show the date picker
                          ),
                        ),
                        Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(_selectedDate1.toString())) , style: TextStyle(fontSize: 13)),
                      ],
                    )),
                    Expanded(child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('To'),
                        Padding(padding: EdgeInsets.all(0),
                          child: IconButton(
                            onPressed: _showDatePicker2, icon: Icon(Icons.calendar_month_outlined , color: ArgonColors.text,), // Call the method to show the date picker
                          ),

                        ),
                        Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(_selectedDate2.toString())) , style: TextStyle(fontSize: 13)),
                      ],
                    ))
                  ],
                ),
              )
            ],
          ),
          tickets.length!=0?ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: tickets.map((e) => makereportstiles(data: e)).toList()

          ):Padding(padding: EdgeInsets.all(8),
            child: Center(
              child: Text('No Tickets Found' , style: TextStyle(color: ArgonColors.text , fontSize: 20),),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }





  Widget makecards({required Map data}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Container(
      width: MediaQuery. of(context). size. width ,
      height: 60,
      child: Card(
        color: ArgonColors.white,
        elevation: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            Container(
                width: MediaQuery. of(context). size. width /2.5,
                padding: EdgeInsets.all(0),
                child:Text(data['name'], style: TextStyle( color: ArgonColors.text   , fontWeight: FontWeight.w700  ,),textAlign: TextAlign.center, maxLines: 1,)
            ),
            Container(
                width: MediaQuery. of(context). size. width /4,
                padding: EdgeInsets.only(left: 10),
                child:Text(data['open'].toString(), style: TextStyle( color: ArgonColors.text   , fontWeight: FontWeight.w700),textAlign: TextAlign.center, maxLines: 1,)
            ),
            Container(
                width: MediaQuery. of(context). size. width /4,
                padding: EdgeInsets.all(0),
                child:Text(data['closed'].toString(), style: TextStyle( color: ArgonColors.text   , fontWeight: FontWeight.w700),textAlign: TextAlign.center,maxLines: 1,)
            ),

          ],
        ),
      ),
    ),
  );
  //date
  void _showDatePicker()  async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      currentDate: _selectedDate1,
      selectableDayPredicate: (DateTime date){
        return true;
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: ArgonColors.darkgreen, // Change the header background color
            accentColor: ArgonColors.darkgreen, // Change the selection color
            colorScheme: ColorScheme.light(
              primary: ArgonColors.darkgreen, // Change the text color
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Change the button text color
            ),
          ),
          child: child as Widget,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate1 = pickedDate;
        filterReports();
      });
    }
  }
  void _showDatePicker2()  async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      currentDate: _selectedDate2,
      selectableDayPredicate: (DateTime date){
        return true;
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: ArgonColors.darkgreen, // Change the header background color
            accentColor: ArgonColors.darkgreen, // Change the selection color
            colorScheme: ColorScheme.light(
              primary: ArgonColors.darkgreen, // Change the text color
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Change the button text color
            ),
          ),
          child: child as Widget,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate2 = pickedDate;
        filterReports();
      });
    }
  }
  Widget makereportstiles({required Map data}) => InkWell(
    onTap: ()
    {

        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => OpenTicket(data: data, userinfo: widget.userinfo,),
          ),
        );

    },
    child: Container(

      height: 90, // Adjust the height according to your requirement

      margin: EdgeInsets.symmetric(horizontal: 8),

      child: Card(

        elevation: 4,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(8),

        ),

        child: Row(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Container(
              width: 10,
              height: double.infinity,
              decoration: BoxDecoration(
                  color: data['ticket_state']=="closed"?ArgonColors.success:(data['ticket_state']=="panding"?Colors.amber:ArgonColors.pending),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8) ,bottomLeft: Radius.circular(8) )
              ),
            ),
            SizedBox(width: 15),



            Expanded(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Container(
                    width:MediaQuery.of(context).size.width / 1.5,
                    child: Text(

                      // data['name'].toString() ,
                      data['subject'],
                      style: TextStyle(
                        color: ArgonColors.text,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,

                        // fontWeight: FontWeight.bold,

                      ),
                      maxLines: 1,

                    ),
                  ),

                  SizedBox(height: 8),

                  Text(

                    'Ticket No: ' + data['ticket_id'].toString(),

                    style: TextStyle(fontSize: 14 , color: ArgonColors.text , overflow: TextOverflow.ellipsis ,fontWeight: FontWeight.bold),maxLines: 1,

                  ),

                ],

              ),

            ),

            SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['unitname']!=null?data['unitname']:'' , style: TextStyle(color: ArgonColors.text , fontWeight: FontWeight.bold),),
                  Padding(padding: EdgeInsets.only(top: 4),
                      child:Text( data['ticket_state'],
                        style: TextStyle( color: data['ticket_state']=='open'?ArgonColors.pending:ArgonColors.success , fontSize: 14  , fontWeight: FontWeight.w500),)
                  ),
                ],
              ),
            ),

          ],

        ),

      ),

    ),
  );

}