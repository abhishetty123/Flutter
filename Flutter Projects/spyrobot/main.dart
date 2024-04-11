import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Billing App',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final response = await http.get(Uri.parse(
          'https://abhi.tinkerspace.in/billingtrolly/getdata.php?user_id=trolly0001'));
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body).cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load items');
      }
    });
  }

  Future<void> deleteItem(String itemName) async {
    final response = await http.post(
      Uri.parse(
          'https://abhi.tinkerspace.in/billingtrolly/delete.php?item=$itemName'),
    );
    if (response.statusCode == 200) {
      fetchData(); // Refresh the list after deletion
    } else {
      throw Exception('Failed to delete item');
      print("failed to delete");
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = items.length;
    int totalAmount =
        items.fold(0, (total, item) => total + int.parse(item['rupees']));

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 74, 159, 230),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Smart Billing App')),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: items.map((item) {
                return Container(
                  // color: Colors.blue,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    // color: Colors.blue,
                    border: Border.all(
                        color: const Color.fromARGB(255, 178, 179, 180)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      item['item'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 111, 185, 247),
                        fontSize: 21,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      '${item['kg']} kg - Rs. ${item['rupees']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      // color: Colors.white,
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Item'),
                              content: const Text(
                                  'Are you sure you want to delete this item?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteItem(item[
                                        'item']); // Pass item name instead of user_id
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Items: $totalItems'),
                  Text('Total Amount: Rs. $totalAmount'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
