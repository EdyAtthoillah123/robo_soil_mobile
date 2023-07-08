import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialPage extends StatelessWidget {
  @override
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
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara Penggunaan Aplikasi :',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Pengambilan Gambar Melalaui Camera HP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Aplikasi ini merupakan solusi inovatif untuk menganalisis dan menghasilkan citra nilai NPK (Nitrogen, Fosfor, dan Kalium) tanah dengan menggunakan gambar tanah yang diambil menggunakan perangkat mobile.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Pengambilan Menggunakan Drone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- Pengambilan gambar tanah dengan kamera perangkat mobile',
            ),
            Text(
              '- Analisis citra untuk mendapatkan nilai NPK tanah',
            ),
            Text(
              '- Tampilan visualisasi hasil analisis',
            ),
            SizedBox(height: 16),
            Text(
              'Dengan aplikasi ini, pengguna dapat dengan mudah mengambil gambar tanah, melakukan analisis citra, dan mendapatkan informasi penting tentang nilai NPK tanah secara cepat dan akurat. Aplikasi ini cocok digunakan oleh petani, ahli pertanian, dan peneliti dalam meningkatkan kualitas pertanian dan keberlanjutan lingkungan.',
            ),
          ],
        ),
      ),
    );
  }
}
