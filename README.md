# KYTMO CONTACT

> Application Flutter minimaliste pour **enregistrer, organiser et retrouver** des contacts **en local** (SQLite).

---

## ✨ Fonctionnalités

* Ajouter / modifier / supprimer un contact
* Recherche instantanée (nom, téléphone, email)
* Marquer en **favori**
* Tri (A→Z, Z→A, récents)
* Stockage **offline** via `sqflite`
* UI épurée, responsive (Android / iOS / Web\*)

> \* Web est optionnel : `sqflite` supporte Android/iOS. Pour le Web, utiliser `sqflite_common_ffi_web` ou un adapter.

---

## 📦 Stack technique

* **Flutter** (Stable)
* **State management** : `provider`
* **Base de données** : `sqflite` + `path`
* **Icônes d’app** : `flutter_launcher_icons`

---

## 🗂️ Structure du projet

```
lib/
 ├─ main.dart
 ├─ app.dart
 ├─ models/
 │   └─ contact.dart
 ├─ data/
 │   ├─ db_helper.dart
 │   └─ contact_repository.dart
 ├─ providers/
 │   └─ contact_provider.dart
 ├─ ui/
 │   ├─ screens/
 │   │   ├─ home_screen.dart
 │   │   └─ edit_contact_screen.dart
 │   └─ widgets/
 │       ├─ contact_tile.dart
 │       └─ empty_view.dart
 assets/
   └─ icons/
       ├─ icon.png            # icône principale (1024x1024 recommandé)
       └─ icon-white.png      # variante blanche/PNG pour fonds colorés
```

---

## 🧰 Pré-requis

* Flutter SDK (canal stable) — `flutter --version`
* Android Studio / Xcode (pour les toolchains)

---

## 🚀 Démarrage rapide

### 1) Cloner & installer

```bash
git clone <repo-url>
cd kytmo_contact
flutter pub get
```

### 2) Configurer l’icône d’application

Dans `pubspec.yaml` :

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  image_path: assets/icons/icon.png
  android: "launcher_icon"
  ios: true
  adaptive_icon_background: "#1E6C99"   # bleu du logo
  adaptive_icon_foreground: assets/icons/icon.png
  remove_alpha_ios: true
```

Générer :

```bash
dart run flutter_launcher_icons
```

### 3) Lancer l’app

```bash
flutter run
```

---

## 🗃️ Modèle de données

**Table `contacts`**

* `id` INTEGER PRIMARY KEY AUTOINCREMENT
* `name` TEXT NOT NULL
* `phone` TEXT NOT NULL
* `email` TEXT
* `company` TEXT
* `address` TEXT
* `favorite` INTEGER DEFAULT 0  # 0/1
* `created_at` TEXT  # ISO 8601
* `updated_at` TEXT

**SQL de création**

```sql
CREATE TABLE IF NOT EXISTS contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  company TEXT,
  address TEXT,
  favorite INTEGER DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);
```

**Modèle Dart** (`lib/models/contact.dart`)

```dart
class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? company;
  final String? address;
  final bool favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.address,
    this.favorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
    id: m['id'] as int?,
    name: m['name'] as String,
    phone: m['phone'] as String,
    email: m['email'] as String?,
    company: m['company'] as String?,
    address: m['address'] as String?,
    favorite: (m['favorite'] ?? 0) == 1,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'company': company,
    'address': address,
    'favorite': favorite ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
```

**Accès DB** (`lib/data/db_helper.dart`)

```dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'kytmo_contact.db';
  static const _version = 1;

  static Future<Database> get database async {
    final base = await getDatabasesPath();
    final path = join(base, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            company TEXT,
            address TEXT,
            favorite INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          );
        ''');
      },
    );
  }
}
```

**Repository** (`lib/data/contact_repository.dart`)

```dart
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import 'db_helper.dart';

class ContactRepository {
  Future<int> create(Contact c) async {
    final db = await DBHelper.database;
    return db.insert('contacts', c.toMap());
  }

  Future<List<Contact>> all({String? q}) async {
    final db = await DBHelper.database;
    List<Map<String, dynamic>> rows;
    if (q != null && q.trim().isNotEmpty) {
      rows = await db.query('contacts',
        where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
        whereArgs: ['%$q%', '%$q%', '%$q%'],
        orderBy: 'name COLLATE NOCASE ASC');
    } else {
      rows = await db.query('contacts', orderBy: 'name COLLATE NOCASE ASC');
    }
    return rows.map(Contact.fromMap).toList();
  }

  Future<int> update(Contact c) async {
    final db = await DBHelper.database;
    return db.update('contacts', c.toMap(), where: 'id=?', whereArgs: [c.id]);
  }

  Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('contacts', where: 'id=?', whereArgs: [id]);
  }
}
```

**Provider** (`lib/providers/contact_provider.dart`)

```dart
import 'package:flutter/foundation.dart';
import '../data/contact_repository.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  final repo = ContactRepository();
  List<Contact> items = [];
  bool loading = false;

  Future<void> refresh({String? q}) async {
    loading = true; notifyListeners();
    items = await repo.all(q: q);
    loading = false; notifyListeners();
  }
}
```

---

## 🧪 Tests & Qualité

* **Tests unitaires** : `flutter test`
* **Analyse statique** : `flutter analyze`
* **Formatage** : `dart format .`

---

## 🔐 Sécurité & Vie privée

* Toutes les données sont **stockées localement**.
* Aucune permission "dangereuse" n’est requise (pas de lecture du carnet d’adresses natif tant que vous n’implémentez pas l’import).

---

## 📸 Captures d’écran (placeholders)

Ajoutez vos images dans `assets/screenshots/` et référencez-les ici :

```md
![Accueil](assets/screenshots/home.png)
![Edition](assets/screenshots/edit.png)
```

---

## 🏗️ Builds

**Android**

```bash
flutter build apk --release
# ou AppBundle
flutter build appbundle --release
```

**iOS**

```bash
flutter build ios --release
# puis archive via Xcode
```

---

## 🗺️ Roadmap suggérée

* Import/export CSV
* Groupes & tags
* Sauvegarde chiffrée
* Synchronisation optionnelle (Supabase/Firebase)
* Thèmes clair/sombre

---

## 🤝 Contribuer

1. Fork
2. Crée une branche : `git checkout -b feat/ma-fonctionnalite`
3. Commits clairs : `feat: ...`, `fix: ...`
4. PR avec description & screenshots

---

## 📄 Licence

MIT — Voir `LICENSE`.

---

## 📞 Contact

* Auteur : **Kobénan**
* Projet : KYTMO CONTACT
* Logo : couleur primaire `#1E6C99` (bleu), variante texte **blanc**.
