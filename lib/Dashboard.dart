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
import 'package:wifi_iot/wifi_iot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title = 'Dasboard'});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _sampleHistory = [];

  late CameraController _cameraController;

  Future<void> connectToCamera() async {
    // Periksa apakah WiFi aktif
    bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();

    if (!isWifiEnabled) {
      // Jika WiFi tidak aktif, tampilkan pesan kesalahan atau tindakan yang sesuai
      print('WiFi is not enabled');
      return;
    }

    // Hubungkan ke jaringan WiFi dari kamera
    await WiFiForIoTPlugin.connect(
        'nama_ssid_wifi_camera kata_sandi_wifi_camera');

    // Periksa apakah koneksi WiFi berhasil
    bool isConnected = await WiFiForIoTPlugin.isConnected();

    if (isConnected) {
      // Jika berhasil terhubung ke WiFi kamera, lakukan operasi lain yang diperlukan
      print('Connected to camera WiFi');
      // Lakukan operasi lainnya seperti streaming video, pengambilan gambar, atau kontrol kamera
    } else {
      // Jika gagal terhubung ke WiFi kamera, tampilkan pesan kesalahan atau tindakan yang sesuai
      print('Failed to connect to camera WiFi');
    }
  }

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

  void _saveImagePathToDatabase(
      String imagePath, String landType, String elevationh) async {
    final url = Uri.parse(ApiConnect.image);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    final response = await http.post(url, body: {
      'imagePath': imagePath,
      'email': email,
      'dataran': elevationh,
      'lahan': landType
    });
    print(imagePath);
    print(email);
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
        if (imagePath != null) {
          String selectedLandType = 'Basah';
          String selectedElevation = 'Tinggi';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text("Preview Image"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.file(File(imagePath)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Jenis Tanah:"),
                            DropdownButton<String>(
                              value: selectedLandType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLandType =
                                      newValue ?? selectedLandType;
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Basah',
                                  child: Text('Basah'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Kering',
                                  child: Text('Kering'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Jenis Dataran:"),
                            DropdownButton<String>(
                              value: selectedElevation,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedElevation =
                                      newValue ?? selectedElevation;
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Tinggi',
                                  child: Text('Tinggi'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Rendah',
                                  child: Text('Rendah'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Proses"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          _saveImagePathToDatabase(
                              imagePath, selectedLandType, selectedElevation);
                          _applyLBPSajaNormalisasi();
                          // Optionally, you can show a confirmation dialog after saving
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Image Saved"),
                                content: Text(
                                    "Image path, land type, and elevation have been saved."),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
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
                        // _displayBottomDrones(context);
                        connectToCamera();
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
                        }
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
      String selectedLandType = 'Basah';
      String selectedElevation = 'Tinggi';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Preview Image"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.file(File(image.path)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jenis Tanah:"),
                        DropdownButton<String>(
                          value: selectedLandType,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLandType = newValue ?? selectedLandType;
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Basah',
                              child: Text('Basah'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Kering',
                              child: Text('Kering'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jenis Dataran:"),
                        DropdownButton<String>(
                          value: selectedElevation,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedElevation = newValue ?? selectedElevation;
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Tinggi',
                              child: Text('Tinggi'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Rendah',
                              child: Text('Rendah'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Proses"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _saveImagePathToDatabase(
                          image.path, selectedLandType, selectedElevation);
                      _applyLBPSajaNormalisasi();
                      // Optionally, you can show a confirmation dialog after saving
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Image Saved"),
                            content: Text(
                                "Image path, land type, and elevation have been saved."),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  // Future<void> _pickImage() async {
  //   final image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       // _image = File(image.path);
  //       _saveImagePathToDatabase(image.path);
  //       // _isImagePicked = true;
  //       // print("imagegeee");
  //       // _applyThresholding();
  //       // _applyGrayscale();
  //       // _applyGrayscaleAndCrop();
  //       // _applyGrayscaleCropEqualizeFilter();
  //       // _applyGrayscaleCropEqualizeLBP();
  //       // _applyLBPSaja();
  //       // _applyLBPSajaNormalisasi();
  //     });
  //   }
  // }

  // Future<void> _pickImagee() async {
  //   final image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _saveImagePathToDatabase(image.path);
  //     });
  //   }
  // }

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

  Future<void> _applyGrayscale() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.Image.from(originalImage);

        await Future.delayed(Duration(milliseconds: 500));

        for (int i = 0; i < originalImage.width; i++) {
          for (int j = 0; j < originalImage.height; j++) {
            final pixel = originalImage.getPixel(i, j);
            final r = img.getRed(pixel);
            final g = img.getGreen(pixel);
            final b = img.getBlue(pixel);

            final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

            grayImage.setPixelRgba(i, j, gray, gray, gray);
          }
        }

        final random = Random();
        final randomName = '${random.nextInt(100000)}'; // Generate random name
        final extension = path
            .extension(_image!.path); // Get the extension from original image
        // Simpan gambar grayscale dalam format PNG
        final grayImagePath =
            '/storage/emulated/0/DCIM/$randomName\_gray$extension';

        await File(grayImagePath).writeAsBytes(img.encodePng(grayImage));

        Fluttertoast.showToast(
          msg: 'Grayscale berhasil!',
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

  Future<void> _applyGrayscaleAndCrop() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.Image.from(originalImage);

        await Future.delayed(Duration(milliseconds: 500));

        for (int i = 0; i < originalImage.width; i++) {
          for (int j = 0; j < originalImage.height; j++) {
            final pixel = originalImage.getPixel(i, j);
            final r = img.getRed(pixel);
            final g = img.getGreen(pixel);
            final b = img.getBlue(pixel);

            final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

            grayImage.setPixelRgba(i, j, gray, gray, gray);
          }
        }

        // Crop bagian tengah dengan ukuran 640 x 480 piksel
        final cropX = (grayImage.width - 640) ~/ 2;
        final cropY = (grayImage.height - 480) ~/ 2;
        final croppedImage = img.copyCrop(grayImage, cropX, cropY, 640, 480);

        final random = Random();
        final randomName = '${random.nextInt(100000)}'; // Generate random name
        final extension = path
            .extension(_image!.path); // Get the extension from original image

        // Simpan gambar grayscale dan crop dalam format PNG
        final croppedImagePath =
            '/storage/emulated/0/DCIM/$randomName\_crop$extension';

        await File(croppedImagePath).writeAsBytes(img.encodePng(croppedImage));

        Fluttertoast.showToast(
          msg: 'Grayscale dan Crop berhasil!',
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

  Future<void> _applyGrayscaleCropEqualizeFilter() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.Image.from(originalImage);

        await Future.delayed(Duration(milliseconds: 500));

        for (int i = 0; i < originalImage.width; i++) {
          for (int j = 0; j < originalImage.height; j++) {
            final pixel = originalImage.getPixel(i, j);
            final r = img.getRed(pixel);
            final g = img.getGreen(pixel);
            final b = img.getBlue(pixel);

            final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

            grayImage.setPixelRgba(i, j, gray, gray, gray);
          }
        }

        // Crop bagian tengah dengan ukuran 640 x 480 piksel
        final cropX = (grayImage.width - 640) ~/ 2;
        final cropY = (grayImage.height - 480) ~/ 2;
        final croppedImage = img.copyCrop(grayImage, cropX, cropY, 640, 480);

        // Perhitungan histogram manual
        final histogram = List<int>.filled(
            256, 0); // Inisialisasi histogram dengan ukuran 256 (0-255)

        for (int i = 0; i < croppedImage.width; i++) {
          for (int j = 0; j < croppedImage.height; j++) {
            final pixel = croppedImage.getPixel(i, j);
            final gray = img.getRed(
                pixel); // Karena gambar sudah grayscale, cukup ambil komponen merah

            histogram[gray]++;
          }
        }

        // Penyetaraan histogram secara manual
        final equalizedImage =
            img.Image(croppedImage.width, croppedImage.height);
        final totalPixels = croppedImage.width * croppedImage.height;

        int sum = 0;
        for (int i = 0; i < histogram.length; i++) {
          sum += histogram[i];
          final normalizedValue = (sum * 255) ~/ totalPixels;

          for (int j = 0; j < croppedImage.height; j++) {
            for (int k = 0; k < croppedImage.width; k++) {
              final pixel = croppedImage.getPixel(k, j);
              final gray = img.getRed(
                  pixel); // Karena gambar sudah grayscale, cukup ambil komponen merah

              if (gray == i) {
                final newPixel = img.getColor(
                    normalizedValue, normalizedValue, normalizedValue);
                equalizedImage.setPixel(k, j, newPixel);
              }
            }
          }
        }

        // Proses tapis dengan Gaussian Blur menggunakan paket flutter_image
        final filteredImage = img.gaussianBlur(
            equalizedImage, 3); // Contoh Gaussian Blur dengan ukuran kernel 3x3

        final random = Random();
        final randomName = '${random.nextInt(100000)}'; // Generate random name
        final extension = path
            .extension(_image!.path); // Get the extension from original image

        // Simpan gambar hasil proses dalam format PNG
        final processedImagePath =
            '/storage/emulated/0/DCIM/$randomName\_processed$extension';

        await File(processedImagePath)
            .writeAsBytes(img.encodePng(filteredImage));

        Fluttertoast.showToast(
          msg: 'Grayscale, Crop, Equalize Histogram, dan Filter berhasil!',
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

  Future<void> _applyGrayscaleCropEqualizeLBP() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.Image.from(originalImage);

        await Future.delayed(Duration(milliseconds: 500));

        for (int i = 0; i < originalImage.width; i++) {
          for (int j = 0; j < originalImage.height; j++) {
            final pixel = originalImage.getPixel(i, j);
            final r = img.getRed(pixel);
            final g = img.getGreen(pixel);
            final b = img.getBlue(pixel);

            final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

            grayImage.setPixelRgba(i, j, gray, gray, gray);
          }
        }

        print('Gambar Grayscale:');
        print(img.encodePng(grayImage));

        // Simpan gambar grayscale dalam format PNG
        final grayImagePath = '/storage/emulated/0/DCIM/gray_image.png';
        await File(grayImagePath).writeAsBytes(img.encodePng(grayImage));

        // Crop bagian tengah dengan ukuran 640 x 480 piksel
        final cropX = (grayImage.width - 640) ~/ 2;
        final cropY = (grayImage.height - 480) ~/ 2;
        final croppedImage = img.copyCrop(grayImage, cropX, cropY, 640, 480);

        // Simpan gambar cropped dalam format PNG
        final croppedImagePath = '/storage/emulated/0/DCIM/cropped_image.png';
        await File(croppedImagePath).writeAsBytes(img.encodePng(croppedImage));

        // Perhitungan histogram manual
        final histogram = List<int>.filled(
            256, 0); // Inisialisasi histogram dengan ukuran 256 (0-255)

        for (int i = 0; i < croppedImage.width; i++) {
          for (int j = 0; j < croppedImage.height; j++) {
            final pixel = croppedImage.getPixel(i, j);
            final gray = img.getRed(
                pixel); // Karena gambar sudah grayscale, cukup ambil komponen merah

            histogram[gray]++;
          }
        }

        // Penyetaraan histogram secara manual
        final equalizedImage =
            img.Image(croppedImage.width, croppedImage.height);
        final totalPixels = croppedImage.width * croppedImage.height;

        int sum = 0;
        for (int i = 0; i < histogram.length; i++) {
          sum += histogram[i];
          final normalizedValue = (sum * 255) ~/ totalPixels;

          for (int j = 0; j < croppedImage.height; j++) {
            for (int k = 0; k < croppedImage.width; k++) {
              final pixel = croppedImage.getPixel(k, j);
              final gray = img.getRed(
                  pixel); // Karena gambar sudah grayscale, cukup ambil komponen merah

              if (gray == i) {
                final newPixel = img.getColor(
                    normalizedValue, normalizedValue, normalizedValue);
                equalizedImage.setPixel(k, j, newPixel);
              }
            }
          }
        }

        // Simpan gambar hasil penyetaraan histogram dalam format PNG
        final equalizedImagePath =
            '/storage/emulated/0/DCIM/equalized_image.png';
        await File(equalizedImagePath)
            .writeAsBytes(img.encodePng(equalizedImage));

        // Ekstraksi tekstur menggunakan Local Binary Pattern (LBP)
        final lbpImage = img.Image(croppedImage.width, croppedImage.height);
        final lbpDecimalValues = [];
        final scale = 255 / 256;

        for (int i = 1; i < croppedImage.width - 1; i++) {
          for (int j = 1; j < croppedImage.height - 1; j++) {
            final center = equalizedImage.getPixel(i, j);
            final centerGray = img.getRed(center);

            var code = 0;

            // Bandingkan nilai piksel dengan tetangganya
            code |=
                (equalizedImage.getPixel(i - 1, j - 1) > centerGray ? 1 : 0) <<
                    7;
            code |=
                (equalizedImage.getPixel(i, j - 1) > centerGray ? 1 : 0) << 6;
            code |=
                (equalizedImage.getPixel(i + 1, j - 1) > centerGray ? 1 : 0) <<
                    5;
            code |=
                (equalizedImage.getPixel(i + 1, j) > centerGray ? 1 : 0) << 4;
            code |=
                (equalizedImage.getPixel(i + 1, j + 1) > centerGray ? 1 : 0) <<
                    3;
            code |=
                (equalizedImage.getPixel(i, j + 1) > centerGray ? 1 : 0) << 2;
            code |=
                (equalizedImage.getPixel(i - 1, j + 1) > centerGray ? 1 : 0) <<
                    1;
            code |=
                (equalizedImage.getPixel(i - 1, j) > centerGray ? 1 : 0) << 0;

            // Skala piksel LBP dari 0-255 ke 0-255
            final scaledCode = (code * scale).round();

            // Simpan nilai desimal LBP pada citra LBP
            final pixelValue = img.getColor(scaledCode, scaledCode, scaledCode);
            lbpImage.setPixel(i, j, pixelValue);

            // Tambahkan nilai desimal ke dalam daftar lbpDecimalValues
            lbpDecimalValues.add(scaledCode);
          }
        }

// // Simpan gambar hasil ekstraksi LBP dalam format PNG
//         final lbpImagePath = '/storage/emulated/0/DCIM/lbp_image.png';
//         await File(lbpImagePath).writeAsBytes(img.encodePng(lbpImage));

        // print(lbpImage);
        print("Nilai LBP : ");
        print(img.encodePng(lbpImage));
// Cetak output nilai desimal LBP
        print('Nilai desimal LBP: $lbpDecimalValues');

        Fluttertoast.showToast(
          msg: 'Grayscale, Crop, Equalize Histogram, dan LBP berhasil!',
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

  Future<void> _applyLBPSaja() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.grayscale(originalImage);

        // Cetak gambar grayscale pada konsol
        print('Gambar Grayscale:');
        print(img.encodePng(grayImage));

        // Crop bagian tengah dengan ukuran 640 x 480 piksel
        final cropX = (grayImage.width - 640) ~/ 2;
        final cropY = (grayImage.height - 480) ~/ 2;
        final croppedImage = img.copyCrop(grayImage, cropX, cropY, 640, 480);

        // Ekstraksi tekstur menggunakan Local Binary Pattern (LBP)
        final lbpImage = img.Image(croppedImage.width, croppedImage.height);
        final lbpDecimalValues = [];
        final scale = 255 / 255; // Update scale to 255 / 255

        for (int i = 1; i < croppedImage.width - 1; i++) {
          for (int j = 1; j < croppedImage.height - 1; j++) {
            final center = croppedImage.getPixel(i, j);
            final centerGray = img.getRed(center);

            var code = 0;

            // Bandingkan nilai piksel dengan tetangganya
            code |=
                (croppedImage.getPixel(i - 1, j - 1) > centerGray ? 1 : 0) << 7;
            code |= (croppedImage.getPixel(i, j - 1) > centerGray ? 1 : 0) << 6;
            code |=
                (croppedImage.getPixel(i + 1, j - 1) > centerGray ? 1 : 0) << 5;
            code |= (croppedImage.getPixel(i + 1, j) > centerGray ? 1 : 0) << 4;
            code |=
                (croppedImage.getPixel(i + 1, j + 1) > centerGray ? 1 : 0) << 3;
            code |= (croppedImage.getPixel(i, j + 1) > centerGray ? 1 : 0) << 2;
            code |=
                (croppedImage.getPixel(i - 1, j + 1) > centerGray ? 1 : 0) << 1;
            code |= (croppedImage.getPixel(i - 1, j) > centerGray ? 1 : 0) << 0;

            // Skala piksel LBP dari 0-255 ke 0-255
            final scaledCode = (code * scale).round();

            // Simpan nilai desimal LBP pada citra LBP
            final pixelValue = img.getColor(scaledCode, scaledCode, scaledCode);
            lbpImage.setPixel(i, j, pixelValue);

            // Tambahkan nilai desimal ke dalam daftar lbpDecimalValues
            lbpDecimalValues.add(scaledCode);
          }
        }

        // Cetak gambar LBP pada konsol
        print('Gambar LBP:');
        print(img.encodePng(lbpImage));

        // Cetak output nilai desimal LBP
        print('Nilai desimal LBP: $lbpDecimalValues');

        Fluttertoast.showToast(
          msg: 'Ekstraksi LBP berhasil!',
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

  Future<void> _applyLBPSajaNormalisasi() async {
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

      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final grayImage = img.grayscale(originalImage);

        // Cetak gambar grayscale pada konsol
        print('Gambar Grayscale:');
        print(img.encodePng(grayImage));

        // Crop bagian tengah dengan ukuran 640 x 480 piksel
        final cropX = (grayImage.width - 640) ~/ 2;
        final cropY = (grayImage.height - 480) ~/ 2;
        final croppedImage = img.copyCrop(grayImage, cropX, cropY, 640, 480);

        // Ekstraksi tekstur menggunakan Local Binary Pattern (LBP)
        final lbpImage = img.Image(croppedImage.width, croppedImage.height);
        final lbpDecimalValues = [];
        final scale = 255 / 255; // Update scale to 255 / 255

        for (int i = 1; i < croppedImage.width - 1; i++) {
          for (int j = 1; j < croppedImage.height - 1; j++) {
            final center = croppedImage.getPixel(i, j);
            final centerGray = img.getRed(center);

            var code = 0;

            // Bandingkan nilai piksel dengan tetangganya
            code |=
                (croppedImage.getPixel(i - 1, j - 1) > centerGray ? 1 : 0) << 7;
            code |= (croppedImage.getPixel(i, j - 1) > centerGray ? 1 : 0) << 6;
            code |=
                (croppedImage.getPixel(i + 1, j - 1) > centerGray ? 1 : 0) << 5;
            code |= (croppedImage.getPixel(i + 1, j) > centerGray ? 1 : 0) << 4;
            code |=
                (croppedImage.getPixel(i + 1, j + 1) > centerGray ? 1 : 0) << 3;
            code |= (croppedImage.getPixel(i, j + 1) > centerGray ? 1 : 0) << 2;
            code |=
                (croppedImage.getPixel(i - 1, j + 1) > centerGray ? 1 : 0) << 1;
            code |= (croppedImage.getPixel(i - 1, j) > centerGray ? 1 : 0) << 0;

            // Skala piksel LBP dari 0-255 ke 0-255
            final scaledCode = (code * scale).round();

            // Simpan nilai desimal LBP pada citra LBP
            final pixelValue = img.getColor(scaledCode, scaledCode, scaledCode);
            lbpImage.setPixel(i, j, pixelValue);

            // Tambahkan nilai desimal ke dalam daftar lbpDecimalValues
            lbpDecimalValues.add(scaledCode);
          }
        }

        // Cetak gambar LBP pada konsol
        print('Gambar LBP:');
        print(img.encodePng(lbpImage));

        final countMap = <int, int>{};

        for (final value in img.encodePng(lbpImage)) {
          final intValue = value.toInt();
          countMap[intValue] = (countMap[intValue] ?? 0) + 1;
        }

// Print the occurrence count
        for (final entry in countMap.entries) {
          print('Value: ${entry.key}, Jumlah kemunculan: ${entry.value}');
        }

        // final countMap = <int, int>{};

        for (final value in img.encodePng(lbpImage)) {
          final intValue = value.toInt();
          countMap[intValue] = (countMap[intValue] ?? 0) + 1;
        }

// Calculate the total occurrences
        int totalOccurrences = 0;
        for (final entry in countMap.entries) {
          totalOccurrences += entry.value;
        }

        print('Total Kemunculan: $totalOccurrences');

        for (final entry in countMap.entries) {
          final percentage = entry.value / totalOccurrences * 100;
          print(
              'Value: ${entry.key}, Jumlah kemunculan: ${entry.value}, Persentase: $percentage%');
        }

//         final countMap = <int, int>{};

//         for (int i = 0; i <= 255; i++) {
//           countMap[i] = 0;
//         }

//         for (final value in lbpImage.data) {
//           if (value >= 0 && value <= 255) {
//             countMap[value] = countMap[value]! + 1;
//           }
//         }

// // Print the occurrence count
//         for (int i = 0; i <= 255; i++) {
//           print('Value: $i, Jumlah kemunculan: ${countMap[i]}');
//         }

//         final countMap = <int, int>{};

//         for (final value in img.encodePng(lbpImage)) {
//           final intValue = value.toInt();
//           if (intValue >= 0 && intValue <= 255) {
//             countMap[intValue] = (countMap[intValue] ?? 0) + 1;
//           }
//         }

// // Print the occurrence count
//         for (int i = 0; i <= 255; i++) {
//           final occurrenceCount = countMap[i] ?? 0;
//           print('Value: $i, Jumlah kemunculan: $occurrenceCount');
//         }

//         final countMap = <int, int>{};

//         for (final value in img.encodePng(lbpImage)) {
//           final intValue = value.toInt();
//           countMap[intValue] = (countMap[intValue] ?? 0) + 1;
//         }

// // Print the occurrence count
//         for (final entry in countMap.entries) {
//           print('Value: ${entry.key}, Jumlah kemunculan: ${entry.value}');
//         }

//         final countMap = <int, int>{};
//         for (final value in lbpImage.data) {
//           countMap[value] = (countMap[value] ?? 0) + 1;
//         }

// // Cetak hasil jumlah kemunculan
//         countMap.forEach((value, count) {
//           print('Nilai: $value, Jumlah Kemunculan: $count');
//         });

        // // Normalisasi LBP
        // final normalizedLbpDecimalValues =
        //     lbpDecimalValues.map((value) => value / 255).toList();

        // // Cetak output nilai desimal LBP
        // print(
        //     'Nilai desimal LBP (Setelah Normalisasi): $normalizedLbpDecimalValues');

        // Normalisasi LBP
        // final maxCode = (255 * scale).round();
        // final normalizedLbpDecimalValues =
        //     lbpDecimalValues.map((value) => value / maxCode).toList();

        // print(
        //     'Nilai desimal LBP (Setelah Normalisasi): $normalizedLbpDecimalValues');

        Fluttertoast.showToast(
          msg: 'Ekstraksi LBP berhasil!',
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
