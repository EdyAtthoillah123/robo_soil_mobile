import 'package:flutter/material.dart';
import 'Api/Api_Service.dart';
import 'Api/Api_Connect.dart';
import 'package:google_fonts/google_fonts.dart';

class CardBerita extends StatelessWidget {
  final List<String> sampleHistory;
  final apiUrl = Uri.parse(ApiConnect.host);

  CardBerita({this.sampleHistory = const []});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder<List<Berita>>(
            future: fetchBerita(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final berita = users[index];
                    return Card(
                      child: ListTile(
                        // leading: Text((index + 1).toString()), // Menambahkan nomor pada leading
                        title: Container(
                          padding: EdgeInsets.only(
                              top:
                                  8), // Menambahkan jarak atas sebesar 8 satuan
                          child: Text(
                            berita.judul,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 37, 37, 37),
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Image.network(
                                apiUrl.toString() + 'image/' + berita.image),
                            SizedBox(height: 8),
                            // Text(berita.tanggal),
                            Text(berita.deskripsi),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
