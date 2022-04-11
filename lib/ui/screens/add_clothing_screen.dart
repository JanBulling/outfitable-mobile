import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/clothing/clothing.dart';
import '../../models/clothing/utils.dart';
import '../../services/closet_service.dart';

class AddClothingScreen extends StatefulWidget {
  final Map<String, dynamic>? _detectedClothing;

  AddClothingScreen(this._detectedClothing, {Key? key}) : super(key: key) {}

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  Color? _color;
  int _type = ClothingType.NONE;
  int _part = ClothingPart.NONE;
  List<int> _temperatures = [];
  List<int> _styles = [];

  @override
  void initState() {
    super.initState();
    if (widget._detectedClothing != null) {
      var clothing = Clothing.fromType(widget._detectedClothing!["type"]);
      _type = clothing.type;
      _part = clothing.part;
      _temperatures = clothing.temperatures;
      _styles = clothing.styles;
      _color = widget._detectedClothing!["color"];
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Clothing"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Selected Clothing"),
                DropdownButton<int>(
                  items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                      .map((value) => DropdownMenuItem(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(ClothingUtils.getTypeIconPath(value), width: 24, height: 24),
                                Text(lang.clothing_type(value)),
                              ],
                            ),
                            value: value,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      var clothing = Clothing.fromType(value ?? ClothingType.NONE);
                      _type = clothing.type;
                      _part = clothing.part;
                      _temperatures = clothing.temperatures;
                      _styles = clothing.styles;
                    });
                  },
                  menuMaxHeight: 400,
                  value: _type != ClothingType.NONE ? _type : null,
                  hint: const Text("Select Clothing"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Selected Style"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _styleChoiceChip(ClothingStyle.CASUAL, lang),
                _styleChoiceChip(ClothingStyle.FORMAL, lang),
                _styleChoiceChip(ClothingStyle.SPORTS, lang),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Selected Temperature"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _temperatureChoiceChip(TemperatureCategory.ICY, lang),
                _temperatureChoiceChip(TemperatureCategory.COLD, lang),
                _temperatureChoiceChip(TemperatureCategory.MODERATE, lang),
                _temperatureChoiceChip(TemperatureCategory.WARM, lang),
                _temperatureChoiceChip(TemperatureCategory.HOT, lang),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _color ?? Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(width: 10),
                MaterialButton(
                  color: _color,
                  child: const Text("Color"),
                  minWidth: 200,
                  onPressed: () {
                    showDialog(context: context, builder: _colorPickerDialog);
                  },
                ),
              ],
            ),
            MaterialButton(
              child: const Text("Add"),
              color: Colors.lightBlue,
              minWidth: double.infinity,
              onPressed: () {
                var clothing = Clothing(
                  type: _type,
                  part: _part,
                  temperatures: _temperatures,
                  styles: _styles,
                  colorValue: _color?.value ?? 0xff000000,
                );

                if (clothing.validate()) {
                  ClosetService().save(clothing);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  AlertDialog _colorPickerDialog(BuildContext context) {
    Color pickerColor = _color ?? Colors.black;
    return AlertDialog(
      title: const Text("Pick a color"),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          enableAlpha: false,
          onColorChanged: (color) => pickerColor = color,
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text("Select Color"),
          onPressed: () {
            setState(() {
              _color = pickerColor;
            });
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  ChoiceChip _styleChoiceChip(int stlye, AppLocalizations lang) {
    return ChoiceChip(
      selectedColor: Colors.blue,
      label: Text(lang.clothing_style(stlye)),
      selected: _styles.contains(stlye),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _styles.add(stlye);
          } else {
            _styles.remove(stlye);
          }
        });
      },
    );
  }

  ChoiceChip _temperatureChoiceChip(int temperature, AppLocalizations lang) {
    return ChoiceChip(
      selectedColor: Colors.blue,
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(ClothingUtils.getTemperatureIconPath(temperature), width: 24, height: 24),
          Text(lang.clothing_temperatures(temperature)),
        ],
      ),
      selected: _temperatures.contains(temperature),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _temperatures.add(temperature);
          } else {
            _temperatures.remove(temperature);
          }
        });
      },
    );
  }
}
