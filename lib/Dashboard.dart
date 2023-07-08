import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:robo_soil/Tresholding.dart';
import 'about.dart';
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'CardBerita.dart';
import 'Api/Api_Connect.dart';
import 'package:http/http.dart' as http;
import 'Rekap.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title = 'Dasboard'});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _sampleHistory = [];

  late CameraController _cameraController;
  void _openCamera() async {
    // Dapatkan daftar kamera yang tersedia
    List<CameraDescription> cameras = await availableCameras();

    // Pilih kamera belakang (indeks 0) sebagai default
    CameraDescription selectedCamera = cameras[0];

    // Buka kamera yang dipilih
    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
    );

    // Inisialisasi kamera
    await _cameraController.initialize();

    // Buka tampilan kamera dalam modal fullscreen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              CameraPreview(_cameraController),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _takePicture,
                  child: Text("Take Picture"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _cameraController.dispose();
  }

  void _saveImagePathToDatabase(String imagePath) async {
    final url = Uri.parse(ApiConnect.image);
    final response = await http.post(url, body: {'imagePath': imagePath});
    print(imagePath);
    if (response.statusCode == 200) {
      print('Path gambar berhasil disimpan di database');
      _sampleHistory.add(imagePath); // Tambahkan path gambar ke dalam riwayat
      setState(() {}); // Perbarui tampilan dengan memanggil setState()
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      final PermissionStatus permissionStatus =
          await Permission.storage.request();
      if (permissionStatus.isGranted) {
        final Directory directory = Directory('/storage/emulated/0/DCIM');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String imagePath = '${directory.path}/$fileName';
        final XFile capturedImage = await _cameraController.takePicture();
        final File imageFile = File(capturedImage.path);
        await imageFile.copy(imagePath);
        await ImageGallerySaver.saveFile(imagePath);
        _saveImagePathToDatabase(
            imagePath); // Panggil metode _saveImagePathToDatabase() di sini
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Gambar diambil'),
              content: Image.file(File(imagePath)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Tutup'),
                ),
              ],
            );
          },
        );
      } else {
        print('Izin penyimpanan ditolak');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Fitur Fitur Robo Soil",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 66, 66, 66),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                children: [
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: _openCamera,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.camera,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "Camera",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.flight_rounded,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "Drone",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(
                          builder: (context) => RekapTanah(),
                        );
                        Navigator.push(context, route);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.book,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "Rekap",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(
                          builder: (context) => AboutPage(),
                        );
                        Navigator.push(context, route);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.info,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "About",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(
                          builder: (context) => ThresholdingPage(),
                        );
                        Navigator.push(context, route);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.image,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "Tresh",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Berita Seputar Robo Soil",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 66, 66, 66),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CardBerita(sampleHistory: _sampleHistory),
            ),
          ],
        ),
      ),
    );
  }
}
