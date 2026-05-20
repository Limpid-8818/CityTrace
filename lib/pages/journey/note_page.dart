import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/note_share_card.dart';
import '../../components/ui/info_pill.dart';
import '../../core/theme/app_colors.dart';
import 'note_controller.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoteController());

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          "AI 寻迹成书",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 固定顶部：风格选择 + 生成按钮 ===
            _buildStyleSection(controller),

            // === 有结果后显示的内容 ===
            Obx(() {
              if (controller.generatedBody.isEmpty && !controller.isGenerating.value) {
                // 无结果：显示空状态
                return _buildEmptyState();
              }
              // 有结果或生成中：显示 tag 切换 + 对应内容
              return _buildContentSection(controller);
            }),
          ],
        ),
      ),
    );
  }

  /// 固定顶部：风格选择 + 自定义提示 + 生成按钮
  Widget _buildStyleSection(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "选择生成风格",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),

        // 风格选择网格
        _buildStyleGrid(controller),

        // 自定义提示词输入框
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.selectedStyle.value == "custom"
                ? Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: TextField(
                      onChanged: (value) =>
                          controller.customPrompt.value = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "在这里输入您的风格需求吧...",
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        SizedBox(height: 32.r),

        // 生成按钮
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isGenerating.value
                  ? null
                  : () => controller.startGenerating(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: controller.isGenerating.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "开始创作",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// 有结果后的内容区域：loading / tag切换 + 对应面板
  Widget _buildContentSection(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),

        // 生成中 → 骨架屏
        if (controller.isGenerating.value && controller.generatedBody.isEmpty)
          _buildLoadingSkeleton()
        else ...[
          // === Tag 切换栏 ===
          SizedBox(height: 8.h),
          _buildTagBar(controller),
          SizedBox(height: 20.h),

          // === 根据当前 tag 显示不同内容 ===
          Obx(() {
            switch (controller.currentTabIndex.value) {
              case 0:
                return _buildNoteContentPanel(controller);
              case 1:
                return _buildNoteCardPanel(controller);
              default:
                return const SizedBox();
            }
          }),
        ],
      ],
    );
  }

  /// Tag 切换栏：游记内容 / 游记卡片
  Widget _buildTagBar(NoteController controller) {
    return Obx(
      () => Row(
        children: [
          _buildTagItem(controller, 0, Icons.edit_note, "游记内容"),
          SizedBox(width: 12.w),
          _buildTagItem(controller, 1, Icons.panorama_outlined, "游记卡片"),
        ],
      ),
    );
  }

  Widget _buildTagItem(
    NoteController controller,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = controller.currentTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.currentTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.r,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tag 0: 游记内容面板（标题 + 描述 + 正文 + 标签 + 操作按钮）
  Widget _buildNoteContentPanel(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 游记内容卡片
        _buildNoteContentCard(controller),

        SizedBox(height: 24.h),

        // 操作按钮组
        _buildActionButtons(controller),
      ],
    );
  }

  /// 游记内容卡片
  Widget _buildNoteContentCard(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              "游记内容",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                controller.isEditing.value
                    ? TextField(
                        controller: controller.titleEditController,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入标题",
                        ),
                      )
                    : Text(
                        controller.displayedTitle.value,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                SizedBox(height: 16.h),

                // 描述区域
                _buildDescriptionField(controller),

                SizedBox(height: 16.h),

                // 正文
                controller.isEditing.value
                    ? TextField(
                        controller: controller.bodyEditController,
                        maxLines: null,
                        style: TextStyle(fontSize: 15.sp, height: 1.6),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入内容",
                        ),
                      )
                    : Text(
                        controller.displayedBody.value,
                        style: TextStyle(fontSize: 15.sp, height: 1.6),
                      ),
                SizedBox(height: 20.h),
                // 标签
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: controller.hashtags
                      .map(
                        (t) => InfoPill(icon: Icons.tag, text: "#$t"),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 描述编辑区域
  Widget _buildDescriptionField(NoteController controller) {
    if (controller.isEditing.value) {
      return TextField(
        controller: controller.descriptionEditController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "行程简介（将显示在行程卡片上）",
          labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: EdgeInsets.all(12.r),
        ),
        style: TextStyle(fontSize: 14.sp, height: 1.5),
      );
    }

    if (controller.description.value.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.primaryOpacity005,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryOpacity010),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.description_outlined, size: 16.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                controller.description.value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.teal.shade800,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 操作按钮组
  Widget _buildActionButtons(NoteController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (controller.isEditing.value) {
                  controller.saveEdits();
                } else {
                  controller.enterEditMode();
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                controller.isEditing.value ? "保存修改" : "手动修改",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.shareToClipboard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                "分享足迹",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tag 1: 游记卡片面板（预览 + 导出）
  Widget _buildNoteCardPanel(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 游记卡片预览
        Center(
          child: RepaintBoundary(
            key: controller.noteShareCardKey,
            child: NoteShareCard(
              title: controller.displayedTitle.value,
              body: controller.displayedBody.value,
              hashtags: controller.hashtags.toList(),
              journeyTitle: controller.journey.value?.title,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // 导出操作按钮
        _buildNoteCardActions(controller),
      ],
    );
  }

  /// 游记卡片导出操作按钮
  Widget _buildNoteCardActions(NoteController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => _exportNoteCardAndShare(controller),
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: Text(
              "导出并分享游记卡片",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: OutlinedButton.icon(
            onPressed: () => _saveNoteCardToGallery(controller),
            icon: const Icon(Icons.download_outlined),
            label: Text(
              "保存游记卡片到相册",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 导出游记卡片并分享
  Future<void> _exportNoteCardAndShare(NoteController controller) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = controller.noteShareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/note_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: controller.journey.value != null
              ? '来自 CityTrace 的游记：${controller.journey.value!.title}'
              : '来自 CityTrace 的游记分享',
        ),
      );
    } catch (e) {
      debugPrint('游记卡片导出失败: $e');
      Get.snackbar("导出失败", "图片生成异常，请稍后重试");
    }
  }

  /// 保存游记卡片到相册
  Future<void> _saveNoteCardToGallery(NoteController controller) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          Get.snackbar("保存失败", "请在设置中授予相册访问权限");
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = controller.noteShareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      await Gal.putImageBytes(
        bytes,
        album: 'CityTrace',
        name: 'citytrace_note_${DateTime.now().millisecondsSinceEpoch}',
      );

      Get.snackbar("保存成功", "游记卡片已保存到手机相册");
    } on GalException catch (e) {
      debugPrint('保存到相册失败(GalException): $e');
      Get.snackbar("保存失败", "请检查相册权限后重试");
    } catch (e) {
      debugPrint('保存到相册失败: $e');
      Get.snackbar("保存失败", "请检查相册权限后重试");
    }
  }

  // ========== 以下为辅助组件 ==========

  Widget _buildStyleGrid(NoteController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
        childAspectRatio: 2.2,
      ),
      itemCount: controller.styleOptions.length,
      itemBuilder: (context, index) {
        final style = controller.styleOptions[index];
        return Obx(() {
          bool isSelected = controller.selectedStyle.value == style['id'];
          return GestureDetector(
            onTap: () => controller.selectedStyle.value = style['id']!,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOpacity010
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2.w,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    style['desc']!,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// 加载中的骨架屏
  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('loading'),
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              "AI 创作中...",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题骨架
              Container(
                width: 160.w,
                height: 22.sp,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 20.h),
              // 内容骨架 x3
              ...List.generate(3, (i) {
                final widths = [320.w, 280.w, 180.w];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    width: widths[i],
                    height: 14.sp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              }),
              SizedBox(height: 12.h),
              // 底部标签骨架
              Row(
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Container(
                      width: 50.w,
                      height: 16.sp,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          children: [
            Icon(Icons.edit_note, size: 64.r, color: Colors.grey.shade200),
            SizedBox(height: 16.h),
            const Text(
              "选个风格，让 AI 帮您回忆这段旅程吧",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}