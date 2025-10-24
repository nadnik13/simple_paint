import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/data/drawn_line.dart';
import 'package:simple_paint/services/sketcher.dart';
import 'package:simple_paint/ui/widgets/my_color_picker.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';
import 'package:simple_paint/ui/widgets/tool_bar.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = new GlobalKey();
  final GlobalKey _drawingAreaKey =
      new GlobalKey(); // Ключ для области рисования
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  List<DrawnLine> lines = <DrawnLine>[];
  late DrawnLine line;
  bool isNewLine = true;
  late StreamController<List<DrawnLine>> linesStreamController;
  late StreamController<DrawnLine> currentLineStreamController;

  @override
  void initState() {
    line = DrawnLine(path: [], color: selectedColor);
    linesStreamController = StreamController<List<DrawnLine>>.broadcast();
    currentLineStreamController = StreamController<DrawnLine>.broadcast();
    super.initState();
  }

  Future<void> save() async {
    try {
      // RenderRepaintBoundary boundary =
      //     _globalKey.currentContext?.findRenderObject()
      //         as RenderRepaintBoundary;
      // ui.Image image = await boundary.toImage();
      // final ByteData? byteData = await image.toByteData(
      //   format: ui.ImageByteFormat.png,
      // );
      // Uint8List pngBytes = byteData.buffer.asUint8List();
      // var saved = await ImageGallerySaver.saveImage(
      //   pngBytes,
      //   quality: 100,
      //   name: DateTime.now().toIso8601String() + ".png",
      //   isReturnImagePathOfIOS: true,
      // );
      print("saved");
    } catch (e) {
      print(e);
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      isNewLine = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        backgroundColor: Color(0x1AC4C4C4), // 10% прозрачности
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            print('go_to_galery');
            context.go('/gallery');
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text('Новое изображение', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              print('finish');
              context.go('/gallery');
            },
            icon: Icon(Icons.check_outlined, color: Colors.white),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Column(
          children: [
            Toolbar(),
            SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    buildAllPaths(context), // Включаем отображение всех линий
                    buildCurrentPath(context),
                    buildColorToolbar(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        key: _drawingAreaKey, // Добавляем ключ к области рисования
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(painter: Sketcher(lines: [line]));
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(painter: Sketcher(lines: lines));
          },
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    // Используем RenderBox области рисования вместо всей страницы
    RenderBox? box =
        _drawingAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset point = box.globalToLocal(details.globalPosition);
      line = DrawnLine(path: [point], color: selectedColor);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Используем RenderBox области рисования вместо всей страницы
    RenderBox? box =
        _drawingAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset point = box.globalToLocal(details.globalPosition);

      List<Offset> path = List.from(line.path)..add(point);
      line = DrawnLine(path: path, color: selectedColor);
      currentLineStreamController.add(line);
    }
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);
    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Container(
      alignment: Alignment.topRight,
      child: MyColorPicker(
        arrowOffset: 155,
        radius: 14,
        child: SizedBox(
          width: 260,
          //height: 180,
          child: Container(
            child: BlockPicker(
              pickerColor: selectedColor,
              layoutBuilder: _layoutBuilder,
              itemBuilder: _itemBuilder,
              onColorChanged: (color) => setState(() => selectedColor = color),
            ),
          ),
        ),
      ),
    );
    // child: MyColorPicker(
    //   arrowOffset: 155,
    //   radius: 14,
    //   child: SizedBox(
    //     width: 260,
    //     height: 180,
    //     child: Container(color: Colors.red, child: BlockPicker(
    //   pickerColor: selectedColor,
    //   onColorChanged: (color) => setState(() => selectedColor = color)))),
    //   ),
    // );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: CircleAvatar(
        child: Icon(Icons.save, size: 20.0, color: Colors.white),
      ),
    );
  }

  Widget _layoutBuilder(
    BuildContext context,
    List<Color> colors,
    PickerItem child,
  ) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      color: Colors.transparent,
      width: 260,
      height: orientation == Orientation.portrait ? 180 : 180,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 7 : 10,
        shrinkWrap: true,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: [for (Color color in colors) child(color)],
      ),
    );
  }

  // Provide a shape for [BlockPicker].
  Widget _itemBuilder(
    Color color,
    bool isCurrentColor,
    void Function() changeColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            offset: const Offset(1, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(
              Icons.done,
              size: 20,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
