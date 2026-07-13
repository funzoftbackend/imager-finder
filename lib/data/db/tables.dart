import 'package:drift/drift.dart';

class Photos extends Table {
  TextColumn get mediaId => text()();
  TextColumn get uri => text()();
  TextColumn get path => text().nullable()();
  IntColumn get width => integer().withDefault(const Constant(0))();
  IntColumn get height => integer().withDefault(const Constant(0))();
  IntColumn get sizeBytes => integer()();
  IntColumn get modifiedMs => integer()();
  IntColumn get createdMs => integer().withDefault(const Constant(0))();
  TextColumn get mime => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get contentHash => text().nullable()();
  TextColumn get dHash => text().nullable()();
  TextColumn get pHash => text().nullable()();
  IntColumn get indexedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

class ScanMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get lastScanAtMs => integer().nullable()();
  IntColumn get photoCount => integer().withDefault(const Constant(0))();
  IntColumn get exactGroupCount => integer().withDefault(const Constant(0))();
  IntColumn get similarGroupCount => integer().withDefault(const Constant(0))();
  TextColumn get lastPhase => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExactGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentHash => text()();
  IntColumn get memberCount => integer()();
  IntColumn get totalBytes => integer().withDefault(const Constant(0))();
}

class ExactGroupMembers extends Table {
  IntColumn get groupId => integer()();
  TextColumn get mediaId => text()();

  @override
  Set<Column<Object>> get primaryKey => {groupId, mediaId};
}

class SimilarGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberCount => integer()();
  IntColumn get maxDistance => integer().withDefault(const Constant(0))();
}

class SimilarGroupMembers extends Table {
  IntColumn get groupId => integer()();
  TextColumn get mediaId => text()();

  @override
  Set<Column<Object>> get primaryKey => {groupId, mediaId};
}
