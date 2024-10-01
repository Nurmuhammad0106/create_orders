import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false, // Add this line to remove the debug banner
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController phoneController = TextEditingController(text: '+998 ');
  String name = '';
  String phoneNumber = '+998';
  int? selectedWarehouseId;
  bool isCreatingOrder = false;
  String token = ''; // Variable to store the authentication token
  String orderNumber = '';

  // Создаем объекты FocusNode для каждого текстового поля
  FocusNode nameFocus = FocusNode();
  FocusNode phoneNumberFocus = FocusNode();
  FocusNode warehouseFocus = FocusNode();

  Future<void> authenticate() async {
    // The API endpoint for authentication
    String authenticateUrl = 'https://prodapi.shipox.com/api/v1/customer/authenticate';

    try {
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'username': '102_nalichiishoes@fargo.uz',
        'password': 'Fargo0093',
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
          "name": "Nalichchi_shoes",
          "email": "info@fargo.uz",
          "city": {"name": "Tashkent"},
          "country": {"id": 234},
          "neighborhood": {"name": "Chilonzor"},
          "phone": "+998919800093",
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
            "paid": false,
            "charge_type": "service_custom",
            "charge": 20000,
          }
        ],
        "recipient_not_available": "do_not_deliver",
        "payment_type": "cash",
        "payer": "recipient",
        "parcel_value": null,
        "fragile": true,
        "note": "buyum",
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
        orderNumber = responseData['data']['order_number'];
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
        title: const Text('Буюртмангиз қабул қилинди'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Сизнинг буюртма рақамингиз $orderNumber. Илтимос уни бизга юборинг'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                TextButton(
                  onPressed: () {
                    // Copy the orderNumber to the clipboard
                    Clipboard.setData(ClipboardData(text: orderNumber));
                    Navigator.of(context).pop();
                    // Show a snackbar or toast indicating successful copy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Мувофақиятли сақланди юборишингиз мумкин'),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 5),
                      Text('Буюртма рақамни сақлаб олиш'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255), // Set the background color to gray
      appBar: AppBar(
        title: const Text('Nalichchi shoes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const CircleAvatar(
                radius: 50, // Устанавливаем радиус аватара
                backgroundImage: AssetImage('assets/images/logo.jpg',), // Замените 'assets/your_image.jpg' на путь к вашей картинке
              ),
              const SizedBox(height: 8),
            Card(
              elevation: 4.0,
              color: Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
              child: TextField(
                focusNode: nameFocus,
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Исмингиз',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_outline), // Icon for Name

              ),
            ),
          ),
        ),
            const SizedBox(height: 7),
            Card(
              color: Color.fromARGB(255, 255, 252, 252),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextField(
                  focusNode: phoneNumberFocus,
                  controller: phoneController,
                  onChanged: (value) {
                    setState(() {
                    phoneNumber = value.replaceAll(' ', '');
                });
              },
              decoration: const InputDecoration(
                labelText: 'Телефон рақамингиз',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.phone_iphone), // Icon for PhoneNumber
                ),
            ),
            ),
            ),
            const SizedBox(height: 7),
            Card(
              color: Color.fromARGB(255, 255, 255, 255),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: DropdownButtonFormField<int>(
                    focusNode: warehouseFocus,
              value: selectedWarehouseId,
              onChanged: (value) {
                setState(() {
                  selectedWarehouseId = value;
                });
              },
              items: const [
                DropdownMenuItem<int>(
                value: 319753835,
                  child: Center(
                    child: Text(
                      'Ангрен',
                    ),
                  ),
                ),
              DropdownMenuItem<int>(
                value: 319750381,
                  child: Center(
                    child: Text(
                      'Андижон',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319752259,
                  child: Center(
                    child: Text(
                      'Бухоро',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 679966731,
                  child: Center(
                    child: Text(
                      'Гиждувон',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 499681951,
                  child: Center(
                    child: Text(
                      'Гулистон',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 700465819,
                  child: Center(
                    child: Text(
                      'Денов',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319751225,
                  child: Center(
                    child: Text(
                      'Жиззах',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 499684314,
                  child: Center(
                    child: Text(
                      'Зарафшон',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319752402,
                  child: Center(
                    child: Text(
                      'Қарши',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 723278025,
                  child: Center(
                    child: Text(
                      'Косонсой',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 509602726,
                  child: Center(
                    child: Text(
                      'Қўкон',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 1246326409,
                  child: Center(
                    child: Text(
                      'Қўкон (Янги бозор)',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 1116985310,
                  child: Center(
                    child: Text(
                      'Мингбулоқ',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319751589,
                  child: Center(
                    child: Text(
                      'Навои',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319749763,
                  child: Center(
                    child: Text(
                      'Наманган',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319753066,
                  child: Center(
                    child: Text(
                      'Нукус',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319750904,
                  child: Center(
                    child: Text(
                      'Самарканд',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319752723,
                  child: Center(
                    child: Text(
                      'Термиз',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319752905,
                  child: Center(
                    child: Text(
                      'Урганч',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319753594,
                  child: Center(
                    child: Text(
                      'Фаргона',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 319754157,
                  child: Center(
                    child: Text(
                      'Чирчиқ',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 1579134301,
                  child: Center(
                    child: Text(
                      'Шахрисабз',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 963686463,
                  child: Center(
                    child: Text(
                      'Бек Барака',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 990841133,
                  child: Center(
                    child: Text(
                      'Мирзо Улугбек',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 501710953,
                  child: Center(
                    child: Text(
                      'Учтепа',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 655903644,
                  child: Center(
                    child: Text(
                      'Шайхонтохур',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 934182817,
                  child: Center(
                    child: Text(
                      'Юнусобод',
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                value: 501652397,
                  child: Center(
                    child: Text(
                      'Яккасарой',
                    ),
                  ),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Манзилингиз',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.location_on_outlined), // Icon for Location
                ),
            ),
            ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child:ElevatedButton(
              onPressed: () async {
                // Проверяем, что поля не пусты
      if (name.isEmpty || phoneNumber=='+998' || selectedWarehouseId == null) {
        // Если хотя бы одно поле пусто, показываем сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Илтимос, бўш майдонларни тўлдиринг'),
          ),
        );

        // Устанавливаем фокус на первое пустое поле
        if (name.isEmpty) {
          FocusScope.of(context).requestFocus(nameFocus);
        } else if (phoneNumber=='+998') {
          FocusScope.of(context).requestFocus(phoneNumberFocus);
        } else {
          // Если все поля заполнены, но не выбран склад, устанавливаем фокус на DropdownButton
          FocusScope.of(context).requestFocus(warehouseFocus);
        }

        return; // Прерываем выполнение метода, чтобы не продолжать без заполненных полей
      }
       // Устанавливаем состояние "в процессе создания заказа"
                  setState(() {
                    isCreatingOrder = true;
                  });
      
                await authenticate();
                await createOrder();
                // Сбрасываем состояние "в процессе создания заказа" после завершения
                  setState(() {
                    isCreatingOrder = false;
                  });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              child: isCreatingOrder
                    ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ) // Показываем индикатор ожидания, если заказ создается
                    : const Text(
                        'Буюртма қолдириш',
                        style: TextStyle(color: Colors.white),
                      ),),),
                      SizedBox(height: 8), // Add some space between the button and the order details
            if (orderNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      launch('https://my.fargo.uz/track?id=$orderNumber&source=RECIPIENT');
                    },
                    child: Text(
                      'Nalichcchi_shoes буюрмангизни қабул қилди харидигиз учун рахмат, қуидаги хавола орқли буюрмани кузатиб боришингиз мумкин: https://my.fargo.uz/track?id=$orderNumber&source=RECIPIENT',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
}