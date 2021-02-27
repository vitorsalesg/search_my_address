import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    color: Colors.yellow,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String street = '';
  String complement = '';
  String district = '';
  String locality = '';
  String onErrorMensage = '';

  bool loading = false;

  final _formKey = GlobalKey<FormState>();
  final _field = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(''),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    size: 120.0,
                  ),
                  Text(
                    'Busque seu Endereço',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: textFieldWidget(
                      Icons.search,
                      'Digite seu CEP',
                      TextInputType.number,
                      false,
                      _field,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    height: 50.0,
                    color: Colors.yellow,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _searchAddress(_field.text.replaceAll('-', ''));
                      }
                    },
                    child: loading ? circularWidget() : Text('Buscar'),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            accentColor: Colors.black,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              "Endereço",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: <Widget>[
                              ListTile(title: Text('Logradouro: $street')),
                              ListTile(title: Text('Complemento: $complement')),
                              ListTile(title: Text('Bairro: $district')),
                              ListTile(title: Text('Localidade: $locality')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFieldWidget(IconData icon, String label, TextInputType keyBoard,
      bool obscureField, TextEditingController controlerField) {
    return TextFormField(
      keyboardType: keyBoard,
      obscureText: obscureField,
      controller: controlerField,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.black),
        focusColor: Colors.black,
        errorText: onErrorMensage.isEmpty ? null : onErrorMensage,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 18,
          color: Colors.black,
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }

  Widget circularWidget() {
    return Container(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }

  _searchAddress(String cep) async {
    circleLoading(true);

    try {
      String url = 'https://viacep.com.br/ws/$cep/json/';

      http.Response response;

      response = await http.get(url);

      Map<String, dynamic> result = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          street = result["logradouro"];
          complement = result["complemento"];
          district = result["bairro"];
          locality = result["localidade"];
          loading = false;
          _field.text = '';
          onErrorMensage = '';
        });
      } else {
        setState(() {
          onErrorMensage = 'CEP não encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        onErrorMensage = 'CEP não encontrado.';
      });

      circleLoading(false);
    }
  }

  void circleLoading(bool value) {
    setState(() {
      loading = value;
    });
  }
}
