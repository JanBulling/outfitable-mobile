// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outfitable_mobile_app/technologies/outfit_generator/outfit_alert_widget.dart';

import '../../../cubits/generate_outfit_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Outfitable", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Outfit of the Day",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              OutfitViewer(),
              TextButton(
                onPressed: () {},
                child: Text("Outfit Details  >", style: TextStyle(color: Colors.grey.shade700)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.bookmark, color: Colors.white),
                    label: Text("Save", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      BlocProvider.of<GenerateOutfitCubit>(context).generateRandomOutfit(null);
                    },
                    icon: Icon(Icons.casino, color: Colors.white),
                    label: Text("New Outfit", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Over the day",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}

class OutfitViewer extends StatelessWidget {
  const OutfitViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      width: double.infinity,
      child: BlocBuilder<GenerateOutfitCubit, OutfitState>(
        builder: (context, state) {
          if (state is SuccessOutfitState) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 425,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.favorite, color: Colors.red.shade700),
                ),
                Center(
                    child: Text(
                        "Top Type: ${state.outfit.upperClothing?.type ?? 'null'}    Lower Type: ${state.outfit.lowerClothing?.type ?? 'null'}")),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 395,
                  child: OutfitAlertWidge(state.outfit),
                ),
                Positioned(
                  top: 363,
                  right: 10,
                  child: Icon(Icons.crop_rotate, color: Colors.grey.shade500),
                ),
              ],
            );
          } else if (state is ErrorOutfitState) {
            return Container(
              width: double.infinity,
              height: 425,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
              child: Center(child: Text(state.message)),
            );
          } else {
            return Container(
              width: double.infinity,
              height: 425,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
