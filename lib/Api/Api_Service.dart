import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:robo_soil/Dashboard.dart';
import 'Api_Connect.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

Future<void> registerUser(String name, String email, String password) async {
  final apiUrl = Uri.parse(ApiConnect.register);

  final response = await http.post(
    apiUrl,
    body: {
      'name': name,
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 201) {
    print('Registrasi berhasil');
    Fluttertoast.showToast(
      msg: 'Registrasi berhasil',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  } else {
    print('Registrasi gagal');
    Fluttertoast.showToast(
      msg: 'Registrasi Gagal',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}

Future<void> loginUser(
    BuildContext context, String email, String password) async {
  final apiUrl = Uri.parse(ApiConnect.login);

  final response = await http.post(
    apiUrl,
    body: {
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    // Login berhasil
    final data = jsonDecode(response.body);
    final token = data['token'];
    final user = data['user'];

    print('Login successful');
    print('Token: $token');
    print('User: $user');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
    print('Registrasi gagal');
    Fluttertoast.showToast(
      msg: 'Login Berhasil',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  } else if (response.statusCode == 401) {
    // Kredensial tidak valid
    print('Invalid credentials');
  } else {
    // Respons lainnya
    print('Login failed');
    print('Registrasi gagal');
    Fluttertoast.showToast(
      msg: 'Gagal Login',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}

// void _saveImagePathToDatabase(String imagePath) async {
//   final url = Uri.parse(ApiConnect.image);
//   final response = await http.post(url, body: {'imagePath': imagePath});
//   print(imagePath);
//   if (response.statusCode == 200) {
//     print('Path gambar berhasil disimpan di database');

//     // Mendapatkan data JSON dari respons
//     final jsonResponse = json.decode(response.body);
//     print(jsonResponse); // Cetak respons JSON
//   } else {
//     print('Error: ${response.statusCode}');
//   }
// }

class Berita {
  final int id;
  final String image;
  final String judul;
  final String deskripsi;
  final String tanggal;

  Berita(
      {required this.id,
      required this.judul,
      required this.deskripsi,
      required this.tanggal,
      required this.image});

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'],
      image: json['image'],
      judul: json['title'],
      deskripsi: json['description'],
      tanggal: json['created_at'],
    );
  }
}

Future<List<Berita>> fetchBerita() async {
  final response = await http.get(Uri.parse(ApiConnect.berita));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    final List<Berita> users =
        responseData.map((json) => Berita.fromJson(json)).toList();
    return users;
  } else {
    throw Exception('Failed to fetch data');
  }
}

class ImageTanaman {
  final int id;
  final String image;

  ImageTanaman({required this.id, required this.image});

  factory ImageTanaman.fromJson(Map<String, dynamic> json) {
    return ImageTanaman(
      id: json['id'],
      image: json['imagepath'],
    );
  }
}

Future<List<ImageTanaman>> fetchImage() async {
  final response = await http.get(Uri.parse(ApiConnect.rekap));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    final List<ImageTanaman> users =
        responseData.map((json) => ImageTanaman.fromJson(json)).toList();
    return users;
  } else {
    throw Exception('Failed to fetch data');
  }
}
