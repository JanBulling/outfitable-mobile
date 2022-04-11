import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../cubits/closet_cubit.dart';
import '../../../models/clothing/utils.dart';
import '../../../utils/routes.dart';

class ClosetTab extends StatelessWidget {
  const ClosetTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    void _addClothing() {
      Navigator.pushNamed(context, ROUTE_CLASSIFICATION);
    }

    void _addClothingManually() {
      Navigator.pushNamed(context, ROUTE_ADD_CLOTHING);
    }

    void _viewClosetDetails(int type) {
      Navigator.pushNamed(context, ROUTE_CLOSET_DETAILS, arguments: type);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.closet_tab),
        actions: [
          IconButton(onPressed: _addClothingManually, icon: const Icon(Icons.add)),
          IconButton(onPressed: _addClothing, icon: const Icon(Icons.document_scanner)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClothingManually,
        child: const Icon(Icons.add),
        tooltip: lang.add_new_clothing,
      ),
      body: BlocBuilder<ClosetCubit, ClosetState>(
        builder: (context, state) {
          if (state is SuccessClosetState) {
            return GridView.count(
              crossAxisCount: 2,
              children: state.clothing.keys.map((type) {
                return InkWell(
                  onTap: () => _viewClosetDetails(type),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(ClothingUtils.getTypeIconPath(type), width: 50, height: 50),
                      Text(lang.clothing_type(type)),
                      Text("Anzahl: ${state.clothing[type]}"),
                    ],
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
