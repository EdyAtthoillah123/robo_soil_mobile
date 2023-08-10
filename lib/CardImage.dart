import 'package:flutter/material.dart';
import 'Api/Api_Service.dart';
import 'dart:io';

class CardImage extends StatelessWidget {
  final List<String> sampleHistory;

  CardImage({this.sampleHistory = const []});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder<List<ImageTanaman>>(
            future: fetchImage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        // leading: Text((index + 1).toString()), // Menambahkan nomor pada leading
                        title: Text(
                          "Pengambilan Sample Image Tanah",
                          textAlign: TextAlign.left,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Image.file(
                              File(user.image),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                            SizedBox(height: 8),
                            Text("Hasil Output Citra Image Tanah"),
                            Text("Nilai N :"),
                            Text("Nilai P :"),
                            Text("Nilai K :"),
                            Text("Saran Tanaman: " + user.tanaman),
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
