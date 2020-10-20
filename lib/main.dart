import 'package:flutter/material.dart';
import 'package:kids_quiz_questions/models/contact.dart';
import 'package:kids_quiz_questions/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite CRUD',
      theme: ThemeData(
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form'),
      ),
      body: Container(
        color: Colors.grey[300],
        child: ContactForm(),
      ),
    );
  }
}

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper _dbHelper;

  final _formKey = GlobalKey<FormState>();
  // for editing
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
      _refreshContactList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _ctrlName,
              decoration: InputDecoration(
                labelText: 'Full Name',
              ),
              onSaved: (val) {
                setState(() {
                  _contact.name = val;
                });
              },
              validator: (val) {
                if (val.isEmpty) {
                  return 'Full Name is required.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ctrlMobile,
              decoration: InputDecoration(
                labelText: 'Mobile',
              ),
              keyboardType: TextInputType.phone,
              onSaved: (val) {
                setState(() {
                  _contact.mobile = val;
                });
              },
              validator: (val) {
                if (val.isEmpty) {
                  return 'Mobile is required.';
                }
                if (val.length < 10 || val.length > 10) {
                  return 'Mobile should have 10 characters';
                }
                return null;
              },
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: RaisedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () => _onSubmit(),
              ),
            ),
            _list(),
          ],
        ),
      ),
    );
  }

  _refreshContactList() async {
    List<Contact> x = await _dbHelper.fetchContact();
    setState(() {
      _contacts = x;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      // setState(() {
      //   // we can use _contact object but it leads to duplicate so, Model Contact(property:value)
      //   _contacts.add(
      //     Contact(id: null, name: _contact.name, mobile: _contact.mobile),
      //   );
      // });
      if (_contact.id == null) {
        // insert operation
        await _dbHelper.insertContact(_contact); //save to sqlite db
      } else {
        // update operation
        await _dbHelper.updateContact(_contact);
      }
      _refreshContactList();
      // form.reset();
      _resetForm();
      // print('Name ${_contact.name}');
      // print('Contact ${_contact.mobile}');
      // print(_contacts.length);
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
        child: Card(
          color: Colors.blue[50],
          margin: EdgeInsets.all(10),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: Text(
                      _contacts[index].name.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_contacts[index].mobile),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_sweep,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        await _dbHelper.deleteContact(_contacts[index].id);
                        _resetForm();
                        _refreshContactList();
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _contact = _contacts[index];
                        _ctrlMobile.text = _contacts[index].mobile;
                        _ctrlName.text = _contacts[index].name;
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                    color: Colors.blue[900],
                  )
                ],
              );
            },
            itemCount: _contacts.length,
          ),
        ),
      );
}
