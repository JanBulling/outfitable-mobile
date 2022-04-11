import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:outfitable_mobile_app/utils/routes.dart';

import '../../cubits/classifcation_cubit.dart';
import '../../cubits/tensorflow_cubit.dart';
import '../../services/tensorflow_service.dart';
import '../../utils/dependency_injection.dart';
import '../widgets/image_classification_widget.dart';

class ClassificationScreen extends StatelessWidget {
  const ClassificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ClassificationCubit()),
        BlocProvider(create: (context) => TensorflowCubit(injector<TensorflowService>())),
      ],
      child: BlocListener<TensorflowCubit, TensorflowState>(
        listener: (context, state) {
          print("State in classification: $state");

          if (state is SuccessTensorflowState) {
            context.read<ClassificationCubit>().processResult(state.results, state.color);
          } else if (state is ErrorTensorflowState) {
            context.read<ClassificationCubit>().emitError(state.message);
          } else {
            context.read<ClassificationCubit>().emitLoading();
          }
        },
        child: const ClassificationView(),
      ),
    );
  }
}

class ClassificationView extends StatelessWidget {
  const ClassificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;

    void _selectClothing(int type, Color color) {
      Navigator.of(context).popAndPushNamed(
        ROUTE_ADD_CLOTHING,
        arguments: {
          "type": type,
          "color": color,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Image Classification")),
      body: Column(
        children: [
          const ImageClassifier(),
          BlocBuilder<ClassificationCubit, ClassificationState>(builder: (_, state) {
            if (state is SuccessClassificationState) {
              return Row(
                children: [
                  SvgPicture.asset("assets/icons/tshirt.svg"),
                  Text("Detected: ${state.resultType}"),
                  MaterialButton(
                    child: const Text("Choose Clothing"),
                    onPressed: () => _selectClothing(state.resultType, state.color),
                  )
                ],
              );
            } else if (state is ErrorClassificationState) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        ],
      ),
    );
  }
}