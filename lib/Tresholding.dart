import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:path/path.dart' as path;
import 'LodingScreen.dart';

class ThresholdingPage extends StatefulWidget {
  @override
  _ThresholdingPageState createState() => _ThresholdingPageState();
}

class _ThresholdingPageState extends State<ThresholdingPage> {
  File? _image;
  ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  bool _isLoading =
      false; // Variable untuk menandakan apakah sedang loading atau tidak

  Future<void> _applyThresholding() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Mencegah menutup dialog dengan mengklik di luar area dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content:
              LoadingScreen(), // Tampilan loading menggunakan widget LoadingScreen
        );
      },
    );

    if (_image != null && !_isLoading) {
      // Cek jika tidak sedang dalam proses loading
      setState(() {
        _isLoading = true; // Set loading menjadi true
      });

      final threshold = 128;
      final bytes = await _image!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        // Salin gambar asli untuk masing-masing output warna
        final grayImage = img.Image.from(originalImage);
        final redImage = img.Image.from(originalImage);
        final greenImage = img.Image.from(originalImage);
        final blueImage = img.Image.from(originalImage);

        await Future.delayed(Duration(
            milliseconds: 500)); // Delay untuk menunjukkan tampilan loading

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
          _isLoading = false; // Set loading menjadi false setelah selesai
        });
      }
    }
    Navigator.of(context).pop();
  }
  // Future<void> _applyThresholding() async {
  //   if (_image != null) {
  //     final threshold = 128;
  //     // Ubah tipe data menjadi Uint8List
  //     final bytes = await _image!.readAsBytes();
  //     final imageBytes = bytes.buffer.asUint8List();

  //     final length = imageBytes.length;
  //     final remainder = length % 4;
  //     final adjustedLength = length - remainder;

  //     for (int i = 0; i < adjustedLength; i += 4) {
  //       final int r = imageBytes[i];
  //       final int g = imageBytes[i + 1];
  //       final int b = imageBytes[i + 2];

  //       final int gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

  //       if (gray > threshold) {
  //         imageBytes[i] = 255;
  //         imageBytes[i + 1] = 255;
  //         imageBytes[i + 2] = 255;
  //       } else {
  //         imageBytes[i] = 0;
  //         imageBytes[i + 1] = 0;
  //         imageBytes[i + 2] = 0;
  //       }
  //     }

  //     // Simpan thresholdedBytes ke file
  //     final thresholdedImagePath =
  //         '/storage/emulated/0/DCIM/thresholded_image.png';
  //     final thresholdedImage = File(thresholdedImagePath);
  //     await thresholdedImage.writeAsBytes(imageBytes, flush: true);

  //     // Baca kembali gambar menggunakan package image
  //     final image = img.decodeImage(thresholdedImage.readAsBytesSync());

  //     // Simpan ulang gambar dengan format yang tepat
  //     final pngThresholdedImage = File(thresholdedImagePath);
  //     pngThresholdedImage.writeAsBytesSync(img.encodePng(image));

  //     Fluttertoast.showToast(
  //       msg: 'Thresholding berhasil!',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.black54,
  //       textColor: Colors.white,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Robo Soil'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          if (_image != null)
            Container(
              height: 500, // Atur tinggi image picker sesuai kebutuhan
              width: double
                  .infinity, // Atur lebar image picker agar mengisi lebar layar
              child: Image.file(_image!),
            ),
          Align(
            alignment:
                Alignment.center, // Menyusun widget secara horizontal di tengah
            child: ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pilih Gambar'),
            ),
          ),
          Align(
            alignment:
                Alignment.center, // Menyusun widget secara horizontal di tengah
            child: ElevatedButton(
              onPressed: _applyThresholding,
              child: Text('Proses Image'),
            ),
          ),
        ],
      ),
    );
  }
}
