import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String label;
  final Function(String)? onChanged;
  final bool readOnly;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
  const PhoneNumberTextField({super.key, this.controller, this.onChanged});
  final TextEditingController? controller;
  final Function(String)? onChanged;

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      onChanged: widget.onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: '9012345678',
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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

class NumberTextField extends StatefulWidget {
  const NumberTextField(
      {super.key, this.controller, required this.hintText, this.onChanged});
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class DateTextField extends StatefulWidget {
  const DateTextField({super.key, this.controller, required this.hintText, this.onChanged});
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onTap: () async {
        final selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (selectedDate != null) {
          setState(() {
            _controller.text = DateFormat('dd-MM-yyyy').format(selectedDate);
          });
          widget.onChanged?.call(_controller.text);
        }
      },
    );
  }
}

class EmailTextField extends StatefulWidget {
  const EmailTextField({super.key, this.controller, required this.hintText, this.onChanged});
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
      onChanged: widget.onChanged,
    );
  }
}

class PriceTextField extends StatefulWidget {
  const PriceTextField(
      {super.key, this.controller, required this.hintText, this.onChanged});
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  @override
  State<PriceTextField> createState() => _PriceTextFieldState();
}

class _PriceTextFieldState extends State<PriceTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          final number = int.parse(value.replaceAll(',', ''));
          final formatted = NumberFormat('#,###').format(number);
          _controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
          widget.onChanged?.call(value);
        }
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        prefixIcon: UnconstrainedBox(
          child: Container(
            margin: const EdgeInsets.only(right: 8, left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('₦'),
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
