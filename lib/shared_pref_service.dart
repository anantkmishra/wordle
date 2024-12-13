import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class Prefs{

  static final Prefs instance = Prefs._();

  factory Prefs(){
    return instance;
  }

  Prefs._();

  init() async{
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  late final SharedPreferences _sharedPreferences;

  final String _kcoins = 'coins';
  final String _kwinCount = 'winCount';
  final String _kloseCount = 'loseCount';
  final String _kplayCount = 'playCount';
  final String _khintCount = 'hintCount';

  bool contains(String key){
    return _sharedPreferences.containsKey(key);
  }

  clear(){
    _sharedPreferences.clear();
  }

  dynamic _getVal(String key){
    if (_sharedPreferences.containsKey(key)) {
      var value = _sharedPreferences.get(key);
      return value;
    }
    dev.log('Exception : "$key" not found', name: 'Shared Preferences');
    return Exception('Shared Preference Key : "$key" not found');
  }

  _setVal(String key, dynamic value){
    if (value is String){
      _sharedPreferences.setString(key, value);
    } else if (value is int){
      _sharedPreferences.setInt(key, value);
    } else if (value is double){
      _sharedPreferences.setDouble(key, value);
    } else if (value is bool){
      _sharedPreferences.setBool(key, value);
    } else if (value is List<String>){
      _sharedPreferences.setStringList(key, value);
    }
  }

  int get coins {
    if (!contains(_kcoins)) {
      dev.log('coins not found');
      _setVal(_kcoins, 5);
    }
    return _getVal(_kcoins);
  }

  set coins(int n) => _setVal(_kcoins, n);

}