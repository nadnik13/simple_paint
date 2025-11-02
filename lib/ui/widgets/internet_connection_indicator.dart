import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/internet_connection_cubit.dart';
import '../../bloc/internet_connection_state.dart';

class InternetConnectionIndicator extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const InternetConnectionIndicator({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetConnectionCubit, InternetConnectionState>(
      builder: (context, state) {
        if (!state.isVisible) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          height: kToolbarHeight + 20,
          duration: const Duration(milliseconds: 100),
          child: _buildIndicator(context, state),
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, InternetConnectionState state) {
    switch (state.status) {
      case ConnectionStatus.connected:
        return _buildStatusCard(
          context,
          icon: Icons.wifi,
          title: 'Вы подключены к интернету',
          backgroundColor: Colors.green,
        );

      case ConnectionStatus.connecting:
        return _buildStatusCard(
          context,
          icon: Icons.wifi_find,
          title: 'Подключение...',
          backgroundColor: Colors.lightBlueAccent,
        );

      case ConnectionStatus.disconnected:
        return _buildStatusCard(
          context,
          icon: Icons.wifi_off,
          title: 'Нет подключения к интернету',
          backgroundColor: Colors.red,
        );
    }
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
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
