import 'package:flutter/material.dart';

/// 图片预览页面：支持点击放大、双击缩放、左右滑动切换同一行程中的多张图片
class ImagePreviewPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePreviewPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;
  late List<TransformationController> _transformControllers;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _transformControllers = List.generate(
      widget.imageUrls.length,
      (_) => TransformationController(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _transformControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetOtherTransforms(int exceptIndex) {
    for (int i = 0; i < _transformControllers.length; i++) {
      if (i != exceptIndex && !_transformControllers[i].value.isIdentity()) {
        _transformControllers[i].value = Matrix4.identity();
      }
    }
  }

  void _onDoubleTap(int index) {
    final controller = _transformControllers[index];
    final currentScale = controller.value.getMaxScaleOnAxis();

    if (currentScale > 1.0) {
      // 双击缩小回原始大小
      controller.value = Matrix4.identity();
    } else {
      // 双击放大到 2.5 倍（以屏幕中心为缩放原点）
      final cx = MediaQuery.of(context).size.width / 2;
      final cy = MediaQuery.of(context).size.height / 2;
      const double s = 2.5;
      // 矩阵: 围绕(cx,cy)缩放s倍
      // [s 0 0 cx*(1-s)]
      // [0 s 0 cy*(1-s)]
      // [0 0 s 0       ]
      // [0 0 0 1       ]
      controller.value = Matrix4(
        s, 0, 0, 0,
        0, s, 0, 0,
        0, 0, s, 0,
        cx * (1 - s), cy * (1 - s), 0, 1,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 主体：左右滑动切换图片
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _resetOtherTransforms(index);
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildZoomableImage(index);
            },
          ),

          // 顶部关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // 底部图片计数器
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZoomableImage(int index) {
    return GestureDetector(
      onDoubleTap: () => _onDoubleTap(index),
      child: InteractiveViewer(
        transformationController: _transformControllers[index],
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(80),
        child: Center(
          child: Image.network(
            widget.imageUrls[index],
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              final total = loadingProgress.expectedTotalBytes;
              final progress = total != null
                  ? loadingProgress.cumulativeBytesLoaded / total
                  : null;
              return Center(
                child: CircularProgressIndicator(
                  value: progress,
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: Colors.white54, size: 64),
                  SizedBox(height: 8),
                  Text(
                    '图片加载失败',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}