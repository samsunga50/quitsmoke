import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/cigaratte.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/constants.dart';
import 'package:quitsmoke/screens/home_screen.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:alan_voice/alan_voice.dart';

import '../size_config.dart';

class WalletScreen extends StatefulWidget {
  final Cigaratte cigaratteManager;
  WalletScreen({Key key, this.cigaratteManager}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String lang = "en";
  Cigaratte cigaraManager;
  List<Transaction> trlist = [];
  final scaffoldState = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // Future<void> loadData() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();

  //   currency = pref.getString("currency");

  //  cigaraManager = Cigaratte(
  //      dailyCigarattes: pref.getInt("dailycigarattes"),
  //       pricePerCigaratte: pref.getDouble("pricePerCigaratte"),
  //     startDate: DateTime.parse(pref.getString("startTime")));
  // }

  double _amountofmoney = 0;
  String _tstitle = "";
  bool _sheetopen = false;
  bool _details = false;
  String currency = "";

  double get currentBalance {
    double m = 0;
    for (var k in trlist) m += k.price;
    return widget.cigaratteManager.getSavedMoney - m;
  }

  _getTransactions() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    currency = pref.getString("currency");
    var tr = jsonDecode((pref.getString("transactionData") ?? "[]"));
    for (var e in tr) {
      trlist.add(Transaction(
          price: e["price"],
          time: DateTime.parse(e["time"]),
          title: e["title"],
          description: e["description"] ?? ""));
    }
    setState(() {});
  }

  //dialogue box
  // showAlertDialog(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //  bool isFirstLoaded = prefs.getBool("");
  //  if (isFirstLoaded == null) {
  //    showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //        AlertDialog alert = AlertDialog();
  //      return AlertDialog(
  //         title: Text("Title: Reset Balance"),
  //      content: Text(
  //         "If you want to quit smoking, be honest with yourself first!"),
  //   actions: <Widget>[
  //     FlatButton(
  //       child: Text(
  //         "${langs[lang]["home"]["reset"]}",
  //        style: TextStyle(color: Colors.red),
  //      ),
  //     onPressed: () async {
  //      Navigator.of(context).pop();
  //     SharedPreferences pref =
  //         await SharedPreferences.getInstance();
  //     pref.setString(
  //          "startTime", DateTime.now().toIso8601String());
  //      loadData();
  //    },
  //  ),
  //     FlatButton(
  //    child: Text(
  //      "${langs[lang]["home"]["cancel"]}",
  //   ),
  //   onPressed: () {
  //    Navigator.of(context).pop();
  //   },
  //  ),
  //     ],
  //  );
  // show the dialog
  //          showDialog(
  //        context: context,
  //        builder: (BuildContext context) {
  //         return alert;
  //     },
  //   );
  //  });
  //  }
  // }

  _addTransaction(
      {DateTime date, double price, String title, String description}) {
    if (price > currentBalance) return;

    trlist.insert(
        0,
        Transaction(
            time: date, price: price, title: title, description: description));
    _saveTransaction();
    setState(() {});
  }

  _removeTransaction(int index) async {
    trlist.removeAt(index);
    _saveTransaction();
    setState(() {});
  }

  _saveTransaction() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<Map> lister = [];
    for (var k in trlist) {
      lister.add(k.toJson);
    }
    pref.setString("transactionData", jsonEncode(lister));
  }

  Timer statetimer;
  @override
  void initState() {
    // loadData();
    lang = getLang();
    super.initState();

    _getTransactions();
    statetimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    setupAlan();
  }

  setupAlan() {
    //adding alan ai button
    AlanVoice.addButton(
        "6a951295d713b86d68f0252cf4476c392e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    //Handling commands from ALan Studio
    AlanVoice.onCommand.add(((command) => _handleCommand(command.data)));
  }

  void _handleCommand(Map<String, dynamic> command) {
    switch (command["command"]) {
      case "details":
        _details = !_details;
        break;
      case "hide":
        !(_details = !_details);
        break;
      case "return":
        Navigator.of(context).pop();
        break;
      default:
        debugPrint("Unknown Command");
        break;
    }
  }

  @override
  void dispose() {
    statetimer.cancel();
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String _tsdescription;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldState,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Row(
          children: [
            FloatingActionButton(
              onPressed: () {
                if (!_sheetopen)
                  scaffoldState.currentState.showBottomSheet((context) =>
                      Container(
                        padding: EdgeInsets.all(15),
                        /*wishcanvas*/
                        color: Color.fromARGB(255, 255, 255, 255),
                        height: getProportionateScreenHeight(340),
                        width: double.infinity,
                        child: Column(children: [
                          Text(
                            "${langs[lang]["wallet"]["newtransaction"]}",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    fontSize: getProportionateScreenWidth(22)),
                          ),
                          TextField(
                            controller: titleController,
                            onChanged: (value) => _tstitle = value,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "${langs[lang]["wallet"]["title"]}"),
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    fontSize: getProportionateScreenWidth(22)),
                          ),
                          TextField(
                            controller: descriptionController,
                            onChanged: (value) => _tsdescription = value,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "${langs[lang]["wallet"]["description"]}"),
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    fontSize: getProportionateScreenWidth(22)),
                          ),
                          TextField(
                            controller: amountController,
                            onChanged: (value) =>
                                _amountofmoney = double.parse(value),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "${langs[lang]["wallet"]["amount"]}"),
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    fontSize: getProportionateScreenWidth(22)),
                          ),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                                padding: EdgeInsets.all(8)),
                            child: Text("${langs[lang]["wallet"]["add"]}"),
                            onPressed: () {
                              _sheetopen = false;
                              _addTransaction(
                                  date: DateTime.now(),
                                  price: _amountofmoney,
                                  title: _tstitle,
                                  description: _tsdescription);
                              Navigator.pop(context);
                            },
                          )
                        ]),
                      ));
                else
                  Navigator.pop(context);
                _sheetopen = !_sheetopen;
              },
              child: Icon(Icons.add,
                  color: Color.fromARGB(255, 0, 0, 0)), //tochange
            ),
          ],
        ),
      ),

      appBar: buildAppBar(context),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _details ? 1 : 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${langs[lang]["wallet"]["balance"]}",
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Color.fromARGB(255, 255, 255, 255)
                            .withAlpha(240), //balancecolor
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AutoSizeText(
                      "${NumberFormat.currency(symbol: currency).format(currentBalance)}",
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Color.fromARGB(
                              255, 255, 255, 255), //currencycolor
                          fontSize: getProportionateScreenWidth(42)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                  _details
                      ? Column(
                          children: [
                            Text(
                              "${langs[lang]["wallet"]["daily"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      color: Color.fromARGB(
                                              255, 255, 255, 255) //daily
                                          .withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["weekly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 7} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      color: Color.fromARGB(
                                              255, 255, 255, 255) //weekly
                                          .withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["monthly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 30} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      color:
                                          Colors.white.withAlpha(200), //monthly
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["yearly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 365} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      color:
                                          Colors.white.withAlpha(200), //yearly
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  // RaisedButton(onPressed: () {}),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //drop down icon button
                          IconButton(
                            icon: Icon(
                              _details
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              size: getProportionateScreenWidth(
                                  50), //dropdownarrow
                            ),
                            onPressed: () {
                              _details = !_details; //details under arrow
                              setState(() {});
                            },
                          ),
                          //    IconButton(
                          //    icon: Icon(
                          //      Icons.settings_backup_restore,
                          //      size: getProportionateScreenWidth(32),
                          //      color: Color.fromARGB(255, 255, 255, 255),
                          //    ),
                          // onPressed: () => showAlertDialog(context),
                          //      ),
                        ]),
                  )
                ],
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(30), //topcanvasheight
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color:
                        Color.fromARGB(255, 237, 237, 237), //bottomcanvascolor
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(
                          color: kShadowColor.withOpacity(.5),
                          blurRadius: 7,
                          offset: Offset(0, -3))
                    ]),
                child: ListView.builder(
                  itemCount: trlist.length,
                  itemBuilder: (context, index) {
                    final item = trlist[index];
                    print(item);
                    return Dismissible(
                      key: Key(item.time.toIso8601String()),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("${langs[lang]["misc"]["confirm"]}"),
                              content: Text(
                                  "${langs[lang]["misc"]["areusuredelete"]}"),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      "${langs[lang]["misc"]["delete"]}",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    )),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child:
                                      Text("${langs[lang]["misc"]["cancel"]}"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color.fromARGB(255, 255, 255, 255)),
                        child: Center(
                            child: Text(
                          "DELETE",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: getProportionateScreenWidth(32)),
                        )),
                      ),
                      onDismissed: (direction) {
                        _removeTransaction(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaction removed')));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(
                                255, 113, 130, 255), //smalltransactionbox
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: kShadowColor.withOpacity(.5),
                                  blurRadius: 7,
                                  offset: Offset(3, 3))
                            ]),
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(
                                          color: Color.fromARGB(
                                              255, 0, 0, 0), //title
                                          fontSize:
                                              getProportionateScreenWidth(30)),
                                ),
                                if (item.description != null &&
                                    item.description != "" &&
                                    item.description.length > 2)
                                  Text(
                                    item.description ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                            color: Color.fromARGB(
                                                255, 0, 0, 0), //description
                                            fontSize:
                                                getProportionateScreenWidth(
                                                    20)),
                                  ),
                                Text(
                                  DateFormat.yMMMMEEEEd().format(item.time),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(
                                          color: Color.fromARGB(
                                              179, 0, 0, 0), //date
                                          fontSize:
                                              getProportionateScreenWidth(16)),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                child: Text(
                                  "${NumberFormat.currency(symbol: currency).format(item.price)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255), //money
                                          fontSize:
                                              getProportionateScreenWidth(25)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),

      backgroundColor: Color.fromARGB(255, 59, 59, 224), //topcanvas color
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255)), //backarrow
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: "wallet",
            child: Icon(
              Icons.account_balance_wallet,
              color: Color.fromARGB(255, 255, 255, 255), //walleticoncolor
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["wallet"]}",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Color.fromARGB(255, 255, 255, 255), //pagetitle
                fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }
}

class Transaction {
  final double price;
  final DateTime time;
  final String title;
  final String description;
  get toJson =>
      {"price": price, "time": time.toIso8601String(), "title": title};
  Transaction({this.price, this.time, this.title, this.description = ""});
}
