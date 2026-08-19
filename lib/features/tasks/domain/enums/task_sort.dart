enum TaskSortBy {
  dueDateAsc,
  dueDateDesc,
  priorityHighToLow,
  priorityLowToHigh,
  createdDateDesc;

  String get label {
    switch (this) {
      case TaskSortBy.dueDateAsc:
        return 'Due Date (Earliest First)';
      case TaskSortBy.dueDateDesc:
        return 'Due Date (Latest First)';
      case TaskSortBy.priorityHighToLow:
        return 'Priority (Highest First)';
      case TaskSortBy.priorityLowToHigh:
        return 'Priority (Lowest First)';
      case TaskSortBy.createdDateDesc:
        return 'Created Date (Newest First)';
    }
  }
}
