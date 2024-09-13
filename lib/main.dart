import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      theme: ThemeData.dark(),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  String _output = "0";
  String _history = "";
  bool _isResultShown = false;

  // Método para evaluar la expresión matemática
  double _evaluate(String expression) {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      // Evaluar la expresión en el contexto dado y devolver el resultado
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return double.nan;
    }
  }

  // Formatear el resultado para mostrar enteros sin ".0"
  String _formatResult(double result) {
    if (result.isNaN) {
      return "Error"; // Manejo de error si la evaluación falla
    } else if (result == result.toInt()) {
      return result.toInt().toString(); // Mostrar sin decimales si es entero
    } else {
      // Limitar a tres decimales y formatear
      String formattedResult = result.toStringAsFixed(3);
      // Eliminar ceros a la derecha en los decimales
      formattedResult = formattedResult.replaceAll(RegExp(r'0+$'), '');
      // Eliminar el punto si es el último carácter
      formattedResult = formattedResult.replaceAll(RegExp(r'\.$'), '');
      return formattedResult;
    }
  }

  // Método para manejar los botones presionados
  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // Reiniciar la calculadora
        _output = "0";
        _history = "";
        _isResultShown = false;
      } else if (buttonText == "⌫") {
        // Borrar el último carácter
        if (_output.isNotEmpty && _output != "0") {
          _output = _output.substring(0, _output.length - 1);
          if (_output.isEmpty) _output = "0";
        }
      } else if (buttonText == "=") {
        // Evaluar la expresión
        if (!_isResultShown) {
          _history = _output;
          double result = _evaluate(_output);
          _output = _formatResult(result);
          _isResultShown = true;
        }
      } else if (buttonText == ".") {
        // Agregar un punto decimal
        if (!_isResultShown &&
            !_output.endsWith('+') &&
            !_output.endsWith('-') &&
            !_output.endsWith('*') &&
            !_output.endsWith('/')) {
          List<String> parts = _output.split(RegExp(r'[\+\-\*/]'));
          if (parts.isNotEmpty && !parts.last.contains('.')) {
            _output += buttonText;
          }
        }
      } else {
        // Manejar la entrada de números y operadores
        if (_isResultShown) {
          if (RegExp(r'[\+\-\*/]').hasMatch(buttonText)) {
            _output += buttonText;
            _isResultShown = false;
          } else {
            _output = buttonText;
            _isResultShown = false;
          }
        } else if (_output == "0" && buttonText != ".") {
          _output = buttonText;
        } else if (RegExp(r'[\+\-\*/]$').hasMatch(_output) &&
            RegExp(r'[\+\-\*/]').hasMatch(buttonText)) {
          // Reemplazar el operador anterior
          _output = _output.substring(0, _output.length - 1) + buttonText;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            alignment: Alignment.centerRight,
            child: Text(
              _history,
              style: const TextStyle(fontSize: 22, color: Colors.grey),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            alignment: Alignment.centerRight,
            child: Text(
              _output,
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildButton("C"),
                    _buildButton("⌫"),
                    _buildButton("/"),
                    _buildButton("*"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("-"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("+"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("="),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildButton("0", flex: 3),
                    _buildButton("."),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir los botones de la calculadora
  Widget _buildButton(String buttonText, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(60, 60),
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}