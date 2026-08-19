import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class SearchInputWidget extends StatefulWidget {
  const SearchInputWidget({super.key});

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentQuery = context.read<TaskBloc>().state.searchQuery;
    _controller = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      child: TextField(
        controller: _controller,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 15,
        ),
        onChanged: (query) {
          context.read<TaskBloc>().add(SearchTasksEvent(query));
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    context.read<TaskBloc>().add(const SearchTasksEvent(''));
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: isDark ? AppColors.primary : AppColors.primaryDark,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        ),
      ),
    );
  }
}
