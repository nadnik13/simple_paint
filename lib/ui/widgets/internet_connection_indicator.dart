import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/internet_connection_cubit.dart';
import '../../bloc/internet_connection_state.dart';

class InternetConnectionIndicator extends StatefulWidget {
  final EdgeInsetsGeometry? margin;

  const InternetConnectionIndicator({super.key, this.margin});

  @override
  State<InternetConnectionIndicator> createState() =>
      _InternetConnectionIndicatorState();
}

class _InternetConnectionIndicatorState
    extends State<InternetConnectionIndicator> {
  late bool _isVisible;
  Timer? _hideIndicatorTimer;

  @override
  void initState() {
    _isVisible =
        context.read<InternetConnectionCubit>().state !=
        ConnectionStatus.connected;
    super.initState();
  }

  void _hideAfterDelay() {
    _hideIndicatorTimer = Timer(const Duration(seconds: 5), () {
      _isVisible = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _show() {
    _hideIndicatorTimer?.cancel();
    _isVisible = true;
  }

  @override
  void dispose() {
    _hideIndicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetConnectionCubit, ConnectionStatus>(
      listener: (context, state) {},
      listenWhen: (prev, current) {
        if (prev == current) {
          return false;
        }
        if (prev != ConnectionStatus.connected &&
            current == ConnectionStatus.connected) {
          _hideAfterDelay();
          return true;
        }
        _show();
        return true;
      },
      child: BlocBuilder<InternetConnectionCubit, ConnectionStatus>(
        //TODO1 надо использовать buildWhen
        //buildWhen: ,
        builder: (context, state) {
          if (!_isVisible) {
            return const SizedBox.shrink();
          }

          return AnimatedContainer(
            height: kToolbarHeight + 20,
            duration: const Duration(milliseconds: 100),
            child: _buildIndicator(context, state),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, ConnectionStatus state) {
    switch (state) {
      case ConnectionStatus.connected:
        return _buildStatusCard(
          context,
          title: 'Вы подключены к интернету',
          backgroundColor: Colors.green,
        );

      case ConnectionStatus.connecting:
        return _buildStatusCard(
          context,
          title: 'Подключение...',
          backgroundColor: Colors.lightBlueAccent,
        );

      case ConnectionStatus.disconnected:
        return _buildStatusCard(
          context,
          title: 'Нет подключения к интернету',
          backgroundColor: Colors.red,
        );
    }
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    Color color = Colors.white,
    required Color backgroundColor,
  }) {
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.zero,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.s,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
