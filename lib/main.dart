import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/todo_model.dart';

const String todoBoxName = "todo";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ScreenHome()));
}

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

enum TodoFilter { ALL, COMPLETED, INCOMPLETED }

class _ScreenHomeState extends State<ScreenHome> {
  late Box<TodoModel> todoBox;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  @override
  void initState() {
    todoBox = Hive.box<TodoModel>(todoBoxName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ValueListenableBuilder(
                valueListenable: todoBox.listenable(),
                builder: (context, Box<TodoModel> todos, _) {
                  List<int> keys = todos.keys.cast<int>().toList();
                  return ListView.builder(
                    itemBuilder: ((context, index) {
                      final int key = keys[index];
                      final TodoModel? todo = todos.get(key);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              todo!.title.toString(),
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(todo.details.toString()),
                            trailing: Wrap(spacing: 0, children: [
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                decoration: InputDecoration(
                                                    hintText: "Enter to update title"),
                                                controller: titleController,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                decoration: InputDecoration(
                                                    hintText: "Enter to update details"),
                                                controller: detailController,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    final String title =
                                                        titleController.text;
                                                    final String details =
                                                        detailController.text;

                                                    TodoModel todo = TodoModel(
                                                        title: title,
                                                        details: details,
                                                        isCompleted: false);
                                                    todoBox.put(key, todo);
                                                    Navigator.pop(context);
                                                    titleController.clear();
                                                    detailController.clear();
                                                  },
                                                  child:
                                                      const Text("Edit Todo"))
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    todoBox.delete(key);
                                  },
                                  icon: Icon(Icons.delete)),
                            ]),
                          ),
                        ),
                      );
                    }),
                    // separatorBuilder: ((context, index) => Divider()),
                    itemCount: keys.length,
                    shrinkWrap: true,
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: "Title"),
                      controller: titleController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Details"),
                      controller: detailController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          final String title = titleController.text;
                          final String details = detailController.text;

                          TodoModel todo = TodoModel(
                              title: title,
                              details: details,
                              isCompleted: false);
                          todoBox.add(todo);
                          Navigator.pop(context);
                          titleController.clear();
                          detailController.clear();
                        },
                        child: const Text("Add Todo"))
                  ],
                ),
              );
            },
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
