import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/voice_room_controller.dart';

class CreateVoiceRoomDialog extends StatefulWidget {
  final LearnerVoiceRoomController controller;

  const CreateVoiceRoomDialog({super.key, required this.controller});

  @override
  State<CreateVoiceRoomDialog> createState() => _CreateVoiceRoomDialogState();
}

class _CreateVoiceRoomDialogState extends State<CreateVoiceRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _privacy = 'public';
  int _maxParticipants = 20;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Voice Room',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              _buildLabel('Room Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                maxLength: 80,
                style: const TextStyle(color: Color(0xFF1F2937)),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Room name is required.';
                  if (trimmed.length > 80) {
                    return 'Room name cannot exceed 80 characters.';
                  }
                  return null;
                },
                decoration: _inputDecoration('Conversation Practice'),
              ),
              const SizedBox(height: 12),
              _buildLabel('Privacy'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _privacy,
                dropdownColor: Colors.white,
                decoration: _inputDecoration(null),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _privacy = value);
                },
              ),
              const SizedBox(height: 18),
              _buildLabel('Listener Limit'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _maxParticipants,
                dropdownColor: Colors.white,
                decoration: _inputDecoration(null),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                ),
                items: const [10, 20, 30, 50, 75, 100]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value listeners'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _maxParticipants = value);
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final loading = widget.controller.isCreatingRoom.value;
                      return OutlinedButton(
                        onPressed: loading
                            ? null
                            : () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final loading = widget.controller.isCreatingRoom.value;
                      return ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                unawaited(
                                  widget.controller.createRoom(
                                    name: _nameController.text,
                                    privacy: _privacy,
                                    maxParticipants: _maxParticipants,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          disabledBackgroundColor: const Color(0xFF99D4CE),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}
