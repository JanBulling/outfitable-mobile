import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../cubits/closet_details_cubit.dart';
import '../../models/clothing/utils.dart';
import '../../services/closet_service.dart';
import '../../utils/dependency_injection.dart';

class ClosetDetailsScreen extends StatelessWidget {
  final int _type;

  const ClosetDetailsScreen(this._type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClosetDetailsCubit(injector<ClosetService>())..loadClothing(_type),
      child: ClosetDetailsView(_type),
    );
  }
}

class ClosetDetailsView extends StatelessWidget {
  final int _type;

  const ClosetDetailsView(this._type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.clothing_type(_type)),
      ),
      body: BlocBuilder<ClosetDetailsCubit, ClosetDetailsState>(
        builder: (_, state) {
          if (state is SuccessClosetDetailsState) {
            return GridView.count(
              crossAxisCount: 2,
              children: state.clothing.map((clothing) {
                return InkWell(
                  onTap: () {},
                  child: SvgPicture.asset(
                    ClothingUtils.getTypeIconPath(_type),
                    width: 50,
                    height: 50,
                    color: clothing.color,
                  ),
                );
              }).toList(),
            );
          } else if (state is ErrorClosetDetailsState) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
