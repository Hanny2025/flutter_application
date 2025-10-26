import 'package:flutter/material.dart';

void main() => runApp(const CoffeeApp());

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF5E35B1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MFU Coffee Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7EEFF),
      ),
      home: const CoffeeOrderScreen(),
    );
  }
}

enum Coffee { latte, americano, cappuccino }

class CoffeeOrderScreen extends StatefulWidget {
  const CoffeeOrderScreen({super.key});

  @override
  State<CoffeeOrderScreen> createState() => _CoffeeOrderScreenState();
}

class _CoffeeOrderScreenState extends State<CoffeeOrderScreen> {
  final purple = const Color(0xFF5E35B1);

  final Map<Coffee, int> basePrice = const {
    Coffee.latte: 35,
    Coffee.americano: 30,
    Coffee.cappuccino: 40,
  };

  final Map<Coffee, String> hotAsset = {
    Coffee.latte: 'assets/images/latte_hot.png',
    Coffee.americano: 'assets/images/americano_hot.png',
    Coffee.cappuccino: 'assets/images/Cappuccino.png',
  };

  final Map<Coffee, String> icedAsset = {
    Coffee.latte: 'assets/images/latte_hot.png',
    Coffee.americano: 'assets/images/americano_hot.png',
    Coffee.cappuccino: 'assets/images/Cappuccino.png',
  };

  Coffee _coffee = Coffee.latte;
  bool _isCold = false;
  double _sugar = 2;
  bool _showThanks = false;

  String get sugarLabelForThumb => switch (_sugar.round()) {
        0 => 'none',
        1 => 'less',
        _ => 'Normal',
      };

  String get sugarSummary => switch (_sugar.round()) {
        0 => 'no sugar',
        1 => 'less sugar',
        _ => 'normal sugar',
      };

  String get coffeeName => switch (_coffee) {
        Coffee.latte => 'Latte',
        Coffee.americano => 'Americano',
        Coffee.cappuccino => 'Cappuccino',
      };

  int get totalPrice => basePrice[_coffee]! + (_isCold ? 5 : 0);
  String get typeText => _isCold ? 'Cold' : 'Hot';
  String currentAssetPath() => _isCold ? icedAsset[_coffee]! : hotAsset[_coffee]!;

  Future<void> _order() async {
    setState(() => _showThanks = false);
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFFFF6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your order',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  currentAssetPath(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$typeText $coffeeName with $sugarSummary. Price = $totalPrice baht',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(foregroundColor: purple),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(foregroundColor: purple),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() => _showThanks = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        title: const Text(
          'MFU Coffee Shop',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Your order',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Coffee', style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 8),
            _coffeeTile(Coffee.latte, 'Latte', basePrice[Coffee.latte]!),
            _coffeeTile(Coffee.americano, 'Americano', basePrice[Coffee.americano]!),
            _coffeeTile(Coffee.cappuccino, 'Cappuccino', basePrice[Coffee.cappuccino]!),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Type', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const Spacer(),
                const Text('Hot', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(width: 8),
                Switch(
                  value: _isCold,
                  onChanged: (v) => setState(() => _isCold = v),
                  activeColor: Colors.white,
                  activeTrackColor: purple,
                  inactiveThumbColor: Colors.grey.shade600,
                  inactiveTrackColor: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                const Text('Cold (+5)', style: TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Sugar', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(width: 12),
                const Text('None', style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: purple,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: purple,
                      overlayColor: purple.withOpacity(.15),
                      valueIndicatorColor: purple,
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: Slider(
                      min: 0,
                      max: 2,
                      divisions: 2,
                      value: _sugar,
                      label: sugarLabelForThumb,
                      onChanged: (v) => setState(() => _sugar = v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Normal', style: TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _order,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .5),
                  elevation: 0,
                ),
                child: const Text('ORDER'),
              ),
            ),
            const SizedBox(height: 10),
            if (_showThanks)
              const Center(
                child: Text(
                  'Thank you for your order!',
                  style: TextStyle(
                    color: Color(0xFFDD2E44),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coffeeTile(Coffee value, String name, int price) {
    return RadioListTile<Coffee>(
      value: value,
      groupValue: _coffee,
      onChanged: (v) => setState(() => _coffee = v!),
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
      title: Text(
        '$name $price',
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      activeColor: purple,
    );
  }
}
