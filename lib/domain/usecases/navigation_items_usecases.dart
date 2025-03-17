import 'package:edconnect_admin/core/interfaces/navigation_repository.dart';
import 'package:edconnect_admin/domain/entities/navigation_item.dart';
import 'package:flutter/material.dart';

class GetNavigationItemsUseCase {
  final NavigationRepository _repository;

  GetNavigationItemsUseCase(this._repository);

  List<NavigationItem> execute() {
    return _repository.getNavigationItems();
  }
}

class GetScreenForNavigationItemUseCase {
  final NavigationRepository _repository;

  GetScreenForNavigationItemUseCase(this._repository);

  Widget execute(String navigationItemId, List<String> userPermissions) {
    return _repository.getScreenForNavigationItem(
        navigationItemId, userPermissions);
  }
}

class CheckAccessUseCase {
  final NavigationRepository _repository;

  CheckAccessUseCase(this._repository);

  bool execute(List<String> requiredPermissions, List<String> userPermissions) {
    return _repository.checkAccess(requiredPermissions, userPermissions);
  }
}
