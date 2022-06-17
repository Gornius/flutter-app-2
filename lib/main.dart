import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
      itemBuilder: (context, i) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneEditPage(
                phone: _phoneList[i],
              ),
            ),
          ).then((value) {
            _loadPhoneList();
            build(context);
          });
        },
        child: Card(
          color: Colors.purple,
          margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: ListTile(
            title: Text(_phoneList[i].name),
          ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_reset_db",
            onPressed: () {
              PhoneDatabase.resetDatabase();
              _loadPhoneList();
              build(context);
            },
            child: const Icon(Icons.restore),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            //onPressed: () => _insertPhoneDebug(null),
            heroTag: "btn_add_record",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneEditPage(phone: null),
                ),
              ).then((value) {
                _loadPhoneList();
                build(context);
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class PhoneEditPage extends StatefulWidget {
  const PhoneEditPage({Key? key, required this.phone}) : super(key: key);
  final Phone? phone;

  @override
  State<PhoneEditPage> createState() => _PhoneEditPageState();
}

class _PhoneEditPageState extends State<PhoneEditPage> {
  final formKey = GlobalKey<FormState>();
  // final phoneManufacturerKey = GlobalKey<FormFieldState>();
  // final phoneModelKey = GlobalKey<FormFieldState>();
  // final phoneSoftwareVersionKey = GlobalKey<FormFieldState>();
  late TextEditingController _manufacturerController;
  late TextEditingController _modelController;
  late TextEditingController _softwareVersionController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.phone?.phoneAvatar != "") {
      _imagePath = widget.phone?.phoneAvatar;
    }
    _manufacturerController =
        TextEditingController(text: widget.phone?.manufacturer);
    _modelController = TextEditingController(text: widget.phone?.model);
    _softwareVersionController =
        TextEditingController(text: widget.phone?.softwareVersion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.phone == null)
            ? const Text("Add record")
            : const Text("Edit record"),
      ),
      floatingActionButton: (widget.phone == null)
          ? Column()
          : FloatingActionButton(
              child: const Icon(Icons.delete),
              onPressed: () {
                PhoneDatabase.deletePhone(widget.phone!);
                Navigator.pop(context);
              },
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  // key: phoneManufacturerKey,
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    label: Text("Phone Manufacturer"),
                  ),
                  validator: (value) {
                    if (value != "") {
                      return null;
                    } else {
                      return "Phone manufacturer must not be empty";
                    }
                  },
                ),
                TextFormField(
                  //key: phoneModelKey,
                  controller: _modelController,
                  decoration: const InputDecoration(
                    label: Text("Phone model"),
                  ),
                  validator: (value) {
                    if (value != "") {
                      return null;
                    } else {
                      return "Phone model must not be empty";
                    }
                  },
                ),
                TextFormField(
                  // key: phoneSoftwareVersionKey,
                  controller: _softwareVersionController,
                  decoration: const InputDecoration(
                    label: Text("Software version"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (_imagePath == null
                      ? Container()
                      : Image.file(
                          File(_imagePath!),
                          height: MediaQuery.of(context).size.height * 0.5,
                        )),
                ),
                ElevatedButton(
                  child: const Text("Pick Avatar"),
                  onPressed: () async {
                    var pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      final String path =
                          (await getApplicationDocumentsDirectory()).path +
                              "/" +
                              pickedFile.name;
                      await pickedFile.saveTo(path);
                      setState(() {
                        _imagePath = path;
                      });
                      print("--------- $path");
                    }
                  },
                ),
                ElevatedButton(
                    child: const Text("Save"),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (widget.phone?.id == null) {
                          PhoneDatabase.insertPhone(Phone(
                              id: widget.phone?.id ?? 0,
                              name:
                                  "${_manufacturerController.text} ${_modelController.text}",
                              model: _modelController.text,
                              manufacturer: _manufacturerController.text,
                              softwareVersion: _softwareVersionController.text,
                              //phoneAvatar: _imageFile.toString()));
                              phoneAvatar: _imagePath ?? ""));
                          Navigator.pop(context);
                        } else {
                          PhoneDatabase.modifyPhone(Phone(
                              id: widget.phone!.id,
                              name:
                                  "${_manufacturerController.text} ${_modelController.text}",
                              model: _modelController.text,
                              manufacturer: _manufacturerController.text,
                              softwareVersion: _softwareVersionController.text,
                              phoneAvatar: _imagePath ?? ""));
                          Navigator.pop(context);
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
