import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.grey),
        border: InputBorder.none,
        // filled: true,
        // fillColor: Colors.black12,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class PhoneNumberTextField extends StatefulWidget {
  const PhoneNumberTextField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: '9012345678',
        hintStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.grey),
        prefixIcon: UnconstrainedBox(
          child: Container(
            margin: const EdgeInsets.only(right: 8, left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('+234'),
          ),
        ),
        border: InputBorder.none,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
