// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'dart:math';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

enum Detector { barcode, face, label, cloudLabel, text, cloudText }

/* FaceDetectPainter class to draw a rectangle on the screen when a face is found */
class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces);

  final Size absoluteImageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = scaleX;
    final double yShift = size.height / 2 -
        (((absoluteImageSize.width / absoluteImageSize.aspectRatio) * scaleY) /
            2);


    final Paint redLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    double mustacheStroke = (absoluteImageSize.aspectRatio > 1) ? 5 : 12;
    print('absoluteImageSize.aspectRatio = ' + absoluteImageSize.aspectRatio.toString());
    print('mustache stroke = ' + mustacheStroke.toString());

    final Paint blackLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = mustacheStroke
      ..color = Colors.black54;

    for (Face face in faces) {
      Offset baseOfNose = face.getLandmark(FaceLandmarkType.noseBase).position;
      FaceContour leftEye = face.getContour(FaceContourType.leftEye);
      FaceContour rightEye = face.getContour(FaceContourType.rightEye);
      double baseOfNoseYShifted = baseOfNose.dy * scaleY + yShift;
      double baseOfNoseXShifted = baseOfNose.dx * scaleX;
      double bottomOfFaceShifted = face.boundingBox.bottom * scaleY + yShift;
      double rightSideOfFaceShifted = face.boundingBox.right * scaleX;
      double leftSideOfFaceShifted = face.boundingBox.left * scaleX;

      double rightThirdX = (rightSideOfFaceShifted - baseOfNoseXShifted) / 5.0;
      double leftThirdX = (baseOfNoseXShifted - leftSideOfFaceShifted) / 5.0;
      double thirdY = (bottomOfFaceShifted - baseOfNoseYShifted) / 4.0;


        // draw the arc for the mustache to the right if the right eye is detected
      if(rightEye != null) {
        Rect rightArc1BoundingBox = Rect.fromLTRB(
            baseOfNoseXShifted, baseOfNoseYShifted,
            baseOfNoseXShifted + (2 * rightThirdX),
            baseOfNoseYShifted + thirdY);

        canvas.drawArc(
            rightArc1BoundingBox,
            (0),
            (pi),
            false,
            blackLine);
      }

      // draw the arc for the mustache to the left if the left eye is detected
      if (leftEye != null) {
        Rect leftArc1BoundingBox = Rect.fromLTRB(
            baseOfNoseXShifted - (leftThirdX * 2), baseOfNoseYShifted,
            baseOfNoseXShifted, baseOfNoseYShifted + thirdY);

        canvas.drawArc(
            leftArc1BoundingBox,
            (0),
            (pi),
            false,
            blackLine);
      }

          // Offset baseOfNoseShifted = Offset(baseOfNoseXShifted, baseOfNoseYShifted);
//      double topOfRectForArc = baseOfNoseYShifted -
//          ((face.boundingBox.bottom * scaleY + yShift) - baseOfNoseYShifted) /
//              2;
//      double bottomOfRectForArc = face.boundingBox.bottom * scaleY +
//          yShift -
//          ((face.boundingBox.bottom * scaleY + yShift) - baseOfNoseYShifted) /
//              2;
//      canvas.drawArc(
//          Rect.fromLTRB(
//              baseOfNoseXShifted,
//              topOfRectForArc,
//              face.boundingBox.right * scaleX,
//              bottomOfRectForArc),
//          (0.5 * pi),
//          (0.5 * pi),
//          false,
//          blackLine);


      canvas.drawRect(
        Rect.fromLTRB(
          face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY + yShift,
          face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY + yShift,
        ),
        redLine,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
