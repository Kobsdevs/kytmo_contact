import 'package:flutter/foundation.dart';
import '../data/contact_repository.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  final repo = ContactRepository();
  List<Contact> items = [];
  bool loading = false;

  Future<void> refresh({String? q}) async {
    loading = true;
    notifyListeners();
    items = await repo.all(q: q);
    loading = false;
    notifyListeners();
  }
}
