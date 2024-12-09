import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';

class Angela extends StatefulWidget {
  const Angela({super.key});

  @override
  State<Angela> createState() => _AngelaState();
}

class _AngelaState extends State<Angela> {
  File? filePath;
  String label = 'No Detection Yet';
  double confidence = 0.0;
  bool isModelLoaded = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initTfLite();
  }

  Future<void> _initTfLite() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );

      if (res == "success") {
        setState(() {
          isModelLoaded = true;
        });
        print("TFLite Model loaded successfully.");
      } else {
        print("Failed to load TFLite Model: $res");
      }
    } catch (e) {
      print("Error loading TFLite Model: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> pickImageGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _processImage(File(image.path));
  }

  Future<void> pickImageCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    await _processImage(File(image.path));
  }

  Future<void> _processImage(File image) async {
    setState(() {
      filePath = image;
      label = "Processing...";
      confidence = 0.0;
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          confidence = (recognitions[0]['confidence'] as double) * 100;
          label = recognitions[0]['label'] as String;
        });
      } else {
        setState(() {
          label = "No results found";
        });
      }
    } catch (e) {
      setState(() {
        label = "Error processing image.";
      });
      print("Error during image recognition: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Angela - Object Detection"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: filePath == null
                            ? Image.asset(
                                'assets/upload.jpg',
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                filePath!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              confidence > 0
                                  ? "Confidence: ${confidence.toStringAsFixed(2)}%"
                                  : "Awaiting Detection...",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isModelLoaded ? pickImageCamera : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Take a Photo"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isModelLoaded ? pickImageGallery : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Pick from Gallery"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
