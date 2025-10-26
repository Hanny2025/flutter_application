//ID:6631501114
import 'package:flutter/material.dart';

class Fishing extends StatefulWidget {
  const Fishing({super.key});

  @override
  State<Fishing> createState() => _FishingState();
}

class _FishingState extends State<Fishing> {
  // Fish data
  List fish = [
    {
      'name': 'AnglerFish',
      'price': 20,
      'image': 'assets/images/fish/anglerfish.png',
    },
    {
      'name': 'NeonTerTra',
      'price': 10,
      'image': 'assets/images/fish/neon-tetra.png',
    },
    {
      'name': 'Puffer',
      'price': 5,
      'image': 'assets/images/fish/puffer-fish.png',
    },
    {'name': 'Shark', 'price': 10, 'image': 'assets/images/fish/shark.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 158, 245),
        title: const Text(
          'Fishing Game',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,

        children: const [
          Image(
            image: AssetImage('assets/images/fishing/anglerfish.png'),
            image: AssetImage('assets/images/fishing/fisherman.png'),
            image: AssetImage('assets/images/fishing/neon-tetra.png'),
            image: AssetImage('assets/images/fishing/puffer-fish.png'),
            image: AssetImage('assets/images/fishing/shark.png'),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
