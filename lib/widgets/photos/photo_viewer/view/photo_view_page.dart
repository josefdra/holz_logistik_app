import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/widgets/photos/photo_viewer/photo_viewer.dart';
import 'package:holz_logistik_backend/repository/photo_repository.dart';

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({
    required this.photos,
    super.key,
  });

  final List<Photo> photos;

  static Route<void> route({
    required int currentIndex,
    required List<Photo> photos,
  }) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => PhotoViewBloc(
          initialIndex: currentIndex,
        ),
        child: PhotoViewPage(photos: photos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoViewBloc, PhotoViewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${state.currentIndex + 1} / ${photos.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PageView.builder(
            controller: context.read<PhotoViewBloc>().pageController,
            itemCount: photos.length,
            onPageChanged: (index) {
              context.read<PhotoViewBloc>().add(PhotoViewIndexChanged(index));
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.memory(
                      photos[index].photoFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
