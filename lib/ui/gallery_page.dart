import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_event.dart';
import 'package:simple_paint/bloc/gallery_bloc.dart';
import 'package:simple_paint/bloc/gallery_event.dart';
import 'package:simple_paint/bloc/gallery_state.dart';
import 'package:simple_paint/data/preview_item.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';

import '../bloc/account_data_bloc.dart';
import '../bloc/account_data_state.dart';
import '../bloc/image_bloc.dart';
import '../bloc/image_event.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Image.asset('assets/logout.png'),
          onPressed: () {
            context.read<AccountDataBloc>().add(LogoutEvent());
            context.read<GalleryBloc>().add(ClearImagesEvent());
            context.go('/auth');
          },
        ),
        title: Text('Галерея', style: TextStyle(color: Color(0xEEEEEEEE))),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ImageBloc>().add(ClearImageEvent());
              context.go('/gallery/draw', extra: null);
            },
            icon: Image.asset('assets/draw.png'),
          ),
          // IconButton(
          //   onPressed: () {
          //     final accountState = context.read<AccountDataBloc>().state;
          //     if (accountState is AccountDataAuthenticated) {
          //       print('Manual refresh triggered');
          //       context.read<GalleryBloc>().add(RefreshImagesEvent());
          //     }
          //   },
          //   icon: Icon(Icons.refresh, color: Color(0xEEEEEEEE)),
          // ),
        ],
      ),
      child: BlocListener<AccountDataBloc, AccountDataState>(
        listener: (context, accountState) {
          print('AccountDataBloc state changed: ${accountState.runtimeType}');
          if (accountState is AccountDataAuthenticated) {
            context.read<GalleryBloc>().add(LoadUserImagesEvent());
          } else if (accountState is AccountDataUnauthenticated) {
            context.read<GalleryBloc>().add(ClearImagesEvent());
          }
        },
        child: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GalleryState state) {
    if (state is GalleryInitialState) {
      final accountState = context.read<AccountDataBloc>().state;
      if (accountState is AccountDataAuthenticated) {
        context.read<GalleryBloc>().add(LoadUserImagesEvent());
      }
    }
    if (state is GalleryLoadingState) {
      print('Showing loading state');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Загружаем ваши изображения...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is ImageLoaderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final accountState = context.read<AccountDataBloc>().state;
                if (accountState is AccountDataAuthenticated) {
                  context.read<GalleryBloc>().add(RefreshImagesEvent());
                }
              },
              child: Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (state is ImageLoaderEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'У вас пока нет сохраненных изображений',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/gallery/draw'),
              child: Text('Создать первый рисунок'),
            ),
          ],
        ),
      );
    }

    if (state is GalleryLoadedState) {
      return _buildImageGrid(context, state.images);
    }

    // ImageLoaderInitial или неизвестное состояние
    return const Center(child: Text('Инициализация...'));
  }

  Widget _buildImageGrid(BuildContext context, List<ImageInfoItem> items) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GalleryBloc>().add(RefreshImagesEvent());
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 46),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: items.length,
        itemBuilder:
            (_, i) => GestureDetector(
              onTap: () async {
                context.read<ImageBloc>().add(
                  LoadOriginalImageEvent(
                    imageId: items[i].imageId,
                    userId: items[i].userId,
                  ),
                );
                context.go('/gallery/draw', extra: items[i].imageId);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    items[i].thumb,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    cacheWidth: 256,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
