import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController phoneController = TextEditingController(text: '+998');
  String name = '';
  String phoneNumber = '+998';
  int? selectedWarehouseId;
  String token = ''; // Variable to store the authentication token

  Future<void> authenticate() async {
    // The API endpoint for authentication
    String authenticateUrl = 'https://prodapi.shipox.com/api/v1/customer/authenticate';

    try {
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'username': 'test@mail.ru',
        'password': 'Nurmuhammad1',
        'remember_me': true,
      };

      // Send a POST request to authenticate
      var response = await http.post(
        Uri.parse(authenticateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> responseData = json.decode(response.body);

        // Extract and save the token
        token = responseData['data']['id_token'];
        print('Token: $token');
      } else {
        // If the request was not successful, print the error status code
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions that may occur during the request
      print('Error: $error');
    }
  }

  Future<void> createOrder() async {
    // The API endpoint for creating an order
    String createOrderUrl = 'https://prodapi.shipox.com/api/v2/customer/order';

    try {
      // Prepare the order data
      Map<String, dynamic> orderData = {
        "sender_data": {
          "address_type": "residential",
          "name": "Nurmuhammad",
          "email": "info@fargo.uz",
          "city": {"name": "Tashkent"},
          "country": {"id": 234},
          "neighborhood": {"name": "Chilonzor"},
          "phone": "+998901600106",
        },
        "recipient_data": {
          "address_type": "residential",
          "name": name, // Using the name from the client
          "phone": phoneNumber, // Using the phone number from the client
          "warehouse_id": selectedWarehouseId,
        },
        "dimensions": {
          "weight": 1,
          "unit": "METRIC",
        },
        "package_type": {
          "courier_type": "OFFICE_OFFICE",
        },
        "charge_items": [
          {
            "paid": true,
            "charge_type": "cod",
            "charge": 0,
          }
        ],
        "recipient_not_available": "do_not_deliver",
        "payment_type": "credit_balance",
        "payer": "sender",
        "parcel_value": null,
        "fragile": true,
        "note": "Books",
        "piece_count": 1,
        "force_create": true,
        "reference_id": "",
      };

      // Send a POST request to create the order
      var response = await http.post(
        Uri.parse(createOrderUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the authorization token
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 201) {
        // Parse the response JSON
        Map<String, dynamic> responseData = json.decode(response.body);
        String orderNumber = responseData['data']['order_number'];
        String Status = responseData['status'];
        // Show success message
        _showSuccessDialog(orderNumber);
        // Handle the response data as needed
        print('Order created successfully: $Status');
      } else {
        // If the request was not successful, print the error status code
        print('Error creating order: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions that may occur during the request
      print('Error creating order: $error');
    }
  }

  

  // Function to show success dialog
  void _showSuccessDialog(String orderNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fargo buyurtmangizni qabul qildi'),
          content: Text('sizning buyurtma raqamingiz $orderNumber.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedWarehouseId,
              onChanged: (value) {
                setState(() {
                  selectedWarehouseId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  value: 319749763,
                  child: Text('Namangan'),
                ),
                DropdownMenuItem<int>(
                  value: 319750381,
                  child: Text('Andijan'),
                ),
              ],
              decoration: InputDecoration(labelText: 'Select Warehouse'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await authenticate();
                await createOrder();
              },
              child: const Text('Buyurtma qoldirish'),
            ),
          ],
        ),
      ),
    );
  }
}