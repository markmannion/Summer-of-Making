import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

//linking to the python app through a local network
fetchData(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

//linking to the homepage
void main() {
  runApp(MaterialApp(
    home: HomePage(),
    routes: {
      '/calculator': (context) => GolfApp(),
    },
  ));
}

class GolfApp extends StatelessWidget {
  const GolfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Golf App')),
      body: Center(child: const Text('Welcome to the Golf App')),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yardage Calculator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/calculator');
                },
                child: const Text('Go to Calculator'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//creating the Belvelly widget so I can access this widget and page through the homepage
class Belvelly extends StatefulWidget {
  const Belvelly({super.key});

  @override
  BelvellyState createState() => BelvellyState();
}

//using the same method as the python app to calculate yardages
class BelvellyState extends State<Belvelly> {
  final TextEditingController yardController = TextEditingController();
  final TextEditingController windController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController holeController = TextEditingController();

  String result = '';

  Future<void> calculate() async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/calculate'); //same url as the python app
      final body = jsonEncode({
        'yard': int.tryParse(yardController.text) ?? 0,
        'wind': int.tryParse(windController.text) ?? 0,
        'temp': int.tryParse(tempController.text) ?? 0,
        'hole': int.tryParse(holeController.text) ?? 0,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          result = jsonDecode(response.body)['result'].toString();
        });
      } else {
        setState(() {
          result = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  Widget _buildInputCard(String label, TextEditingController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            TextField(controller: controller),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fota - Belvelly Course', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Image.asset(
                themeProvider.themeMode == ThemeMode.dark //change the image based on the theme
                    ? 'assets/images/range_white.png'
                    : 'assets/images/range_black.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 25),
              _buildInputCard('Yardage', yardController),
              _buildInputCard('Wind Speed MPH (Neg if downwind)', windController),
              _buildInputCard('Temperature *C', tempController),
              _buildInputCard('Hole', holeController),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: calculate, child: const Text('Calculate',textAlign: TextAlign.center, style: TextStyle(fontSize: 22))),
              const SizedBox(height: 25),
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    )
  );
  }
}