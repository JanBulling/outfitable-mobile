import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../cubits/add_clothing_cubit.dart';
import '../../models/clothing/utils.dart';

class AddClothingScreen extends StatelessWidget {
  final Map<String, dynamic>? _arguments;

  const AddClothingScreen(this._arguments, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddClothingCubit()..init(_arguments),
      child: const AddClothingView(),
    );
  }
}

class AddClothingView extends StatelessWidget {
  const AddClothingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.add_clothing),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: BlocBuilder<AddClothingCubit, AddClothingState>(
          builder: (_, state) {
            if (state is UpdatedClothingState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.select_clothing_type,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ClothingTypeDropdown(state.clothing.type),
                  const SizedBox(height: 20),
                  Text(
                    lang.select_clothing_style,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ClothingStyleChips(state.clothing.styles),
                  const SizedBox(height: 20),
                  Text(
                    lang.select_clothing_temperature,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ClothingTemperatureChips(state.clothing.temperatures),
                  const SizedBox(height: 20),
                  ClothingColorPicker(state.clothing.color),
                  const SizedBox(height: 20),
                  Center(
                    child: SvgPicture.asset(
                      ClothingUtils.getTypeIconPath(state.clothing.type),
                      color: state.clothing.color,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    child: Text(lang.add),
                    color: Colors.grey,
                    minWidth: double.infinity,
                    onPressed: () {
                      print("Added clothing. Valid: ${state.clothing.validate()}");
                    },
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

// ========= Widgets =============================================
/// Widget for displaying the clothing-type dropdown menu
class ClothingTypeDropdown extends StatelessWidget {
  final int type;
  const ClothingTypeDropdown(this.type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return DropdownButtonHideUnderline(
      child: Container(
        width: 250,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<int>(
          items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
              .map((clothing) => DropdownMenuItem(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(ClothingUtils.getTypeIconPath(clothing), width: 24, height: 24),
                        Text(lang.clothing_type(clothing)),
                      ],
                    ),
                    value: clothing,
                  ))
              .toList(),
          onChanged: (type) => BlocProvider.of<AddClothingCubit>(context).changeType(type ?? ClothingType.NONE),
          menuMaxHeight: 400,
          value: type != ClothingType.NONE ? type : null,
          hint: Text(lang.select_clothing_type),
          isExpanded: true,
          elevation: 4,
        ),
      ),
    );
  }
}

/// Widget for displaying the choiceCips for the clothing style
class ClothingStyleChips extends StatelessWidget {
  final List<int> styles;
  const ClothingStyleChips(this.styles, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Wrap(
        spacing: 5,
        direction: Axis.horizontal,
        children: [0, 1, 2].map((style) {
          return ChoiceChip(
            label: Text(lang.clothing_style(style)),
            selected: styles.contains(style),
            backgroundColor: Colors.grey.shade200,
            selectedColor: Colors.grey.shade500,
            onSelected: (_) => BlocProvider.of<AddClothingCubit>(context).changeStyle(style),
          );
        }).toList());
  }
}

/// Widget for displaying the choiceCips for the temperature of the clothing piece
class ClothingTemperatureChips extends StatelessWidget {
  final List<int> temperatures;
  const ClothingTemperatureChips(this.temperatures, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 5,
      direction: Axis.horizontal,
      children: [0, 1, 2, 3, 4].map((temperature) {
        return ChoiceChip(
          label: Column(
            children: [
              SvgPicture.asset(
                ClothingUtils.getTemperatureIconPath(temperature),
                width: 18,
                height: 18,
              ),
              Text(lang.clothing_temperatures(temperature)),
            ],
          ),
          backgroundColor: Colors.grey.shade200,
          selectedColor: Colors.grey.shade500,
          selected: temperatures.contains(temperature),
          onSelected: (_) => BlocProvider.of<AddClothingCubit>(context).changeTemperautr(temperature),
        );
      }).toList(),
    );
  }
}

/// Widget for showing a color picker dialog for changing the color of the piece
class ClothingColorPicker extends StatelessWidget {
  final Color color;
  const ClothingColorPicker(this.color, {Key? key}) : super(key: key);

  AlertDialog _colorPickerDialog(BuildContext context, BuildContext screenContext) {
    var lang = AppLocalizations.of(screenContext)!;

    Color pickerColor = color;
    return AlertDialog(
      title: Text(lang.select_color),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          enableAlpha: false,
          onColorChanged: (color) => pickerColor = color,
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text(lang.select_color),
          onPressed: () {
            BlocProvider.of<AddClothingCubit>(screenContext).changeColor(pickerColor);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        const SizedBox(width: 10),
        MaterialButton(
          child: Text(lang.change_color),
          color: Colors.grey.shade200,
          minWidth: 200,
          onPressed: () {
            showDialog(context: context, builder: (c) => _colorPickerDialog(c, context));
          },
        ),
      ],
    );
  }
}
