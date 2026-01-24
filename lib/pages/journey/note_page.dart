import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'note_controller.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoteController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "AI 寻迹成书",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
            const Text(
              "选择生成风格",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 风格选择网格
            _buildStyleGrid(controller),

            // 自定义提示词输入框
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.selectedStyle.value == "custom"
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextField(
                          onChanged: (value) =>
                              controller.customPrompt.value = value,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "在这里输入您的风格需求吧...",
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF009688),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 32),

            // 生成按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : () => controller.startGenerating(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isGenerating.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "开始创作",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 结果展示区域
            Obx(() {
              if (controller.generatedBody.isEmpty &&
                  !controller.isGenerating.value) {
                return _buildEmptyState();
              }
              return _buildResultCard(controller);
            }),
          ],
        ),
      ),
    );
  }

  // 风格选择小组件
  Widget _buildStyleGrid(NoteController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF009688).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF009688)
                      : Colors.transparent,
                  width: 2,
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
                      color: isSelected
                          ? const Color(0xFF009688)
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    style['desc']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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

  Widget _buildResultCard(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF009688), size: 20),
            SizedBox(width: 8),
            Text(
              "生成结果",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题部分
                controller.isEditing.value
                    ? TextField(
                        controller: controller.titleEditController,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入标题",
                        ),
                      )
                    : Text(
                        controller.generatedTitle.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const Divider(height: 32),
                // 正文部分
                controller.isEditing.value
                    ? TextField(
                        controller: controller.bodyEditController,
                        maxLines: null,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入内容",
                        ),
                      )
                    : Text(
                        controller.generatedBody.value,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                const SizedBox(height: 20),
                // 标签部分
                Wrap(
                  spacing: 8,
                  children: controller.hashtags
                      .map(
                        (t) => Text(
                          "#$t",
                          style: const TextStyle(color: Color(0xFF009688)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
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
                  child: Text(
                    controller.isEditing.value ? "保存修改" : "手动修改",
                    style: TextStyle(color: const Color(0xFF009688)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.shareToClipboard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                  ),
                  child: const Text(
                    "分享足迹",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.edit_note, size: 64, color: Colors.grey.shade200),
          const Text(
            "选个风格，让 AI 帮您回忆这段旅程吧",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
