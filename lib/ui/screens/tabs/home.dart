import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../cubits/generate_outfit_cubit.dart';
import '../../../cubits/weather_cubit.dart';
import '../../../models/clothing/outfit.dart';
import '../../../repositories/weather_repository.dart';
import '../../../technologies/outfit_generator/outfit_alert_widget.dart';
import '../../../technologies/outfit_generator/outfit_generator.dart';
import '../../../utils/dependency_injection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => WeatherCubit(injector<WeatherRepository>())..getWeather()),
        BlocProvider(create: (context) => GenerateOutfitCubit(injector<OutfitGenerator>())),
      ],
      child: BlocListener<WeatherCubit, WeatherState>(
        listener: (context, state) {
          if (state is SuccessWeatherState) {
            context.read<GenerateOutfitCubit>().generateDailyOutfit(state.weather.forecastday);
          } else if (state is ErrorWeatherState) {
            context.read<GenerateOutfitCubit>().generateDailyOutfit(null);
          }
        },
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    // Click-Callback for generating a random Outfit. Invokes the GnerateOutfitCubit.generateRandomOutfit() method
    void _generateRandomOutfit() {
      WeatherState currentState = BlocProvider.of<WeatherCubit>(context).state;

      if (currentState is SuccessWeatherState) {
        BlocProvider.of<GenerateOutfitCubit>(context).generateRandomOutfit(currentState.weather.forecastday);
      } else {
        BlocProvider.of<GenerateOutfitCubit>(context).generateRandomOutfit(null);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.daily_outfit,
                    style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                BlocBuilder<WeatherCubit, WeatherState>(
                  buildWhen: (_, state) => state is SuccessWeatherState,
                  builder: (_, state) {
                    if (state is SuccessWeatherState) {
                      return Row(
                        children: [
                          Text(
                            "${state.weather.current.temperature.round()}°C",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.cloud, color: Colors.grey.shade400),
                          Text(
                            "   ·   ${state.weather.current.timeString}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  height: 420,
                  child: BlocBuilder<GenerateOutfitCubit, OutfitState>(
                    builder: (_, state) {
                      if (state is SuccessOutfitState) {
                        return Column(
                          children: [
                            Text(
                                "Type: ${lang.clothing_type(state.outfit.upperClothing?.type ?? -1)}  Color: ${state.outfit.upperClothing?.color}"),
                            Text(
                                "Type: ${lang.clothing_type(state.outfit.lowerClothing?.type ?? -1)}  Color: ${state.outfit.lowerClothing?.color}"),
                            OutfitAlertWidge(state.outfit),
                          ],
                        );
                      } else if (state is ErrorOutfitState) {
                        return Center(child: Text(state.message));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark, color: Colors.white),
                      label: Text(lang.save_outfit, style: const TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _generateRandomOutfit,
                      icon: const Icon(Icons.casino, color: Colors.white),
                      label: Text(lang.new_outfit, style: const TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(lang.outfit_pieces, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                BlocBuilder<GenerateOutfitCubit, OutfitState>(
                  builder: (_, state) {
                    if (state is SuccessOutfitState) {
                      return Row(
                        children: [
                          Text("Piece 1: ${state.outfit.upperClothing?.type}"),
                          Text("Piece 2: ${state.outfit.lowerClothing?.type}"),
                        ],
                      );
                    } else if (state is ErrorOutfitState) {
                      return Center(child: Text(state.message));
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OutfitDisplay extends StatelessWidget {
  final Outfit outfit;

  const OutfitDisplay(this.outfit, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Container(
      height: 405,
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text("Type: ${lang.clothing_type(outfit.upperClothing?.type ?? -1)}  Color: ${outfit.upperClothing?.color}"),
          Text("Type: ${lang.clothing_type(outfit.lowerClothing?.type ?? -1)}  Color: ${outfit.lowerClothing?.color}")
        ],
      ),
    );
  }
}
