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
      debugShowCheckedModeBanner: false,
      title: 'Smart Billing App',
      theme: ThemeData(),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController deviceIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Billing App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Device ID',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: deviceIdController,
                decoration: const InputDecoration(
                  hintText: 'Device ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(deviceId: deviceIdController.text),
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String deviceId;

  const HomePage({required this.deviceId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];
  late String userId; // New variable to store the user ID

  @override
  void initState() {
    super.initState();
    userId = widget.deviceId; // Initialize userId with the deviceId
    fetchData();
  }

  Future<void> fetchData() async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final response = await http.get(
        Uri.parse(
            'https://abhi.tinkerspace.in/billingtrolly/getdata.php?user_id=$userId'),
      );
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

  Future<void> updateQty(String itemName) async {
    final response = await http.post(
      Uri.parse(
          'https://abhi.tinkerspace.in/billingtrolly/updateqty.php?item=$itemName&user_id=$userId'),
    );
    if (response.statusCode == 200) {
      fetchData(); // Refresh the list after updating quantity
    } else {
      throw Exception('Failed to update quantity');
      print("failed to update quantity");
    }
  }

  Future<void> pay(BuildContext context) async {
    String enteredCardNumber = "";
    String enteredPassword = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Card Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  enteredCardNumber = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                ),
              ),
              TextField(
                onChanged: (value) {
                  enteredPassword = value;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel button
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Check if card number and password match the stored values
                if (enteredCardNumber == '123' && enteredPassword == '1719') {
                  Navigator.of(context).pop(); // Close dialog
                  // Proceed with payment API call
                  await callPaymentAPI();
                } else {
                  // Show error message for wrong card number or password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wrong card number or password.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> callPaymentAPI() async {
    print("callingAPI");
    final response = await http.post(
      Uri.parse(
          'https://abhi.tinkerspace.in/billingtrolly/billdone.php?user_id=trolly0002'), // Use userId here
    );
    if (response.statusCode == 200) {
      fetchData(); // Refresh the list after updating quantity
      print(" updated bill");
    } else {
      throw Exception('Failed to update quantity');
      print("failed to update quantity");
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = items.length;
    double totalAmount =
        items.fold(0.0, (total, item) => total + double.parse(item['rupees']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Billing App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: items.map((item) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 178, 179, 180)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.grey,
                            ),
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
                                          deleteItem(item['item']);
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
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['item'],
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 111, 185, 247),
                                  fontSize: 21,
                                ),
                              ),
                              if (int.parse(item['qty']) > 0)
                                Text(
                                  '${item['qty']} Qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (double.parse(item['kg']) > 0)
                                Text(
                                  'kg: ${item['kg']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                'Rupees: ${item['rupees']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Color.fromARGB(221, 223, 33, 33),
                            ),
                            onPressed: () {
                              updateQty(item['item']);
                            },
                          ),
                        ],
                      ),
                    ],
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
                  ElevatedButton(
                    onPressed: () {
                      pay(context);
                    },
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
