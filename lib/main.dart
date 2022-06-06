import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:developer';

void main() {
  runApp(const MyApp());
  inspect(PhoneDatabase.getPhones());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: Colors.amber,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Phone> _phoneList;
  bool _isLoadingData = true;

  void _loadPhoneList() async {
    final phoneList = await PhoneDatabase.getPhones();
    setState(() {
      _phoneList = phoneList;
      _isLoadingData = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPhoneList();
  }

  Widget _buildPhoneList() {
    return ListView.builder(
      itemCount: _phoneList.length,
      itemBuilder: (context, i) => Card(
        color: Colors.purple,
        margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: ListTile(
          title: Text(_phoneList[i].name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Database'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _buildPhoneList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _insertPhoneDebug(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  final TextEditingController _phoneNameFieldController =
      TextEditingController();

  _insertPhoneDebug(int? phoneId) {
    PhoneDatabase.insertPhone(Phone(
        id: 0,
        name: "name",
        model: "model",
        manufacturer: "manufacturer",
        softwareVersion: "softwareVersion",
        phoneAvatar: "phoneAvatar"));
    _loadPhoneList();
    build(context);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
