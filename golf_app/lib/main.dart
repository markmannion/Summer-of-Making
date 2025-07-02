import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'settings.dart';

//linking to the python app through a local network
fetchData(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

//Creating the light and dark themes for the app
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueGrey,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
);

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Dark Mode',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: HomePage(),
          routes: {
            '/calculator': (context) => GolfApp(),
            '/belvelly': (context) => Belvelly(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}

//Setting up the home page to include - the changing image, main title, courses, a theme toggle, link to my github page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yardage Calculator',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              }
            )
          ]
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 45),
                  Image.asset(
                    themeProvider.themeMode == ThemeMode.dark
                        ? 'assets/images/golf_white.png'
                        : 'assets/images/golf_dark.png',
                    width: 320, 
                    height: 320, 
                  ),
                  const SizedBox(height: 60), 
                  const Text(
                    'Choose your course: ',
                    style: TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/calculator');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    child: const Text('Fota - Deerpark Course', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/belvelly');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    child: const Text('Fota - Belvelly Course', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Light/Dark Theme', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async{
                      final url = Uri.parse('https://github.com/markmannion');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text('https://github.com/markmannion', //link to my github page
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//declaring the GolfApp and linking it to my python script
//also setting up the two other pages to work with the home page
class GolfApp extends StatefulWidget {
  const GolfApp({super.key});

  @override
  GolfAppState createState() => GolfAppState();
}

class GolfAppState extends State<GolfApp> {
  final TextEditingController yardController = TextEditingController();
  final TextEditingController windController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController holeController = TextEditingController();

  String result = '';

  Future<void> calculate() async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/calculate'); //same url as the python app
      final body = {
        'yard': int.tryParse(yardController.text) ?? 0,
        'wind': int.tryParse(windController.text) ?? 0,
        'temp': int.tryParse(tempController.text) ?? 0,
        'hole': int.tryParse(holeController.text) ?? 0,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['final_yardage'] != null && data['recommended_club'] != null) {
          setState(() {
            result =
                "Final Yardage: ${data['final_yardage']}\nRecommended Club: ${data['recommended_club']}";
          });
        } else {
          setState(() {
            result = "Error: Invalid response from server.";
          });
        }
      } else {
        setState(() {
          result = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Fota - Deerpark Course', style:  TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                themeProvider.themeMode == ThemeMode.dark
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
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}

class Belvelly extends StatefulWidget {
  const Belvelly({super.key});

  @override
  BelvellyState createState() => BelvellyState();
}
//declaring the belvelly state
//used for the belvelly page to link it to the python flask app
class BelvellyState extends State<Belvelly> {
  final TextEditingController yardController = TextEditingController();
  final TextEditingController windController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController holeController = TextEditingController();

  String result = '';

  Future<void> calculate() async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/calculate');
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
        final data = jsonDecode(response.body);
        if (data['final_yardage'] != null && data['recommended_club'] != null) {
          setState(() {
            result =
                "Final Yardage: ${data['final_yardage']}\nRecommended Club: ${data['recommended_club']}";
          });
        } else {
          setState(() {
            result = "Error: Invalid response from server.";
          });
        }
      } else {
        setState(() {
          result = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: ${e.toString()}";
      });
    }
  }

  Widget _buildInputCard(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fota - Belvelly Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                themeProvider.themeMode == ThemeMode.dark
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
              ElevatedButton(
                onPressed: calculate,
                child: const Text(
                  'Calculate',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
                ),
              ),
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
    );
  }
}