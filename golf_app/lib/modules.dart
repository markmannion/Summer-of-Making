import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modules',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('Light/Dark Theme', style: TextStyle(fontSize: 16)),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (_){
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(height:20),
          GestureDetector(
            onTap: () async{
              final url = Uri.parse('https://github.com/markmannion');
              if (await canLaunchUrl(url)){
                await launchUrl(url);
              }
            },
            child: const Text(
              'https://github.com/markmannion',
              style : TextStyle(
                color: Colors.blue,
                decoration:TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}