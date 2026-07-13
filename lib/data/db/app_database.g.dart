// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedMsMeta = const VerificationMeta(
    'modifiedMs',
  );
  @override
  late final GeneratedColumn<int> modifiedMs = GeneratedColumn<int>(
    'modified_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdMsMeta = const VerificationMeta(
    'createdMs',
  );
  @override
  late final GeneratedColumn<int> createdMs = GeneratedColumn<int>(
    'created_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dHashMeta = const VerificationMeta('dHash');
  @override
  late final GeneratedColumn<String> dHash = GeneratedColumn<String>(
    'd_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pHashMeta = const VerificationMeta('pHash');
  @override
  late final GeneratedColumn<String> pHash = GeneratedColumn<String>(
    'p_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMsMeta = const VerificationMeta(
    'indexedAtMs',
  );
  @override
  late final GeneratedColumn<int> indexedAtMs = GeneratedColumn<int>(
    'indexed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    uri,
    path,
    width,
    height,
    sizeBytes,
    modifiedMs,
    createdMs,
    mime,
    album,
    contentHash,
    dHash,
    pHash,
    indexedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('modified_ms')) {
      context.handle(
        _modifiedMsMeta,
        modifiedMs.isAcceptableOrUnknown(data['modified_ms']!, _modifiedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedMsMeta);
    }
    if (data.containsKey('created_ms')) {
      context.handle(
        _createdMsMeta,
        createdMs.isAcceptableOrUnknown(data['created_ms']!, _createdMsMeta),
      );
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('d_hash')) {
      context.handle(
        _dHashMeta,
        dHash.isAcceptableOrUnknown(data['d_hash']!, _dHashMeta),
      );
    }
    if (data.containsKey('p_hash')) {
      context.handle(
        _pHashMeta,
        pHash.isAcceptableOrUnknown(data['p_hash']!, _pHashMeta),
      );
    }
    if (data.containsKey('indexed_at_ms')) {
      context.handle(
        _indexedAtMsMeta,
        indexedAtMs.isAcceptableOrUnknown(
          data['indexed_at_ms']!,
          _indexedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_indexedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      modifiedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_ms'],
      )!,
      createdMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_ms'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
      dHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}d_hash'],
      ),
      pHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}p_hash'],
      ),
      indexedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indexed_at_ms'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String mediaId;
  final String uri;
  final String? path;
  final int width;
  final int height;
  final int sizeBytes;
  final int modifiedMs;
  final int createdMs;
  final String? mime;
  final String? album;
  final String? contentHash;
  final String? dHash;
  final String? pHash;
  final int indexedAtMs;
  const Photo({
    required this.mediaId,
    required this.uri,
    this.path,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.modifiedMs,
    required this.createdMs,
    this.mime,
    this.album,
    this.contentHash,
    this.dHash,
    this.pHash,
    required this.indexedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['uri'] = Variable<String>(uri);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['modified_ms'] = Variable<int>(modifiedMs);
    map['created_ms'] = Variable<int>(createdMs);
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    if (!nullToAbsent || dHash != null) {
      map['d_hash'] = Variable<String>(dHash);
    }
    if (!nullToAbsent || pHash != null) {
      map['p_hash'] = Variable<String>(pHash);
    }
    map['indexed_at_ms'] = Variable<int>(indexedAtMs);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      mediaId: Value(mediaId),
      uri: Value(uri),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      width: Value(width),
      height: Value(height),
      sizeBytes: Value(sizeBytes),
      modifiedMs: Value(modifiedMs),
      createdMs: Value(createdMs),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      dHash: dHash == null && nullToAbsent
          ? const Value.absent()
          : Value(dHash),
      pHash: pHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pHash),
      indexedAtMs: Value(indexedAtMs),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      uri: serializer.fromJson<String>(json['uri']),
      path: serializer.fromJson<String?>(json['path']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      modifiedMs: serializer.fromJson<int>(json['modifiedMs']),
      createdMs: serializer.fromJson<int>(json['createdMs']),
      mime: serializer.fromJson<String?>(json['mime']),
      album: serializer.fromJson<String?>(json['album']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      dHash: serializer.fromJson<String?>(json['dHash']),
      pHash: serializer.fromJson<String?>(json['pHash']),
      indexedAtMs: serializer.fromJson<int>(json['indexedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'uri': serializer.toJson<String>(uri),
      'path': serializer.toJson<String?>(path),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'modifiedMs': serializer.toJson<int>(modifiedMs),
      'createdMs': serializer.toJson<int>(createdMs),
      'mime': serializer.toJson<String?>(mime),
      'album': serializer.toJson<String?>(album),
      'contentHash': serializer.toJson<String?>(contentHash),
      'dHash': serializer.toJson<String?>(dHash),
      'pHash': serializer.toJson<String?>(pHash),
      'indexedAtMs': serializer.toJson<int>(indexedAtMs),
    };
  }

  Photo copyWith({
    String? mediaId,
    String? uri,
    Value<String?> path = const Value.absent(),
    int? width,
    int? height,
    int? sizeBytes,
    int? modifiedMs,
    int? createdMs,
    Value<String?> mime = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> contentHash = const Value.absent(),
    Value<String?> dHash = const Value.absent(),
    Value<String?> pHash = const Value.absent(),
    int? indexedAtMs,
  }) => Photo(
    mediaId: mediaId ?? this.mediaId,
    uri: uri ?? this.uri,
    path: path.present ? path.value : this.path,
    width: width ?? this.width,
    height: height ?? this.height,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    modifiedMs: modifiedMs ?? this.modifiedMs,
    createdMs: createdMs ?? this.createdMs,
    mime: mime.present ? mime.value : this.mime,
    album: album.present ? album.value : this.album,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    dHash: dHash.present ? dHash.value : this.dHash,
    pHash: pHash.present ? pHash.value : this.pHash,
    indexedAtMs: indexedAtMs ?? this.indexedAtMs,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      uri: data.uri.present ? data.uri.value : this.uri,
      path: data.path.present ? data.path.value : this.path,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      modifiedMs: data.modifiedMs.present
          ? data.modifiedMs.value
          : this.modifiedMs,
      createdMs: data.createdMs.present ? data.createdMs.value : this.createdMs,
      mime: data.mime.present ? data.mime.value : this.mime,
      album: data.album.present ? data.album.value : this.album,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      dHash: data.dHash.present ? data.dHash.value : this.dHash,
      pHash: data.pHash.present ? data.pHash.value : this.pHash,
      indexedAtMs: data.indexedAtMs.present
          ? data.indexedAtMs.value
          : this.indexedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('mediaId: $mediaId, ')
          ..write('uri: $uri, ')
          ..write('path: $path, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('modifiedMs: $modifiedMs, ')
          ..write('createdMs: $createdMs, ')
          ..write('mime: $mime, ')
          ..write('album: $album, ')
          ..write('contentHash: $contentHash, ')
          ..write('dHash: $dHash, ')
          ..write('pHash: $pHash, ')
          ..write('indexedAtMs: $indexedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    uri,
    path,
    width,
    height,
    sizeBytes,
    modifiedMs,
    createdMs,
    mime,
    album,
    contentHash,
    dHash,
    pHash,
    indexedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.mediaId == this.mediaId &&
          other.uri == this.uri &&
          other.path == this.path &&
          other.width == this.width &&
          other.height == this.height &&
          other.sizeBytes == this.sizeBytes &&
          other.modifiedMs == this.modifiedMs &&
          other.createdMs == this.createdMs &&
          other.mime == this.mime &&
          other.album == this.album &&
          other.contentHash == this.contentHash &&
          other.dHash == this.dHash &&
          other.pHash == this.pHash &&
          other.indexedAtMs == this.indexedAtMs);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> mediaId;
  final Value<String> uri;
  final Value<String?> path;
  final Value<int> width;
  final Value<int> height;
  final Value<int> sizeBytes;
  final Value<int> modifiedMs;
  final Value<int> createdMs;
  final Value<String?> mime;
  final Value<String?> album;
  final Value<String?> contentHash;
  final Value<String?> dHash;
  final Value<String?> pHash;
  final Value<int> indexedAtMs;
  final Value<int> rowid;
  const PhotosCompanion({
    this.mediaId = const Value.absent(),
    this.uri = const Value.absent(),
    this.path = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.modifiedMs = const Value.absent(),
    this.createdMs = const Value.absent(),
    this.mime = const Value.absent(),
    this.album = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.dHash = const Value.absent(),
    this.pHash = const Value.absent(),
    this.indexedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String mediaId,
    required String uri,
    this.path = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int sizeBytes,
    required int modifiedMs,
    this.createdMs = const Value.absent(),
    this.mime = const Value.absent(),
    this.album = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.dHash = const Value.absent(),
    this.pHash = const Value.absent(),
    required int indexedAtMs,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       uri = Value(uri),
       sizeBytes = Value(sizeBytes),
       modifiedMs = Value(modifiedMs),
       indexedAtMs = Value(indexedAtMs);
  static Insertable<Photo> custom({
    Expression<String>? mediaId,
    Expression<String>? uri,
    Expression<String>? path,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? sizeBytes,
    Expression<int>? modifiedMs,
    Expression<int>? createdMs,
    Expression<String>? mime,
    Expression<String>? album,
    Expression<String>? contentHash,
    Expression<String>? dHash,
    Expression<String>? pHash,
    Expression<int>? indexedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (uri != null) 'uri': uri,
      if (path != null) 'path': path,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (modifiedMs != null) 'modified_ms': modifiedMs,
      if (createdMs != null) 'created_ms': createdMs,
      if (mime != null) 'mime': mime,
      if (album != null) 'album': album,
      if (contentHash != null) 'content_hash': contentHash,
      if (dHash != null) 'd_hash': dHash,
      if (pHash != null) 'p_hash': pHash,
      if (indexedAtMs != null) 'indexed_at_ms': indexedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? uri,
    Value<String?>? path,
    Value<int>? width,
    Value<int>? height,
    Value<int>? sizeBytes,
    Value<int>? modifiedMs,
    Value<int>? createdMs,
    Value<String?>? mime,
    Value<String?>? album,
    Value<String?>? contentHash,
    Value<String?>? dHash,
    Value<String?>? pHash,
    Value<int>? indexedAtMs,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      mediaId: mediaId ?? this.mediaId,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedMs: modifiedMs ?? this.modifiedMs,
      createdMs: createdMs ?? this.createdMs,
      mime: mime ?? this.mime,
      album: album ?? this.album,
      contentHash: contentHash ?? this.contentHash,
      dHash: dHash ?? this.dHash,
      pHash: pHash ?? this.pHash,
      indexedAtMs: indexedAtMs ?? this.indexedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (modifiedMs.present) {
      map['modified_ms'] = Variable<int>(modifiedMs.value);
    }
    if (createdMs.present) {
      map['created_ms'] = Variable<int>(createdMs.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (dHash.present) {
      map['d_hash'] = Variable<String>(dHash.value);
    }
    if (pHash.present) {
      map['p_hash'] = Variable<String>(pHash.value);
    }
    if (indexedAtMs.present) {
      map['indexed_at_ms'] = Variable<int>(indexedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('uri: $uri, ')
          ..write('path: $path, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('modifiedMs: $modifiedMs, ')
          ..write('createdMs: $createdMs, ')
          ..write('mime: $mime, ')
          ..write('album: $album, ')
          ..write('contentHash: $contentHash, ')
          ..write('dHash: $dHash, ')
          ..write('pHash: $pHash, ')
          ..write('indexedAtMs: $indexedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanMetaTable extends ScanMeta
    with TableInfo<$ScanMetaTable, ScanMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastScanAtMsMeta = const VerificationMeta(
    'lastScanAtMs',
  );
  @override
  late final GeneratedColumn<int> lastScanAtMs = GeneratedColumn<int>(
    'last_scan_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoCountMeta = const VerificationMeta(
    'photoCount',
  );
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
    'photo_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exactGroupCountMeta = const VerificationMeta(
    'exactGroupCount',
  );
  @override
  late final GeneratedColumn<int> exactGroupCount = GeneratedColumn<int>(
    'exact_group_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _similarGroupCountMeta = const VerificationMeta(
    'similarGroupCount',
  );
  @override
  late final GeneratedColumn<int> similarGroupCount = GeneratedColumn<int>(
    'similar_group_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPhaseMeta = const VerificationMeta(
    'lastPhase',
  );
  @override
  late final GeneratedColumn<String> lastPhase = GeneratedColumn<String>(
    'last_phase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastScanAtMs,
    photoCount,
    exactGroupCount,
    similarGroupCount,
    lastPhase,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_scan_at_ms')) {
      context.handle(
        _lastScanAtMsMeta,
        lastScanAtMs.isAcceptableOrUnknown(
          data['last_scan_at_ms']!,
          _lastScanAtMsMeta,
        ),
      );
    }
    if (data.containsKey('photo_count')) {
      context.handle(
        _photoCountMeta,
        photoCount.isAcceptableOrUnknown(data['photo_count']!, _photoCountMeta),
      );
    }
    if (data.containsKey('exact_group_count')) {
      context.handle(
        _exactGroupCountMeta,
        exactGroupCount.isAcceptableOrUnknown(
          data['exact_group_count']!,
          _exactGroupCountMeta,
        ),
      );
    }
    if (data.containsKey('similar_group_count')) {
      context.handle(
        _similarGroupCountMeta,
        similarGroupCount.isAcceptableOrUnknown(
          data['similar_group_count']!,
          _similarGroupCountMeta,
        ),
      );
    }
    if (data.containsKey('last_phase')) {
      context.handle(
        _lastPhaseMeta,
        lastPhase.isAcceptableOrUnknown(data['last_phase']!, _lastPhaseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastScanAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scan_at_ms'],
      ),
      photoCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_count'],
      )!,
      exactGroupCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exact_group_count'],
      )!,
      similarGroupCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}similar_group_count'],
      )!,
      lastPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_phase'],
      ),
    );
  }

  @override
  $ScanMetaTable createAlias(String alias) {
    return $ScanMetaTable(attachedDatabase, alias);
  }
}

class ScanMetaData extends DataClass implements Insertable<ScanMetaData> {
  final int id;
  final int? lastScanAtMs;
  final int photoCount;
  final int exactGroupCount;
  final int similarGroupCount;
  final String? lastPhase;
  const ScanMetaData({
    required this.id,
    this.lastScanAtMs,
    required this.photoCount,
    required this.exactGroupCount,
    required this.similarGroupCount,
    this.lastPhase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastScanAtMs != null) {
      map['last_scan_at_ms'] = Variable<int>(lastScanAtMs);
    }
    map['photo_count'] = Variable<int>(photoCount);
    map['exact_group_count'] = Variable<int>(exactGroupCount);
    map['similar_group_count'] = Variable<int>(similarGroupCount);
    if (!nullToAbsent || lastPhase != null) {
      map['last_phase'] = Variable<String>(lastPhase);
    }
    return map;
  }

  ScanMetaCompanion toCompanion(bool nullToAbsent) {
    return ScanMetaCompanion(
      id: Value(id),
      lastScanAtMs: lastScanAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAtMs),
      photoCount: Value(photoCount),
      exactGroupCount: Value(exactGroupCount),
      similarGroupCount: Value(similarGroupCount),
      lastPhase: lastPhase == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPhase),
    );
  }

  factory ScanMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanMetaData(
      id: serializer.fromJson<int>(json['id']),
      lastScanAtMs: serializer.fromJson<int?>(json['lastScanAtMs']),
      photoCount: serializer.fromJson<int>(json['photoCount']),
      exactGroupCount: serializer.fromJson<int>(json['exactGroupCount']),
      similarGroupCount: serializer.fromJson<int>(json['similarGroupCount']),
      lastPhase: serializer.fromJson<String?>(json['lastPhase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastScanAtMs': serializer.toJson<int?>(lastScanAtMs),
      'photoCount': serializer.toJson<int>(photoCount),
      'exactGroupCount': serializer.toJson<int>(exactGroupCount),
      'similarGroupCount': serializer.toJson<int>(similarGroupCount),
      'lastPhase': serializer.toJson<String?>(lastPhase),
    };
  }

  ScanMetaData copyWith({
    int? id,
    Value<int?> lastScanAtMs = const Value.absent(),
    int? photoCount,
    int? exactGroupCount,
    int? similarGroupCount,
    Value<String?> lastPhase = const Value.absent(),
  }) => ScanMetaData(
    id: id ?? this.id,
    lastScanAtMs: lastScanAtMs.present ? lastScanAtMs.value : this.lastScanAtMs,
    photoCount: photoCount ?? this.photoCount,
    exactGroupCount: exactGroupCount ?? this.exactGroupCount,
    similarGroupCount: similarGroupCount ?? this.similarGroupCount,
    lastPhase: lastPhase.present ? lastPhase.value : this.lastPhase,
  );
  ScanMetaData copyWithCompanion(ScanMetaCompanion data) {
    return ScanMetaData(
      id: data.id.present ? data.id.value : this.id,
      lastScanAtMs: data.lastScanAtMs.present
          ? data.lastScanAtMs.value
          : this.lastScanAtMs,
      photoCount: data.photoCount.present
          ? data.photoCount.value
          : this.photoCount,
      exactGroupCount: data.exactGroupCount.present
          ? data.exactGroupCount.value
          : this.exactGroupCount,
      similarGroupCount: data.similarGroupCount.present
          ? data.similarGroupCount.value
          : this.similarGroupCount,
      lastPhase: data.lastPhase.present ? data.lastPhase.value : this.lastPhase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanMetaData(')
          ..write('id: $id, ')
          ..write('lastScanAtMs: $lastScanAtMs, ')
          ..write('photoCount: $photoCount, ')
          ..write('exactGroupCount: $exactGroupCount, ')
          ..write('similarGroupCount: $similarGroupCount, ')
          ..write('lastPhase: $lastPhase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastScanAtMs,
    photoCount,
    exactGroupCount,
    similarGroupCount,
    lastPhase,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanMetaData &&
          other.id == this.id &&
          other.lastScanAtMs == this.lastScanAtMs &&
          other.photoCount == this.photoCount &&
          other.exactGroupCount == this.exactGroupCount &&
          other.similarGroupCount == this.similarGroupCount &&
          other.lastPhase == this.lastPhase);
}

class ScanMetaCompanion extends UpdateCompanion<ScanMetaData> {
  final Value<int> id;
  final Value<int?> lastScanAtMs;
  final Value<int> photoCount;
  final Value<int> exactGroupCount;
  final Value<int> similarGroupCount;
  final Value<String?> lastPhase;
  const ScanMetaCompanion({
    this.id = const Value.absent(),
    this.lastScanAtMs = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.exactGroupCount = const Value.absent(),
    this.similarGroupCount = const Value.absent(),
    this.lastPhase = const Value.absent(),
  });
  ScanMetaCompanion.insert({
    this.id = const Value.absent(),
    this.lastScanAtMs = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.exactGroupCount = const Value.absent(),
    this.similarGroupCount = const Value.absent(),
    this.lastPhase = const Value.absent(),
  });
  static Insertable<ScanMetaData> custom({
    Expression<int>? id,
    Expression<int>? lastScanAtMs,
    Expression<int>? photoCount,
    Expression<int>? exactGroupCount,
    Expression<int>? similarGroupCount,
    Expression<String>? lastPhase,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastScanAtMs != null) 'last_scan_at_ms': lastScanAtMs,
      if (photoCount != null) 'photo_count': photoCount,
      if (exactGroupCount != null) 'exact_group_count': exactGroupCount,
      if (similarGroupCount != null) 'similar_group_count': similarGroupCount,
      if (lastPhase != null) 'last_phase': lastPhase,
    });
  }

  ScanMetaCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastScanAtMs,
    Value<int>? photoCount,
    Value<int>? exactGroupCount,
    Value<int>? similarGroupCount,
    Value<String?>? lastPhase,
  }) {
    return ScanMetaCompanion(
      id: id ?? this.id,
      lastScanAtMs: lastScanAtMs ?? this.lastScanAtMs,
      photoCount: photoCount ?? this.photoCount,
      exactGroupCount: exactGroupCount ?? this.exactGroupCount,
      similarGroupCount: similarGroupCount ?? this.similarGroupCount,
      lastPhase: lastPhase ?? this.lastPhase,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastScanAtMs.present) {
      map['last_scan_at_ms'] = Variable<int>(lastScanAtMs.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (exactGroupCount.present) {
      map['exact_group_count'] = Variable<int>(exactGroupCount.value);
    }
    if (similarGroupCount.present) {
      map['similar_group_count'] = Variable<int>(similarGroupCount.value);
    }
    if (lastPhase.present) {
      map['last_phase'] = Variable<String>(lastPhase.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanMetaCompanion(')
          ..write('id: $id, ')
          ..write('lastScanAtMs: $lastScanAtMs, ')
          ..write('photoCount: $photoCount, ')
          ..write('exactGroupCount: $exactGroupCount, ')
          ..write('similarGroupCount: $similarGroupCount, ')
          ..write('lastPhase: $lastPhase')
          ..write(')'))
        .toString();
  }
}

class $ExactGroupsTable extends ExactGroups
    with TableInfo<$ExactGroupsTable, ExactGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExactGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    memberCount,
    totalBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exact_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExactGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memberCountMeta);
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExactGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExactGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
    );
  }

  @override
  $ExactGroupsTable createAlias(String alias) {
    return $ExactGroupsTable(attachedDatabase, alias);
  }
}

class ExactGroup extends DataClass implements Insertable<ExactGroup> {
  final int id;
  final String contentHash;
  final int memberCount;
  final int totalBytes;
  const ExactGroup({
    required this.id,
    required this.contentHash,
    required this.memberCount,
    required this.totalBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['member_count'] = Variable<int>(memberCount);
    map['total_bytes'] = Variable<int>(totalBytes);
    return map;
  }

  ExactGroupsCompanion toCompanion(bool nullToAbsent) {
    return ExactGroupsCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      memberCount: Value(memberCount),
      totalBytes: Value(totalBytes),
    );
  }

  factory ExactGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExactGroup(
      id: serializer.fromJson<int>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'memberCount': serializer.toJson<int>(memberCount),
      'totalBytes': serializer.toJson<int>(totalBytes),
    };
  }

  ExactGroup copyWith({
    int? id,
    String? contentHash,
    int? memberCount,
    int? totalBytes,
  }) => ExactGroup(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    memberCount: memberCount ?? this.memberCount,
    totalBytes: totalBytes ?? this.totalBytes,
  );
  ExactGroup copyWithCompanion(ExactGroupsCompanion data) {
    return ExactGroup(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      memberCount: data.memberCount.present
          ? data.memberCount.value
          : this.memberCount,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExactGroup(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('memberCount: $memberCount, ')
          ..write('totalBytes: $totalBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contentHash, memberCount, totalBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExactGroup &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.memberCount == this.memberCount &&
          other.totalBytes == this.totalBytes);
}

class ExactGroupsCompanion extends UpdateCompanion<ExactGroup> {
  final Value<int> id;
  final Value<String> contentHash;
  final Value<int> memberCount;
  final Value<int> totalBytes;
  const ExactGroupsCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.totalBytes = const Value.absent(),
  });
  ExactGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String contentHash,
    required int memberCount,
    this.totalBytes = const Value.absent(),
  }) : contentHash = Value(contentHash),
       memberCount = Value(memberCount);
  static Insertable<ExactGroup> custom({
    Expression<int>? id,
    Expression<String>? contentHash,
    Expression<int>? memberCount,
    Expression<int>? totalBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (memberCount != null) 'member_count': memberCount,
      if (totalBytes != null) 'total_bytes': totalBytes,
    });
  }

  ExactGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? contentHash,
    Value<int>? memberCount,
    Value<int>? totalBytes,
  }) {
    return ExactGroupsCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      memberCount: memberCount ?? this.memberCount,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExactGroupsCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('memberCount: $memberCount, ')
          ..write('totalBytes: $totalBytes')
          ..write(')'))
        .toString();
  }
}

class $ExactGroupMembersTable extends ExactGroupMembers
    with TableInfo<$ExactGroupMembersTable, ExactGroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExactGroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, mediaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exact_group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExactGroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, mediaId};
  @override
  ExactGroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExactGroupMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
    );
  }

  @override
  $ExactGroupMembersTable createAlias(String alias) {
    return $ExactGroupMembersTable(attachedDatabase, alias);
  }
}

class ExactGroupMember extends DataClass
    implements Insertable<ExactGroupMember> {
  final int groupId;
  final String mediaId;
  const ExactGroupMember({required this.groupId, required this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['media_id'] = Variable<String>(mediaId);
    return map;
  }

  ExactGroupMembersCompanion toCompanion(bool nullToAbsent) {
    return ExactGroupMembersCompanion(
      groupId: Value(groupId),
      mediaId: Value(mediaId),
    );
  }

  factory ExactGroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExactGroupMember(
      groupId: serializer.fromJson<int>(json['groupId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'mediaId': serializer.toJson<String>(mediaId),
    };
  }

  ExactGroupMember copyWith({int? groupId, String? mediaId}) =>
      ExactGroupMember(
        groupId: groupId ?? this.groupId,
        mediaId: mediaId ?? this.mediaId,
      );
  ExactGroupMember copyWithCompanion(ExactGroupMembersCompanion data) {
    return ExactGroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExactGroupMember(')
          ..write('groupId: $groupId, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExactGroupMember &&
          other.groupId == this.groupId &&
          other.mediaId == this.mediaId);
}

class ExactGroupMembersCompanion extends UpdateCompanion<ExactGroupMember> {
  final Value<int> groupId;
  final Value<String> mediaId;
  final Value<int> rowid;
  const ExactGroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExactGroupMembersCompanion.insert({
    required int groupId,
    required String mediaId,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       mediaId = Value(mediaId);
  static Insertable<ExactGroupMember> custom({
    Expression<int>? groupId,
    Expression<String>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (mediaId != null) 'media_id': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExactGroupMembersCompanion copyWith({
    Value<int>? groupId,
    Value<String>? mediaId,
    Value<int>? rowid,
  }) {
    return ExactGroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExactGroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SimilarGroupsTable extends SimilarGroups
    with TableInfo<$SimilarGroupsTable, SimilarGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimilarGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxDistanceMeta = const VerificationMeta(
    'maxDistance',
  );
  @override
  late final GeneratedColumn<int> maxDistance = GeneratedColumn<int>(
    'max_distance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, memberCount, maxDistance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'similar_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimilarGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memberCountMeta);
    }
    if (data.containsKey('max_distance')) {
      context.handle(
        _maxDistanceMeta,
        maxDistance.isAcceptableOrUnknown(
          data['max_distance']!,
          _maxDistanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimilarGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimilarGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      )!,
      maxDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_distance'],
      )!,
    );
  }

  @override
  $SimilarGroupsTable createAlias(String alias) {
    return $SimilarGroupsTable(attachedDatabase, alias);
  }
}

class SimilarGroup extends DataClass implements Insertable<SimilarGroup> {
  final int id;
  final int memberCount;
  final int maxDistance;
  const SimilarGroup({
    required this.id,
    required this.memberCount,
    required this.maxDistance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['member_count'] = Variable<int>(memberCount);
    map['max_distance'] = Variable<int>(maxDistance);
    return map;
  }

  SimilarGroupsCompanion toCompanion(bool nullToAbsent) {
    return SimilarGroupsCompanion(
      id: Value(id),
      memberCount: Value(memberCount),
      maxDistance: Value(maxDistance),
    );
  }

  factory SimilarGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimilarGroup(
      id: serializer.fromJson<int>(json['id']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      maxDistance: serializer.fromJson<int>(json['maxDistance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memberCount': serializer.toJson<int>(memberCount),
      'maxDistance': serializer.toJson<int>(maxDistance),
    };
  }

  SimilarGroup copyWith({int? id, int? memberCount, int? maxDistance}) =>
      SimilarGroup(
        id: id ?? this.id,
        memberCount: memberCount ?? this.memberCount,
        maxDistance: maxDistance ?? this.maxDistance,
      );
  SimilarGroup copyWithCompanion(SimilarGroupsCompanion data) {
    return SimilarGroup(
      id: data.id.present ? data.id.value : this.id,
      memberCount: data.memberCount.present
          ? data.memberCount.value
          : this.memberCount,
      maxDistance: data.maxDistance.present
          ? data.maxDistance.value
          : this.maxDistance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimilarGroup(')
          ..write('id: $id, ')
          ..write('memberCount: $memberCount, ')
          ..write('maxDistance: $maxDistance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memberCount, maxDistance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimilarGroup &&
          other.id == this.id &&
          other.memberCount == this.memberCount &&
          other.maxDistance == this.maxDistance);
}

class SimilarGroupsCompanion extends UpdateCompanion<SimilarGroup> {
  final Value<int> id;
  final Value<int> memberCount;
  final Value<int> maxDistance;
  const SimilarGroupsCompanion({
    this.id = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.maxDistance = const Value.absent(),
  });
  SimilarGroupsCompanion.insert({
    this.id = const Value.absent(),
    required int memberCount,
    this.maxDistance = const Value.absent(),
  }) : memberCount = Value(memberCount);
  static Insertable<SimilarGroup> custom({
    Expression<int>? id,
    Expression<int>? memberCount,
    Expression<int>? maxDistance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberCount != null) 'member_count': memberCount,
      if (maxDistance != null) 'max_distance': maxDistance,
    });
  }

  SimilarGroupsCompanion copyWith({
    Value<int>? id,
    Value<int>? memberCount,
    Value<int>? maxDistance,
  }) {
    return SimilarGroupsCompanion(
      id: id ?? this.id,
      memberCount: memberCount ?? this.memberCount,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (maxDistance.present) {
      map['max_distance'] = Variable<int>(maxDistance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimilarGroupsCompanion(')
          ..write('id: $id, ')
          ..write('memberCount: $memberCount, ')
          ..write('maxDistance: $maxDistance')
          ..write(')'))
        .toString();
  }
}

class $SimilarGroupMembersTable extends SimilarGroupMembers
    with TableInfo<$SimilarGroupMembersTable, SimilarGroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimilarGroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, mediaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'similar_group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimilarGroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, mediaId};
  @override
  SimilarGroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimilarGroupMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
    );
  }

  @override
  $SimilarGroupMembersTable createAlias(String alias) {
    return $SimilarGroupMembersTable(attachedDatabase, alias);
  }
}

class SimilarGroupMember extends DataClass
    implements Insertable<SimilarGroupMember> {
  final int groupId;
  final String mediaId;
  const SimilarGroupMember({required this.groupId, required this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['media_id'] = Variable<String>(mediaId);
    return map;
  }

  SimilarGroupMembersCompanion toCompanion(bool nullToAbsent) {
    return SimilarGroupMembersCompanion(
      groupId: Value(groupId),
      mediaId: Value(mediaId),
    );
  }

  factory SimilarGroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimilarGroupMember(
      groupId: serializer.fromJson<int>(json['groupId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'mediaId': serializer.toJson<String>(mediaId),
    };
  }

  SimilarGroupMember copyWith({int? groupId, String? mediaId}) =>
      SimilarGroupMember(
        groupId: groupId ?? this.groupId,
        mediaId: mediaId ?? this.mediaId,
      );
  SimilarGroupMember copyWithCompanion(SimilarGroupMembersCompanion data) {
    return SimilarGroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimilarGroupMember(')
          ..write('groupId: $groupId, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimilarGroupMember &&
          other.groupId == this.groupId &&
          other.mediaId == this.mediaId);
}

class SimilarGroupMembersCompanion extends UpdateCompanion<SimilarGroupMember> {
  final Value<int> groupId;
  final Value<String> mediaId;
  final Value<int> rowid;
  const SimilarGroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SimilarGroupMembersCompanion.insert({
    required int groupId,
    required String mediaId,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       mediaId = Value(mediaId);
  static Insertable<SimilarGroupMember> custom({
    Expression<int>? groupId,
    Expression<String>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (mediaId != null) 'media_id': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SimilarGroupMembersCompanion copyWith({
    Value<int>? groupId,
    Value<String>? mediaId,
    Value<int>? rowid,
  }) {
    return SimilarGroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimilarGroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $ScanMetaTable scanMeta = $ScanMetaTable(this);
  late final $ExactGroupsTable exactGroups = $ExactGroupsTable(this);
  late final $ExactGroupMembersTable exactGroupMembers =
      $ExactGroupMembersTable(this);
  late final $SimilarGroupsTable similarGroups = $SimilarGroupsTable(this);
  late final $SimilarGroupMembersTable similarGroupMembers =
      $SimilarGroupMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    photos,
    scanMeta,
    exactGroups,
    exactGroupMembers,
    similarGroups,
    similarGroupMembers,
  ];
}

typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      required String mediaId,
      required String uri,
      Value<String?> path,
      Value<int> width,
      Value<int> height,
      required int sizeBytes,
      required int modifiedMs,
      Value<int> createdMs,
      Value<String?> mime,
      Value<String?> album,
      Value<String?> contentHash,
      Value<String?> dHash,
      Value<String?> pHash,
      required int indexedAtMs,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<String> mediaId,
      Value<String> uri,
      Value<String?> path,
      Value<int> width,
      Value<int> height,
      Value<int> sizeBytes,
      Value<int> modifiedMs,
      Value<int> createdMs,
      Value<String?> mime,
      Value<String?> album,
      Value<String?> contentHash,
      Value<String?> dHash,
      Value<String?> pHash,
      Value<int> indexedAtMs,
      Value<int> rowid,
    });

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modifiedMs => $composableBuilder(
    column: $table.modifiedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dHash => $composableBuilder(
    column: $table.dHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pHash => $composableBuilder(
    column: $table.pHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexedAtMs => $composableBuilder(
    column: $table.indexedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modifiedMs => $composableBuilder(
    column: $table.modifiedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dHash => $composableBuilder(
    column: $table.dHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pHash => $composableBuilder(
    column: $table.pHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexedAtMs => $composableBuilder(
    column: $table.indexedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get modifiedMs => $composableBuilder(
    column: $table.modifiedMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdMs =>
      $composableBuilder(column: $table.createdMs, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dHash =>
      $composableBuilder(column: $table.dHash, builder: (column) => column);

  GeneratedColumn<String> get pHash =>
      $composableBuilder(column: $table.pHash, builder: (column) => column);

  GeneratedColumn<int> get indexedAtMs => $composableBuilder(
    column: $table.indexedAtMs,
    builder: (column) => column,
  );
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> modifiedMs = const Value.absent(),
                Value<int> createdMs = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> dHash = const Value.absent(),
                Value<String?> pHash = const Value.absent(),
                Value<int> indexedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                mediaId: mediaId,
                uri: uri,
                path: path,
                width: width,
                height: height,
                sizeBytes: sizeBytes,
                modifiedMs: modifiedMs,
                createdMs: createdMs,
                mime: mime,
                album: album,
                contentHash: contentHash,
                dHash: dHash,
                pHash: pHash,
                indexedAtMs: indexedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String uri,
                Value<String?> path = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                required int sizeBytes,
                required int modifiedMs,
                Value<int> createdMs = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> dHash = const Value.absent(),
                Value<String?> pHash = const Value.absent(),
                required int indexedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                mediaId: mediaId,
                uri: uri,
                path: path,
                width: width,
                height: height,
                sizeBytes: sizeBytes,
                modifiedMs: modifiedMs,
                createdMs: createdMs,
                mime: mime,
                album: album,
                contentHash: contentHash,
                dHash: dHash,
                pHash: pHash,
                indexedAtMs: indexedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;
typedef $$ScanMetaTableCreateCompanionBuilder =
    ScanMetaCompanion Function({
      Value<int> id,
      Value<int?> lastScanAtMs,
      Value<int> photoCount,
      Value<int> exactGroupCount,
      Value<int> similarGroupCount,
      Value<String?> lastPhase,
    });
typedef $$ScanMetaTableUpdateCompanionBuilder =
    ScanMetaCompanion Function({
      Value<int> id,
      Value<int?> lastScanAtMs,
      Value<int> photoCount,
      Value<int> exactGroupCount,
      Value<int> similarGroupCount,
      Value<String?> lastPhase,
    });

class $$ScanMetaTableFilterComposer
    extends Composer<_$AppDatabase, $ScanMetaTable> {
  $$ScanMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScanAtMs => $composableBuilder(
    column: $table.lastScanAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exactGroupCount => $composableBuilder(
    column: $table.exactGroupCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get similarGroupCount => $composableBuilder(
    column: $table.similarGroupCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPhase => $composableBuilder(
    column: $table.lastPhase,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanMetaTable> {
  $$ScanMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScanAtMs => $composableBuilder(
    column: $table.lastScanAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exactGroupCount => $composableBuilder(
    column: $table.exactGroupCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get similarGroupCount => $composableBuilder(
    column: $table.similarGroupCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPhase => $composableBuilder(
    column: $table.lastPhase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanMetaTable> {
  $$ScanMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastScanAtMs => $composableBuilder(
    column: $table.lastScanAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exactGroupCount => $composableBuilder(
    column: $table.exactGroupCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get similarGroupCount => $composableBuilder(
    column: $table.similarGroupCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPhase =>
      $composableBuilder(column: $table.lastPhase, builder: (column) => column);
}

class $$ScanMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanMetaTable,
          ScanMetaData,
          $$ScanMetaTableFilterComposer,
          $$ScanMetaTableOrderingComposer,
          $$ScanMetaTableAnnotationComposer,
          $$ScanMetaTableCreateCompanionBuilder,
          $$ScanMetaTableUpdateCompanionBuilder,
          (
            ScanMetaData,
            BaseReferences<_$AppDatabase, $ScanMetaTable, ScanMetaData>,
          ),
          ScanMetaData,
          PrefetchHooks Function()
        > {
  $$ScanMetaTableTableManager(_$AppDatabase db, $ScanMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastScanAtMs = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                Value<int> exactGroupCount = const Value.absent(),
                Value<int> similarGroupCount = const Value.absent(),
                Value<String?> lastPhase = const Value.absent(),
              }) => ScanMetaCompanion(
                id: id,
                lastScanAtMs: lastScanAtMs,
                photoCount: photoCount,
                exactGroupCount: exactGroupCount,
                similarGroupCount: similarGroupCount,
                lastPhase: lastPhase,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastScanAtMs = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                Value<int> exactGroupCount = const Value.absent(),
                Value<int> similarGroupCount = const Value.absent(),
                Value<String?> lastPhase = const Value.absent(),
              }) => ScanMetaCompanion.insert(
                id: id,
                lastScanAtMs: lastScanAtMs,
                photoCount: photoCount,
                exactGroupCount: exactGroupCount,
                similarGroupCount: similarGroupCount,
                lastPhase: lastPhase,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanMetaTable,
      ScanMetaData,
      $$ScanMetaTableFilterComposer,
      $$ScanMetaTableOrderingComposer,
      $$ScanMetaTableAnnotationComposer,
      $$ScanMetaTableCreateCompanionBuilder,
      $$ScanMetaTableUpdateCompanionBuilder,
      (
        ScanMetaData,
        BaseReferences<_$AppDatabase, $ScanMetaTable, ScanMetaData>,
      ),
      ScanMetaData,
      PrefetchHooks Function()
    >;
typedef $$ExactGroupsTableCreateCompanionBuilder =
    ExactGroupsCompanion Function({
      Value<int> id,
      required String contentHash,
      required int memberCount,
      Value<int> totalBytes,
    });
typedef $$ExactGroupsTableUpdateCompanionBuilder =
    ExactGroupsCompanion Function({
      Value<int> id,
      Value<String> contentHash,
      Value<int> memberCount,
      Value<int> totalBytes,
    });

class $$ExactGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ExactGroupsTable> {
  $$ExactGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExactGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExactGroupsTable> {
  $$ExactGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExactGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExactGroupsTable> {
  $$ExactGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );
}

class $$ExactGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExactGroupsTable,
          ExactGroup,
          $$ExactGroupsTableFilterComposer,
          $$ExactGroupsTableOrderingComposer,
          $$ExactGroupsTableAnnotationComposer,
          $$ExactGroupsTableCreateCompanionBuilder,
          $$ExactGroupsTableUpdateCompanionBuilder,
          (
            ExactGroup,
            BaseReferences<_$AppDatabase, $ExactGroupsTable, ExactGroup>,
          ),
          ExactGroup,
          PrefetchHooks Function()
        > {
  $$ExactGroupsTableTableManager(_$AppDatabase db, $ExactGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExactGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExactGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExactGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
              }) => ExactGroupsCompanion(
                id: id,
                contentHash: contentHash,
                memberCount: memberCount,
                totalBytes: totalBytes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentHash,
                required int memberCount,
                Value<int> totalBytes = const Value.absent(),
              }) => ExactGroupsCompanion.insert(
                id: id,
                contentHash: contentHash,
                memberCount: memberCount,
                totalBytes: totalBytes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExactGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExactGroupsTable,
      ExactGroup,
      $$ExactGroupsTableFilterComposer,
      $$ExactGroupsTableOrderingComposer,
      $$ExactGroupsTableAnnotationComposer,
      $$ExactGroupsTableCreateCompanionBuilder,
      $$ExactGroupsTableUpdateCompanionBuilder,
      (
        ExactGroup,
        BaseReferences<_$AppDatabase, $ExactGroupsTable, ExactGroup>,
      ),
      ExactGroup,
      PrefetchHooks Function()
    >;
typedef $$ExactGroupMembersTableCreateCompanionBuilder =
    ExactGroupMembersCompanion Function({
      required int groupId,
      required String mediaId,
      Value<int> rowid,
    });
typedef $$ExactGroupMembersTableUpdateCompanionBuilder =
    ExactGroupMembersCompanion Function({
      Value<int> groupId,
      Value<String> mediaId,
      Value<int> rowid,
    });

class $$ExactGroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ExactGroupMembersTable> {
  $$ExactGroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExactGroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ExactGroupMembersTable> {
  $$ExactGroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExactGroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExactGroupMembersTable> {
  $$ExactGroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $$ExactGroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExactGroupMembersTable,
          ExactGroupMember,
          $$ExactGroupMembersTableFilterComposer,
          $$ExactGroupMembersTableOrderingComposer,
          $$ExactGroupMembersTableAnnotationComposer,
          $$ExactGroupMembersTableCreateCompanionBuilder,
          $$ExactGroupMembersTableUpdateCompanionBuilder,
          (
            ExactGroupMember,
            BaseReferences<
              _$AppDatabase,
              $ExactGroupMembersTable,
              ExactGroupMember
            >,
          ),
          ExactGroupMember,
          PrefetchHooks Function()
        > {
  $$ExactGroupMembersTableTableManager(
    _$AppDatabase db,
    $ExactGroupMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExactGroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExactGroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExactGroupMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExactGroupMembersCompanion(
                groupId: groupId,
                mediaId: mediaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required String mediaId,
                Value<int> rowid = const Value.absent(),
              }) => ExactGroupMembersCompanion.insert(
                groupId: groupId,
                mediaId: mediaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExactGroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExactGroupMembersTable,
      ExactGroupMember,
      $$ExactGroupMembersTableFilterComposer,
      $$ExactGroupMembersTableOrderingComposer,
      $$ExactGroupMembersTableAnnotationComposer,
      $$ExactGroupMembersTableCreateCompanionBuilder,
      $$ExactGroupMembersTableUpdateCompanionBuilder,
      (
        ExactGroupMember,
        BaseReferences<
          _$AppDatabase,
          $ExactGroupMembersTable,
          ExactGroupMember
        >,
      ),
      ExactGroupMember,
      PrefetchHooks Function()
    >;
typedef $$SimilarGroupsTableCreateCompanionBuilder =
    SimilarGroupsCompanion Function({
      Value<int> id,
      required int memberCount,
      Value<int> maxDistance,
    });
typedef $$SimilarGroupsTableUpdateCompanionBuilder =
    SimilarGroupsCompanion Function({
      Value<int> id,
      Value<int> memberCount,
      Value<int> maxDistance,
    });

class $$SimilarGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SimilarGroupsTable> {
  $$SimilarGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxDistance => $composableBuilder(
    column: $table.maxDistance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SimilarGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SimilarGroupsTable> {
  $$SimilarGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxDistance => $composableBuilder(
    column: $table.maxDistance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SimilarGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimilarGroupsTable> {
  $$SimilarGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxDistance => $composableBuilder(
    column: $table.maxDistance,
    builder: (column) => column,
  );
}

class $$SimilarGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimilarGroupsTable,
          SimilarGroup,
          $$SimilarGroupsTableFilterComposer,
          $$SimilarGroupsTableOrderingComposer,
          $$SimilarGroupsTableAnnotationComposer,
          $$SimilarGroupsTableCreateCompanionBuilder,
          $$SimilarGroupsTableUpdateCompanionBuilder,
          (
            SimilarGroup,
            BaseReferences<_$AppDatabase, $SimilarGroupsTable, SimilarGroup>,
          ),
          SimilarGroup,
          PrefetchHooks Function()
        > {
  $$SimilarGroupsTableTableManager(_$AppDatabase db, $SimilarGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimilarGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimilarGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SimilarGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int> maxDistance = const Value.absent(),
              }) => SimilarGroupsCompanion(
                id: id,
                memberCount: memberCount,
                maxDistance: maxDistance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int memberCount,
                Value<int> maxDistance = const Value.absent(),
              }) => SimilarGroupsCompanion.insert(
                id: id,
                memberCount: memberCount,
                maxDistance: maxDistance,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SimilarGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimilarGroupsTable,
      SimilarGroup,
      $$SimilarGroupsTableFilterComposer,
      $$SimilarGroupsTableOrderingComposer,
      $$SimilarGroupsTableAnnotationComposer,
      $$SimilarGroupsTableCreateCompanionBuilder,
      $$SimilarGroupsTableUpdateCompanionBuilder,
      (
        SimilarGroup,
        BaseReferences<_$AppDatabase, $SimilarGroupsTable, SimilarGroup>,
      ),
      SimilarGroup,
      PrefetchHooks Function()
    >;
typedef $$SimilarGroupMembersTableCreateCompanionBuilder =
    SimilarGroupMembersCompanion Function({
      required int groupId,
      required String mediaId,
      Value<int> rowid,
    });
typedef $$SimilarGroupMembersTableUpdateCompanionBuilder =
    SimilarGroupMembersCompanion Function({
      Value<int> groupId,
      Value<String> mediaId,
      Value<int> rowid,
    });

class $$SimilarGroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $SimilarGroupMembersTable> {
  $$SimilarGroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SimilarGroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $SimilarGroupMembersTable> {
  $$SimilarGroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SimilarGroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimilarGroupMembersTable> {
  $$SimilarGroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $$SimilarGroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimilarGroupMembersTable,
          SimilarGroupMember,
          $$SimilarGroupMembersTableFilterComposer,
          $$SimilarGroupMembersTableOrderingComposer,
          $$SimilarGroupMembersTableAnnotationComposer,
          $$SimilarGroupMembersTableCreateCompanionBuilder,
          $$SimilarGroupMembersTableUpdateCompanionBuilder,
          (
            SimilarGroupMember,
            BaseReferences<
              _$AppDatabase,
              $SimilarGroupMembersTable,
              SimilarGroupMember
            >,
          ),
          SimilarGroupMember,
          PrefetchHooks Function()
        > {
  $$SimilarGroupMembersTableTableManager(
    _$AppDatabase db,
    $SimilarGroupMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimilarGroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimilarGroupMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SimilarGroupMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SimilarGroupMembersCompanion(
                groupId: groupId,
                mediaId: mediaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required String mediaId,
                Value<int> rowid = const Value.absent(),
              }) => SimilarGroupMembersCompanion.insert(
                groupId: groupId,
                mediaId: mediaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SimilarGroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimilarGroupMembersTable,
      SimilarGroupMember,
      $$SimilarGroupMembersTableFilterComposer,
      $$SimilarGroupMembersTableOrderingComposer,
      $$SimilarGroupMembersTableAnnotationComposer,
      $$SimilarGroupMembersTableCreateCompanionBuilder,
      $$SimilarGroupMembersTableUpdateCompanionBuilder,
      (
        SimilarGroupMember,
        BaseReferences<
          _$AppDatabase,
          $SimilarGroupMembersTable,
          SimilarGroupMember
        >,
      ),
      SimilarGroupMember,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$ScanMetaTableTableManager get scanMeta =>
      $$ScanMetaTableTableManager(_db, _db.scanMeta);
  $$ExactGroupsTableTableManager get exactGroups =>
      $$ExactGroupsTableTableManager(_db, _db.exactGroups);
  $$ExactGroupMembersTableTableManager get exactGroupMembers =>
      $$ExactGroupMembersTableTableManager(_db, _db.exactGroupMembers);
  $$SimilarGroupsTableTableManager get similarGroups =>
      $$SimilarGroupsTableTableManager(_db, _db.similarGroups);
  $$SimilarGroupMembersTableTableManager get similarGroupMembers =>
      $$SimilarGroupMembersTableTableManager(_db, _db.similarGroupMembers);
}
