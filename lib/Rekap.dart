import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CardImage.dart';

class RekapTanah extends StatelessWidget {
  // const RekapTanah({super.key});

  @override
  List<String> _sampleHistory = [];
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white.withOpacity(0.98),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child: Text(
                "Robo Soil",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 29, 197, 104),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: CardImage(sampleHistory: _sampleHistory),
      ),
    );
  }
}
