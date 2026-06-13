import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/expanded_category_selector.dart';
import '../controllers/normal_controller.dart';

const _normalOffWhite = Color(0xFFFAFBF9);
const _normalForest = Color(0xFF145C4F);
const _normalWarmDark = Color(0xFF4A342B);
const _normalMuted = Color(0xFFA89890);
const _normalBorder = Color(0x1F145C4F);
const _normalRowTint = Color(0xFFF7FAF8);
const _normalSageTint = Color(0xFFF5F8F6);
const _normalAvatarBg = Color(0xFFEBF0EE);

class _NormalReplyItem {
  _NormalReplyItem({
    required this.id,
    required this.handle,
    required this.text,
    required this.time,
    required this.likes,
    required this.liked,
    this.isNew = false,
    this.isOwn = false,
  });

  final String id;
  final String handle;
  final String text;
  final String time;
  int likes;
  bool liked;
  bool isNew;
  final bool isOwn;
}

String _normalVoiceLabel(int count) {
  if (count <= 0) return 'VOICES';
  if (count == 1) return '1 VOICE';
  return '$count VOICES';
}

class NormalView extends StatefulWidget {
  const NormalView({super.key});

  @override
  State<NormalView> createState() => _NormalViewState();
}

class _NormalViewState extends State<NormalView> {
  late final PageController _pageController;
  final ScrollController _threadScrollController = ScrollController();
  final TextEditingController _replyController = TextEditingController();
  final Set<String> _likedTopics = <String>{};
  final Map<String, int> _topicLikeDeltas = <String, int>{};
  int _active = 0;
  bool _categoriesExpanded = false;
  bool _threadOpen = false;
  bool _composerOpen = false;
  bool _composerPosting = false;
  bool _composerPosted = false;
  NormalTopicItem? _threadTopic;
  List<_NormalReplyItem> _threadReplies = <_NormalReplyItem>[];
  int _visibleReplyCount = 3;
  static const int _replyStep = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _threadScrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NormalController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
          final topics = controller.topics;
          if (topics.isEmpty) {
            return Center(
              child: Text(
                'No topics yet for this category.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= topics.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final categories = controller.categories;
          final selectedCategory = controller.selectedCategory.value;
          final currentNumber = (_active + 1).toString().padLeft(2, '0');
          final totalNumber = topics.length.toString().padLeft(2, '0');

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: Get.back,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'is this normal',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: const Color(0xFFA3A3A3),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$currentNumber / $totalNumber',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: const Color(0xFFA3A3A3),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExpandedCategorySelector(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    expanded: _categoriesExpanded,
                    labelBuilder: controller.categoryLabel,
                    onExpandedChanged: (expanded) =>
                        setState(() => _categoriesExpanded = expanded),
                    onSelect: (category) {
                      controller.selectCategory(category);
                      _active = 0;
                      _categoriesExpanded = false;
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Row(
                      children: [
                        _InlineTab(
                          label: 'most felt',
                          active: controller.sortMode.value == 'felt',
                          onTap: () => controller.setSortMode('felt'),
                        ),
                        const SizedBox(width: 24),
                        _InlineTab(
                          label: 'latest',
                          active: controller.sortMode.value == 'latest',
                          onTap: () => controller.setSortMode('latest'),
                        ),
                        const Spacer(),
                        _InlineTab(
                          label: 'ASK ANONYMOUSLY',
                          active: true,
                          onTap: controller.openAskQuestion,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  Expanded(
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: topics.length,
                          onPageChanged: (value) =>
                              setState(() => _active = value),
                          itemBuilder: (context, index) => _NormalSlide(
                            topic: topics[index],
                            category: controller
                                .categoryLabel(topics[index].tab)
                                .toUpperCase(),
                            voicesCount:
                                controller.voicesFor(topics[index]).length,
                            onOpen: () => _openThread(
                              controller: controller,
                              topic: topics[index],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: _VerticalProgress(
                              total: topics.length,
                              active: _active,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              AnimatedSlide(
                offset: _threadOpen ? Offset.zero : const Offset(1, 0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _buildThreadOverlay(context, controller),
              ),
              if (_composerOpen)
                GestureDetector(
                  onTap: _closeComposer,
                  child: Container(color: Colors.black.withOpacity(0.15)),
                ),
              AnimatedSlide(
                offset: _composerOpen ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildComposerSheet(context, controller),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _openThread({
    required NormalController controller,
    required NormalTopicItem topic,
  }) {
    final replies = _repliesFor(topic, controller);
    setState(() {
      _threadTopic = topic;
      _threadReplies = replies;
      _visibleReplyCount = math.min(replies.length, _replyStep);
      _threadOpen = true;
    });
  }

  void _closeThread() {
    _closeComposer();
    setState(() {
      _threadOpen = false;
      _threadTopic = null;
      _threadReplies = <_NormalReplyItem>[];
      _visibleReplyCount = _replyStep;
    });
  }

  List<_NormalReplyItem> _repliesFor(
    NormalTopicItem topic,
    NormalController controller,
  ) {
    final key = _topicKey(topic);
    final voices = controller.voicesFor(topic);
    return voices
        .asMap()
        .entries
        .map(
          (entry) => _NormalReplyItem(
            id: '${key}_${entry.key}_${entry.value.hashCode}',
            handle: '@community',
            text: entry.value,
            time: '',
            likes: 0,
            liked: false,
          ),
        )
        .toList()
        .reversed
        .toList();
  }

  void _openComposer() {
    setState(() {
      _composerOpen = true;
      _composerPosting = false;
      _composerPosted = false;
    });
    _replyController.clear();
  }

  void _closeComposer() {
    if (!_composerOpen && !_composerPosting && !_composerPosted) return;
    setState(() {
      _composerOpen = false;
      _composerPosting = false;
      _composerPosted = false;
    });
    _replyController.clear();
  }

  Future<void> _postReply(NormalController controller) async {
    final topic = _threadTopic;
    final text = _replyController.text.trim();
    if (topic == null || text.isEmpty || _composerPosting) return;

    setState(() => _composerPosting = true);
    final saved = await controller.addVoiceFor(topic: topic, voice: text);
    if (!mounted) return;

    if (!saved) {
      setState(() => _composerPosting = false);
      return;
    }

    final reply = _NormalReplyItem(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      handle: '@you',
      text: text,
      time: 'now',
      likes: 0,
      liked: false,
      isNew: true,
      isOwn: true,
    );

    setState(() {
      _composerPosted = true;
      _threadReplies.insert(0, reply);
      _visibleReplyCount =
          math.min(_visibleReplyCount + 1, _threadReplies.length);
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    _closeComposer();

    if (_threadScrollController.hasClients) {
      await _threadScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => reply.isNew = false);
    }
  }

  void _toggleTopicLike(NormalTopicItem topic) {
    final key = _topicKey(topic);
    setState(() {
      if (_likedTopics.contains(key)) {
        _likedTopics.remove(key);
        _topicLikeDeltas[key] = (_topicLikeDeltas[key] ?? 0) - 1;
      } else {
        _likedTopics.add(key);
        _topicLikeDeltas[key] = (_topicLikeDeltas[key] ?? 0) + 1;
      }
    });
  }

  void _toggleReplyLike(String replyId) {
    setState(() {
      _NormalReplyItem? reply;
      for (final item in _threadReplies) {
        if (item.id == replyId) {
          reply = item;
          break;
        }
      }
      if (reply == null) return;
      reply.liked = !reply.liked;
      reply.likes += reply.liked ? 1 : -1;
    });
  }

  void _loadMoreReplies() {
    setState(() {
      _visibleReplyCount =
          math.min(_visibleReplyCount + _replyStep, _threadReplies.length);
    });
  }

  String _topicKey(NormalTopicItem topic) {
    return topic.question
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  int _topicLikeCount(NormalTopicItem topic) {
    return math.max(0, topic.metoo + (_topicLikeDeltas[_topicKey(topic)] ?? 0));
  }

  String _voiceLabel(int count) {
    return _normalVoiceLabel(count);
  }

  String _countLabel(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }

  Widget _buildThreadOverlay(
    BuildContext context,
    NormalController controller,
  ) {
    final topic = _threadTopic;
    if (topic == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final visible = _threadReplies.take(_visibleReplyCount).toList();
    final remaining = _threadReplies.length - visible.length;
    final voicesLabel = _voiceLabel(_threadReplies.length);

    return Container(
      color: _normalOffWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
            child: Row(
              children: [
                InkWell(
                  onTap: _closeThread,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 15,
                        color: _normalForest,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IS THIS NORMAL',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: _normalForest,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  voicesLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.terracotta,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _normalBorder),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  controller: _threadScrollController,
                  padding: const EdgeInsets.only(bottom: 76),
                  children: [
                    _buildOriginalPost(context, topic),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 18, 28, 10),
                      child: Text(
                        voicesLabel,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: _normalMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: _normalBorder),
                    if (_threadReplies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 36, 28, 18),
                        child: Text(
                          'Be the first to add your voice.',
                          style: textTheme.displaySmall?.copyWith(
                            color: _normalMuted,
                            fontSize: 22,
                            height: 1.35,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ...visible.asMap().entries.map(
                          (entry) => _buildReplyRow(
                            context,
                            entry.value,
                            entry.key,
                          ),
                        ),
                    if (remaining > 0)
                      InkWell(
                        onTap: _loadMoreReplies,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                          child: Text(
                            'LOAD $remaining MORE ${remaining == 1 ? 'REPLY' : 'REPLIES'}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: _normalForest,
                              letterSpacing: 1.2,
                              decoration: TextDecoration.underline,
                              decorationColor: _normalForest,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildStickyReplyBar(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalPost(BuildContext context, NormalTopicItem topic) {
    final textTheme = Theme.of(context).textTheme;
    final liked = _likedTopics.contains(_topicKey(topic));
    final likes = _topicLikeCount(topic);

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _normalBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.tab.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.terracotta,
              letterSpacing: 1.5,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '"${topic.question}"',
            style: textTheme.displaySmall?.copyWith(
              color: _normalWarmDark,
              height: 1.25,
              fontSize: 24,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _toggleTopicLike(topic),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      size: 17,
                      color: liked ? AppColors.terracotta : _normalMuted,
                    ),
                    if (likes > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        _countLabel(likes),
                        style: textTheme.bodySmall?.copyWith(
                          color: liked ? AppColors.terracotta : _normalMuted,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyRow(
    BuildContext context,
    _NormalReplyItem reply,
    int index,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final initial = reply.isOwn
        ? 'Y'
        : (reply.handle.replaceAll('@', '').isEmpty
            ? 'C'
            : reply.handle.replaceAll('@', '')[0].toUpperCase());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      color: reply.isNew
          ? AppColors.terracotta.withOpacity(0.05)
          : (index.isEven ? Colors.white : _normalRowTint),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                color: reply.isOwn ? _normalForest : _normalAvatarBg,
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: textTheme.bodySmall?.copyWith(
                    color: reply.isOwn ? Colors.white : _normalForest,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reply.handle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: reply.isOwn ? AppColors.terracotta : _normalForest,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (reply.time.isNotEmpty)
                Text(
                  reply.time,
                  style: textTheme.bodySmall?.copyWith(
                    color: _normalMuted,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              reply.text,
              style: textTheme.bodyMedium?.copyWith(
                color: _normalWarmDark,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _toggleReplyLike(reply.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        reply.liked ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color:
                            reply.liked ? AppColors.terracotta : _normalMuted,
                      ),
                      if (reply.likes > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          reply.likes.toString(),
                          style: textTheme.bodySmall?.copyWith(
                            color: reply.liked
                                ? AppColors.terracotta
                                : _normalMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: _openComposer,
                  child: Text(
                    'REPLY',
                    style: textTheme.bodySmall?.copyWith(
                      color: _normalMuted,
                      fontSize: 10,
                      letterSpacing: 1,
                      decoration: TextDecoration.underline,
                      decorationColor: _normalMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyReplyBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: _normalOffWhite,
        border: Border(top: BorderSide(color: _normalBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _openComposer,
              child: Text(
                'Add to the conversation...',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: _normalWarmDark.withOpacity(0.35),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _openComposer,
            child: Text(
              'REPLY',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
                fontSize: 11,
                letterSpacing: 1.2,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.terracotta,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerSheet(
    BuildContext context,
    NormalController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final charCount = _replyController.text.length;
    final canPost =
        _replyController.text.trim().isNotEmpty && !_composerPosting;

    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          28,
          24,
          28,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: _composerPosted
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    color: _normalForest,
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'REPLY POSTED',
                    style: textTheme.bodySmall?.copyWith(
                      color: _normalMuted,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ADD YOUR VOICE',
                        style: textTheme.bodySmall?.copyWith(
                          color: _normalWarmDark,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _closeComposer,
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: _normalMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    color: _normalSageTint,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPLYING TO',
                          style: textTheme.bodySmall?.copyWith(
                            color: _normalMuted,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${_threadTopic?.question ?? ''}"',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.displaySmall?.copyWith(
                            color: _normalMuted,
                            fontSize: 16,
                            height: 1.35,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _replyController,
                    maxLength: 280,
                    maxLines: 3,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _normalWarmDark,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: _normalWarmDark.withOpacity(0.35),
                        fontSize: 14,
                      ),
                      counterText: '',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _normalBorder),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _normalForest.withOpacity(0.35),
                        ),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        '$charCount / 280',
                        style: textTheme.bodySmall?.copyWith(
                          color: charCount >= 240
                              ? AppColors.terracotta
                              : _normalMuted,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: canPost ? () => _postReply(controller) : null,
                        child: Opacity(
                          opacity: canPost ? 1 : 0.35,
                          child: Container(
                            color: _normalForest,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              _composerPosting ? 'POSTING...' : 'POST REPLY',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _NormalSlide extends StatelessWidget {
  const _NormalSlide({
    required this.topic,
    required this.category,
    required this.voicesCount,
    required this.onOpen,
  });

  final NormalTopicItem topic;
  final String category;
  final int voicesCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 104, 42, 12),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '"${topic.question}"',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  color: const Color(0xFF3B2C24),
                  height: 1.2,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 32,
                height: 1,
                color: const Color(0xFFE6E6E6),
              ),
              const SizedBox(height: 20),
              Text(
                '${topic.metoo} felt this',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA3A3A3),
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _InlineTab(
                    label: 'READ CONTEXT',
                    active: true,
                    onTap: onOpen,
                  ),
                  const SizedBox(width: 24),
                  _InlineTab(
                    label: _normalVoiceLabel(voicesCount),
                    active: false,
                    onTap: onOpen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalProgress extends StatelessWidget {
  const _VerticalProgress({
    required this.total,
    required this.active,
  });

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    const maxBars = 6;
    final bars = total <= 1 ? 2 : total.clamp(2, maxBars);
    final mapped = total <= 1
        ? 0
        : ((active / (total - 1)) * (bars - 1)).round().clamp(0, bars - 1);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(bars, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == bars - 1 ? 0 : 8),
            child: Container(
              width: 2,
              height: 24,
              color: index == mapped
                  ? AppColors.terracotta
                  : const Color(0xFFE6E6E6),
            ),
          );
        }),
      ),
    );
  }
}

class _InlineTab extends StatelessWidget {
  const _InlineTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.terracotta : const Color(0xFFDCD6D2),
              width: active ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: active ? AppColors.terracotta : const Color(0xFFA3A3A3),
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }
}
