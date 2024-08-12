import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_one/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:  HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String,dynamic>> _journals = [];

  bool _isLoading = true;

  void _refreshJournals() async{
    final data = await SqlHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }


  @override

  Future<void> _addItem()async{
    await SqlHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
    print("..number of items ${_journals.length}");
  }

  Future<void> _updateItem (int id) async {
    await SqlHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void initState(){
    super.initState();
    _refreshJournals();
    print("..number of items ${_journals.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();



  void _deleteItem(int id) async{
    await SqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  void  _showForm(int? id) async {
    if (id != null){

      final existingJournal=
          _journals.firstWhere((element) => element['id']==id);
      _titleController.text = existingJournal ['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=> Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,

            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                width: 40.0,
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title'
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description'
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async{
                    if(id==null){
                      await _addItem();
                    }
                    if(id != null){
                      await _updateItem(id);
                    }

                    _titleController.text = ' ';
                    _descriptionController.text = ' ';

                    Navigator.of(context).pop();
                  },
                  child: Text(id== null ? 'Create New':'Update'),
              )
            ],
          ),
        )
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text(
            "SQL",
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.black
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context,index)=> Card(
            color: Colors.orange,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              // onTap: (){
              //   Navigator.push(
              //       context, MaterialPageRoute(
              //       builder: (context) =>const branchDetails() ));
              // },
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing:  SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          _showForm(_journals[index]['id']);
                        },
                        icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                        onPressed: (){
                          _deleteItem(_journals[index]['id']);
                        },
                        icon:const Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.teal,
        onPressed: (){
          _showForm(null);
        },
      ),
    );
  }
}


