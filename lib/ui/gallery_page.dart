import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/gallery_bloc.dart';
import 'package:simple_paint/bloc/gallery_event.dart';
import 'package:simple_paint/bloc/gallery_state.dart';
import 'package:simple_paint/data/preview_item.dart';
import 'package:simple_paint/ui/widgets/custom_button.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';

import '../bloc/account_data_bloc.dart';
import '../bloc/account_data_event.dart';
import '../bloc/account_data_state.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryBloc _galleryBloc;
  @override
  void initState() {
    super.initState();
    _galleryBloc = context.read<GalleryBloc>()..add(LoadGalleryEvent());
  }

  @override
  void dispose() {
    _galleryBloc.add(ClearGalleryEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state is GalleryLoadingState) {
          return ScaffoldWithBackground(
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Изображение загружается...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        return ScaffoldWithBackground(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Image.asset('assets/logout.png'),
              onPressed: () {
                context.read<AccountDataBloc>().add(LogoutEvent());
                context.go('/auth');
              },
            ),
            title: Text('Галерея', style: TextStyle(color: Color(0xEEEEEEEE))),
            actions: [
              if (state is! GalleryIsEmpty)
                IconButton(
                  onPressed: () async {
                    await context.push('/gallery/draw', extra: null);
                    context.read<GalleryBloc>().add(RefreshGalleryEvent());
                  },
                  icon: Image.asset('assets/draw.png'),
                ),
            ],
          ),
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, GalleryState state) {
    if (state is GalleryLoadingError) {
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
                  context.read<GalleryBloc>().add(RefreshGalleryEvent());
                }
              },
              child: Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (state is GalleryIsEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                title: 'Создать',
                isDark: true,
                onPressed: () async {
                  await context.push('/gallery/draw', extra: null);
                  context.read<GalleryBloc>().add(RefreshGalleryEvent());
                },
              ),
            ],
          ),
        ),
      );
    }

    if (state is GalleryLoadedState) {
      return _buildImageGrid(context, state.images);
    }

    return const Center(child: Text('Инициализация...'));
  }

  Widget _buildImageGrid(BuildContext context, List<ImageInfoItem> items) {
    return RefreshIndicator(
      onRefresh: () async {
        final completer = Completer();
        context.read<GalleryBloc>().add(
          RefreshGalleryEvent(completer: completer),
        );
        return completer.future;
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
                await context.push('/gallery/draw', extra: items[i].imageId);
                context.read<GalleryBloc>().add(RefreshGalleryEvent());
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
