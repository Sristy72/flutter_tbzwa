import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/widgets/button_widgets.dart';
import '../controllers/instructor_home_controller.dart';
import '../controllers/instructor_rooms_controller.dart';

typedef CreateRoomHandler =
    Future<void> Function({
      required String name,
      required String groupId,
      required String privacy,
    });

class CreateRoomGroupOption {
  final String id;
  final String name;

  const CreateRoomGroupOption({required this.id, required this.name});
}

class CreateRoomDialog extends StatefulWidget {
  final List<CreateRoomGroupOption> groups;
  final CreateRoomHandler onCreateRoom;

  CreateRoomDialog({super.key, required InstructorHomeController controller})
    : groups = controller.assignedGroups
          .map((group) => CreateRoomGroupOption(id: group.id, name: group.name))
          .toList(),
      onCreateRoom = controller.createRoom;

  CreateRoomDialog.forRooms({
    super.key,
    required InstructorRoomsController controller,
  }) : groups = controller.assignedGroups
           .map(
             (group) => CreateRoomGroupOption(id: group.id, name: group.name),
           )
           .toList(),
       onCreateRoom = controller.createRoom;

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _roomNameController = TextEditingController();
  String? _selectedGroup;
  String _privacy = "Public";

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Room",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),

            // Room Name
            _buildLabel("Room Name"),
            const SizedBox(height: 8),
            TextField(
              controller: _roomNameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "e.g. Math Study Group",
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Assign to Group
            _buildLabel("Assign to Group"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedGroup,
              hint: const Text(
                "Select a group",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6B7280),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 14),
              items: groups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text(
                    group.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroup = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Privacy
            _buildLabel("Privacy"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRadioTile("Public (Group members)", "Public"),
                ),
                Expanded(
                  child: _buildRadioTile("Private (Invite only)", "Private"),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Create Room",
                    onApiPressed: () => widget.onCreateRoom(
                      name: _roomNameController.text,
                      groupId: _selectedGroup ?? '',
                      privacy: _privacy,
                    ),
                    height: 48,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _privacy = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _privacy,
            onChanged: (newValue) {
              setState(() {
                _privacy = newValue!;
              });
            },
            activeColor: const Color(0xFF5151EF),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF5151EF);
              }
              return const Color(0xFF9CA3AF); // Gray for initial/unselected
            }),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }
}
