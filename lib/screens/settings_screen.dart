import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/static/currencies.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../size_config.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String lang = "";
  int dailyCigarattes;
  double pricePerCigaratte;
  String currency;
  TextEditingController controllerday;
  TextEditingController controllercost;

  @override
  void initState() {
    controllercost = TextEditingController();
    controllerday = TextEditingController();
    lang = getLang();
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    dailyCigarattes = pref.getInt("dailycigarattes");
    pricePerCigaratte = pref.getDouble("pricePerCigaratte");
    currency = pref.getString("currency");
    stopDate = DateTime.parse(pref.getString("startTime"));

    controllerday.text = dailyCigarattes.toString();
    controllercost.text = pricePerCigaratte.toString();
    setState(() {});
  }

  saveData() async {
    if (pricePerCigaratte == null ||
        dailyCigarattes == null ||
        currency == null) return false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("pricePerCigaratte", pricePerCigaratte);
    pref.setInt("dailycigarattes", dailyCigarattes);
    pref.setString("currency", currency);
    pref.setString("startTime", stopDate.toIso8601String());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //to avoid overflow
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: controllerday,
              onChanged: (value) => dailyCigarattes = int.parse(value),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: new InputDecoration(
                labelText: langs[lang]["welcome"]["howmanyperday"],
                fillColor: Color.fromARGB(255, 255, 255, 255),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),

                //fillColor: Colors.green
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(55),
            ),
            TextFormField(
              controller: controllercost,
              onChanged: (value) =>
                  pricePerCigaratte = double.parse(value.replaceAll(",", ".")),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: new InputDecoration(
                labelText: langs[lang]["welcome"]["howmuchpercigcost"],
                fillColor: Color.fromARGB(255, 255, 255, 255),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
                //fillColor: Colors.green
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(50),
            ),
            FittedBox(
              child: DropdownButton<String>(
                value: currency ?? null,
                hint: Text(
                  langs[lang]["welcome"]["choosecurrency"],
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: getProportionateScreenWidth(26)),
                ),
                items: currencyList.map((Map value) {
                  return DropdownMenuItem<String>(
                    value: value["symbol"],
                    child: new Text("${value["name"]} ${value["symbol"]}"),
                  );
                }).toList(),
                onChanged: (p) {
                  currency = p;
                  setState(() {});
                },
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(50), //bottomboxfromabove
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("${langs[lang]["settings"]["youstopped"]}"),
                    Text(
                      "${DateFormat.yMMMMEEEEd().format(stopDate)}\n${DateFormat.Hms().format(stopDate)}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                OutlineButton(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  onPressed: () => _pickDate(context),
                  child: Text(
                    "${langs[lang]["settings"]["change"]}",
                    textAlign: TextAlign.center,
                  ),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 113, 113, 113).withAlpha(200),
                      width: 2), //changebutton
                ),
              ],
            ),
            Expanded(
              child: Text(""),
            ),
            OutlineButton(
              padding: EdgeInsets.symmetric(horizontal: 50), //savebutton
              onPressed: () => saveData(),
              child: Text(langs[lang]["settings"]["save"]),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 113, 113, 113).withAlpha(200),
                  width: 2),
            )
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 240),
    );
  }

  DateTime stopDate;

  _pickDate(BuildContext context) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDate: stopDate,
    );

    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (date != null && t != null)
      setState(() {
        stopDate = date;
        print(t.hour);
        stopDate = stopDate.add(Duration(hours: t.hour, minutes: t.minute));
      });
    print(stopDate);
  }

  AppBar buildAppBar(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Hero(
              tag: "settings",
              child: Icon(
                Icons.settings,
                color: Color.fromARGB(255, 0, 0, 0),
                size: getProportionateScreenWidth(26),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "${langs[lang]["home"]["settings"]}",
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.black,
                  fontSize: getProportionateScreenWidth(26)),
            )
          ],
        ),
        backgroundColor: Color.fromARGB(255, 165, 165, 185));
  }
}
