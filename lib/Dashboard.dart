import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about.dart';
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'CardBerita.dart';
import 'Api/Api_Connect.dart';
import 'package:http/http.dart' as http;
import 'Rekap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:path/path.dart' as path;
import 'LodingScreen.dart';
import 'package:flutter/services.dart';

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
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20.0), // Tambahkan jarak bawah di sini
                  child: InkWell(
                    onTap: _takePicture,
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 238, 238, 238),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Icon(Icons.camera),
                      ),
                    ),
                  ),
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
        String imagePath = '${directory.path}/$fileName';
        final XFile capturedImage = await _cameraController.takePicture();
        final File imageFile = File(capturedImage.path);
        await imageFile.copy(imagePath);
        await ImageGallerySaver.saveFile(imagePath);
        // _saveImagePathToDatabase(
        //     imagePath); // Panggil metode _saveImagePathToDatabase() di sini
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
                TextButton(
                  onPressed: () async {
                    if (imagePath != null) {
                      setState(() {
                        _image = File(imagePath);
                        _isImagePicked = true;
                      });

                      await _applyThresholding();
                      _saveImagePathToDatabase(imagePath);

                      setState(() {
                        imagePath =
                            ''; // Set imagePath menjadi string kosong setelah thresholding
                      });
                    }

                    Route route = MaterialPageRoute(
                      builder: (context) => RekapTanah(),
                    );
                    Navigator.pushReplacement(context,
                        route); // Gunakan pushReplacement untuk menggantikan halaman saat ini dengan halaman rekap
                  },
                  child: Text("Proses image"),
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
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                children: [
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      // onPressed: _openCamera,
                      onPressed: () {
                        _displayBottomSheet(context);
                      },
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
                      onPressed: () {
                        _displayBottomDrones(context);
                      },
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

  Future<void> _displayBottomDrones(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: 500,
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Ambil Gambar dengan Drone",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 66, 66, 66),
                  ),
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Masukkan IP dari Drone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageThresholding = false;

  Future _displayBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: 160,
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Ambil Gambar Melalui",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                      onPressed: () async {
                        _pickImage();
                        if (_isImagePicked) {
                          await _applyThresholding();
                          // if (_applyThresholding() == true) {
                          // Route route = MaterialPageRoute(
                          //   builder: (context) => RekapTanah(),
                          // );
                          // await Navigator.pushReplacement(context, route);
                          // }
                        }
                        // Route route = MaterialPageRoute(
                        //   builder: (context) => RekapTanah(),
                        // );
                        // Navigator.pushReplacement(context, route);
                        // onPressed: () async {
                        // _pickImage();
                        // if (_isImagePicked) {
                        //   await _applyThresholding();
                        //   if (_isImageThresholding) {
                        //     await Future.delayed(Duration.zero);
                        //     Route route = MaterialPageRoute(
                        //       builder: (context) => RekapTanah(),
                        //     );
                        //     Navigator.pushReplacement(context, route);
                        //   }
                        // }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.photo_library,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 20.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              "Gallery",
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
          ],
        ),
      ),
    );
  }

  bool _isImagePicked = false;

  File? _image;
  // File? _imagePicker;
  ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _saveImagePathToDatabase(image.path);
        _isImagePicked = true;
        // // print("imagegeee");
        _applyThresholding();
      });
    }
  }

  bool _isLoading =
      false; // Variable untuk menandakan apakah sedang loading atau tidak

  Future<void> _applyThresholding() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: LoadingScreen(),
        );
      },
    );

    if (_image != null && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      final threshold = 128;
      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.Image.from(originalImage);
        final redImage = img.Image.from(originalImage);
        final greenImage = img.Image.from(originalImage);
        final blueImage = img.Image.from(originalImage);

        await Future.delayed(Duration(milliseconds: 500));

        for (int i = 0; i < originalImage.width; i++) {
          for (int j = 0; j < originalImage.height; j++) {
            final pixel = originalImage.getPixel(i, j);
            final r = img.getRed(pixel);
            final g = img.getGreen(pixel);
            final b = img.getBlue(pixel);

            final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

            // Thresholding untuk gambar abu-abu
            if (gray > threshold) {
              grayImage.setPixelRgba(i, j, 255, 255, 255);
            } else {
              grayImage.setPixelRgba(i, j, 0, 0, 0);
            }

            // Thresholding untuk gambar merah
            if (r > threshold) {
              redImage.setPixelRgba(i, j, 255, 0, 0);
            } else {
              redImage.setPixelRgba(i, j, 0, 0, 0);
            }

            // Thresholding untuk gambar hijau
            if (g > threshold) {
              greenImage.setPixelRgba(i, j, 0, 255, 0);
            } else {
              greenImage.setPixelRgba(i, j, 0, 0, 0);
            }

            // Thresholding untuk gambar biru
            if (b > threshold) {
              blueImage.setPixelRgba(i, j, 0, 0, 255);
            } else {
              blueImage.setPixelRgba(i, j, 0, 0, 0);
            }
          }
        }

        final random = Random();
        final randomName = '${random.nextInt(100000)}'; // Generate random name
        final extension = path
            .extension(_image!.path); // Get the extension from original image

        // Simpan gambar thresholded dalam format PNG
        final grayImagePath =
            '/storage/emulated/0/DCIM/$randomName\_gray$extension';
        final redImagePath =
            '/storage/emulated/0/DCIM/$randomName\_red$extension';
        final greenImagePath =
            '/storage/emulated/0/DCIM/$randomName\_green$extension';
        final blueImagePath =
            '/storage/emulated/0/DCIM/$randomName\_blue$extension';

        await File(grayImagePath).writeAsBytes(img.encodePng(grayImage));
        await File(redImagePath).writeAsBytes(img.encodePng(redImage));
        await File(greenImagePath).writeAsBytes(img.encodePng(greenImage));
        await File(blueImagePath).writeAsBytes(img.encodePng(blueImage));

        Fluttertoast.showToast(
          msg: 'Thresholding berhasil!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );

        setState(() {
          _isLoading = false;
          _image = null; // Set _image menjadi null
        });
      }
    }
    Navigator.of(context).pop();
  }
}
