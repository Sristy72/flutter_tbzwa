import '../../../core/utils/app_snackbar.dart';
import '../../instructor/controllers/instructor_messages_controller.dart';
import '../../instructor/models/instructor_message_model.dart';
import '../../instructor/services/instructor_messages_service.dart';
import 'package:get/get.dart';

class CommunityMessagesController extends InstructorMessagesController {
  CommunityMessagesController() : super(includeGroups: false);

  final InstructorMessagesService _communityMessageService =
      InstructorMessagesService();

  final selectedConversationIds = <String>{}.obs;
  final isDeletingConversations = false.obs;
  final hasLoadedConversationBaseline = false.obs;
  final hasAnyConversation = false.obs;

  bool get isSelectionMode => selectedConversationIds.isNotEmpty;
  int get selectedConversationCount => selectedConversationIds.length;

  bool isConversationSelected(String conversationId) {
    return selectedConversationIds.contains(conversationId);
  }

  void startConversationSelection(InstructorConversation conversation) {
    if (conversation.id.isEmpty) return;
    selectedConversationIds
      ..clear()
      ..add(conversation.id);
  }

  void toggleConversationSelection(InstructorConversation conversation) {
    if (conversation.id.isEmpty) return;
    if (selectedConversationIds.contains(conversation.id)) {
      selectedConversationIds.remove(conversation.id);
    } else {
      selectedConversationIds.add(conversation.id);
    }
  }

  void clearConversationSelection() {
    selectedConversationIds.clear();
  }

  @override
  Future<void> loadConversations({bool refresh = false}) async {
    await super.loadConversations(refresh: refresh);
    _updateConversationBaseline();
    _pruneSelection();
  }

  Future<bool> deleteSelectedConversations() async {
    if (isDeletingConversations.value || selectedConversationIds.isEmpty) {
      return false;
    }

    final ids = selectedConversationIds.toList(growable: false);
    isDeletingConversations.value = true;
    try {
      final result = await _communityMessageService.deleteConversationsForMe(
        ids,
      );
      final hiddenIds = result.hiddenConversationIds.toSet();
      if (hiddenIds.isEmpty) {
        throw Exception('No conversations were deleted.');
      }

      conversations.removeWhere(
        (conversation) => hiddenIds.contains(conversation.id),
      );
      selectedConversationIds.removeAll(hiddenIds);
      _updateConversationBaseline(forceFromCurrentList: true);

      if (hiddenIds.length == ids.length) {
        final count = hiddenIds.length;
        clearConversationSelection();
        AppSnackbar.success(
          'Messages',
          count == 1
              ? 'Conversation deleted successfully.'
              : '$count conversations deleted successfully.',
        );
        return true;
      }

      _pruneSelection();
      AppSnackbar.error('Messages', 'Some conversations could not be deleted.');
      return false;
    } catch (error) {
      AppSnackbar.error('Messages', error);
      _pruneSelection();
      return false;
    } finally {
      isDeletingConversations.value = false;
    }
  }

  @override
  void onClose() {
    clearConversationSelection();
    super.onClose();
  }

  void _updateConversationBaseline({bool forceFromCurrentList = false}) {
    if (errorMessage.value.isNotEmpty) return;
    if (searchController.text.trim().isNotEmpty && !forceFromCurrentList) {
      return;
    }
    hasLoadedConversationBaseline.value = true;
    hasAnyConversation.value = conversations.isNotEmpty;
  }

  void _pruneSelection() {
    if (selectedConversationIds.isEmpty) return;
    final visibleIds = conversations
        .map((conversation) => conversation.id)
        .toSet();
    selectedConversationIds.removeWhere((id) => !visibleIds.contains(id));
  }
}
