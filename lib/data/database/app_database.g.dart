// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pdfFilenameMeta = const VerificationMeta(
    'pdfFilename',
  );
  @override
  late final GeneratedColumn<String> pdfFilename = GeneratedColumn<String>(
    'pdf_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ocrProgressMeta = const VerificationMeta(
    'ocrProgress',
  );
  @override
  late final GeneratedColumn<int> ocrProgress = GeneratedColumn<int>(
    'ocr_progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aiProgressMeta = const VerificationMeta(
    'aiProgress',
  );
  @override
  late final GeneratedColumn<int> aiProgress = GeneratedColumn<int>(
    'ai_progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReadPageMeta = const VerificationMeta(
    'lastReadPage',
  );
  @override
  late final GeneratedColumn<int> lastReadPage = GeneratedColumn<int>(
    'last_read_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastScrollOffsetMeta = const VerificationMeta(
    'lastScrollOffset',
  );
  @override
  late final GeneratedColumn<double> lastScrollOffset = GeneratedColumn<double>(
    'last_scroll_offset',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ben'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    author,
    folderName,
    pdfFilename,
    coverPath,
    totalPages,
    ocrProgress,
    aiProgress,
    lastReadPage,
    lastScrollOffset,
    languageCode,
    status,
    fileSize,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('pdf_filename')) {
      context.handle(
        _pdfFilenameMeta,
        pdfFilename.isAcceptableOrUnknown(
          data['pdf_filename']!,
          _pdfFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pdfFilenameMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('ocr_progress')) {
      context.handle(
        _ocrProgressMeta,
        ocrProgress.isAcceptableOrUnknown(
          data['ocr_progress']!,
          _ocrProgressMeta,
        ),
      );
    }
    if (data.containsKey('ai_progress')) {
      context.handle(
        _aiProgressMeta,
        aiProgress.isAcceptableOrUnknown(data['ai_progress']!, _aiProgressMeta),
      );
    }
    if (data.containsKey('last_read_page')) {
      context.handle(
        _lastReadPageMeta,
        lastReadPage.isAcceptableOrUnknown(
          data['last_read_page']!,
          _lastReadPageMeta,
        ),
      );
    }
    if (data.containsKey('last_scroll_offset')) {
      context.handle(
        _lastScrollOffsetMeta,
        lastScrollOffset.isAcceptableOrUnknown(
          data['last_scroll_offset']!,
          _lastScrollOffsetMeta,
        ),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      pdfFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_filename'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
      ocrProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocr_progress'],
      )!,
      aiProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ai_progress'],
      )!,
      lastReadPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_page'],
      )!,
      lastScrollOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_scroll_offset'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String name;
  final String author;
  final String folderName;
  final String pdfFilename;
  final String? coverPath;
  final int totalPages;
  final int ocrProgress;
  final int aiProgress;
  final int lastReadPage;
  final double lastScrollOffset;
  final String languageCode;
  final String status;
  final int fileSize;
  final String createdAt;
  final String updatedAt;
  const Book({
    required this.id,
    required this.name,
    required this.author,
    required this.folderName,
    required this.pdfFilename,
    this.coverPath,
    required this.totalPages,
    required this.ocrProgress,
    required this.aiProgress,
    required this.lastReadPage,
    required this.lastScrollOffset,
    required this.languageCode,
    required this.status,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['author'] = Variable<String>(author);
    map['folder_name'] = Variable<String>(folderName);
    map['pdf_filename'] = Variable<String>(pdfFilename);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['total_pages'] = Variable<int>(totalPages);
    map['ocr_progress'] = Variable<int>(ocrProgress);
    map['ai_progress'] = Variable<int>(aiProgress);
    map['last_read_page'] = Variable<int>(lastReadPage);
    map['last_scroll_offset'] = Variable<double>(lastScrollOffset);
    map['language_code'] = Variable<String>(languageCode);
    map['status'] = Variable<String>(status);
    map['file_size'] = Variable<int>(fileSize);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      name: Value(name),
      author: Value(author),
      folderName: Value(folderName),
      pdfFilename: Value(pdfFilename),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      totalPages: Value(totalPages),
      ocrProgress: Value(ocrProgress),
      aiProgress: Value(aiProgress),
      lastReadPage: Value(lastReadPage),
      lastScrollOffset: Value(lastScrollOffset),
      languageCode: Value(languageCode),
      status: Value(status),
      fileSize: Value(fileSize),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      author: serializer.fromJson<String>(json['author']),
      folderName: serializer.fromJson<String>(json['folderName']),
      pdfFilename: serializer.fromJson<String>(json['pdfFilename']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      ocrProgress: serializer.fromJson<int>(json['ocrProgress']),
      aiProgress: serializer.fromJson<int>(json['aiProgress']),
      lastReadPage: serializer.fromJson<int>(json['lastReadPage']),
      lastScrollOffset: serializer.fromJson<double>(json['lastScrollOffset']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      status: serializer.fromJson<String>(json['status']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String>(author),
      'folderName': serializer.toJson<String>(folderName),
      'pdfFilename': serializer.toJson<String>(pdfFilename),
      'coverPath': serializer.toJson<String?>(coverPath),
      'totalPages': serializer.toJson<int>(totalPages),
      'ocrProgress': serializer.toJson<int>(ocrProgress),
      'aiProgress': serializer.toJson<int>(aiProgress),
      'lastReadPage': serializer.toJson<int>(lastReadPage),
      'lastScrollOffset': serializer.toJson<double>(lastScrollOffset),
      'languageCode': serializer.toJson<String>(languageCode),
      'status': serializer.toJson<String>(status),
      'fileSize': serializer.toJson<int>(fileSize),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Book copyWith({
    String? id,
    String? name,
    String? author,
    String? folderName,
    String? pdfFilename,
    Value<String?> coverPath = const Value.absent(),
    int? totalPages,
    int? ocrProgress,
    int? aiProgress,
    int? lastReadPage,
    double? lastScrollOffset,
    String? languageCode,
    String? status,
    int? fileSize,
    String? createdAt,
    String? updatedAt,
  }) => Book(
    id: id ?? this.id,
    name: name ?? this.name,
    author: author ?? this.author,
    folderName: folderName ?? this.folderName,
    pdfFilename: pdfFilename ?? this.pdfFilename,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    totalPages: totalPages ?? this.totalPages,
    ocrProgress: ocrProgress ?? this.ocrProgress,
    aiProgress: aiProgress ?? this.aiProgress,
    lastReadPage: lastReadPage ?? this.lastReadPage,
    lastScrollOffset: lastScrollOffset ?? this.lastScrollOffset,
    languageCode: languageCode ?? this.languageCode,
    status: status ?? this.status,
    fileSize: fileSize ?? this.fileSize,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      pdfFilename: data.pdfFilename.present
          ? data.pdfFilename.value
          : this.pdfFilename,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      ocrProgress: data.ocrProgress.present
          ? data.ocrProgress.value
          : this.ocrProgress,
      aiProgress: data.aiProgress.present
          ? data.aiProgress.value
          : this.aiProgress,
      lastReadPage: data.lastReadPage.present
          ? data.lastReadPage.value
          : this.lastReadPage,
      lastScrollOffset: data.lastScrollOffset.present
          ? data.lastScrollOffset.value
          : this.lastScrollOffset,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      status: data.status.present ? data.status.value : this.status,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('folderName: $folderName, ')
          ..write('pdfFilename: $pdfFilename, ')
          ..write('coverPath: $coverPath, ')
          ..write('totalPages: $totalPages, ')
          ..write('ocrProgress: $ocrProgress, ')
          ..write('aiProgress: $aiProgress, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('lastScrollOffset: $lastScrollOffset, ')
          ..write('languageCode: $languageCode, ')
          ..write('status: $status, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    author,
    folderName,
    pdfFilename,
    coverPath,
    totalPages,
    ocrProgress,
    aiProgress,
    lastReadPage,
    lastScrollOffset,
    languageCode,
    status,
    fileSize,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.name == this.name &&
          other.author == this.author &&
          other.folderName == this.folderName &&
          other.pdfFilename == this.pdfFilename &&
          other.coverPath == this.coverPath &&
          other.totalPages == this.totalPages &&
          other.ocrProgress == this.ocrProgress &&
          other.aiProgress == this.aiProgress &&
          other.lastReadPage == this.lastReadPage &&
          other.lastScrollOffset == this.lastScrollOffset &&
          other.languageCode == this.languageCode &&
          other.status == this.status &&
          other.fileSize == this.fileSize &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> author;
  final Value<String> folderName;
  final Value<String> pdfFilename;
  final Value<String?> coverPath;
  final Value<int> totalPages;
  final Value<int> ocrProgress;
  final Value<int> aiProgress;
  final Value<int> lastReadPage;
  final Value<double> lastScrollOffset;
  final Value<String> languageCode;
  final Value<String> status;
  final Value<int> fileSize;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.folderName = const Value.absent(),
    this.pdfFilename = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.ocrProgress = const Value.absent(),
    this.aiProgress = const Value.absent(),
    this.lastReadPage = const Value.absent(),
    this.lastScrollOffset = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.status = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String name,
    this.author = const Value.absent(),
    required String folderName,
    required String pdfFilename,
    this.coverPath = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.ocrProgress = const Value.absent(),
    this.aiProgress = const Value.absent(),
    this.lastReadPage = const Value.absent(),
    this.lastScrollOffset = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.status = const Value.absent(),
    this.fileSize = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       folderName = Value(folderName),
       pdfFilename = Value(pdfFilename),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? folderName,
    Expression<String>? pdfFilename,
    Expression<String>? coverPath,
    Expression<int>? totalPages,
    Expression<int>? ocrProgress,
    Expression<int>? aiProgress,
    Expression<int>? lastReadPage,
    Expression<double>? lastScrollOffset,
    Expression<String>? languageCode,
    Expression<String>? status,
    Expression<int>? fileSize,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (folderName != null) 'folder_name': folderName,
      if (pdfFilename != null) 'pdf_filename': pdfFilename,
      if (coverPath != null) 'cover_path': coverPath,
      if (totalPages != null) 'total_pages': totalPages,
      if (ocrProgress != null) 'ocr_progress': ocrProgress,
      if (aiProgress != null) 'ai_progress': aiProgress,
      if (lastReadPage != null) 'last_read_page': lastReadPage,
      if (lastScrollOffset != null) 'last_scroll_offset': lastScrollOffset,
      if (languageCode != null) 'language_code': languageCode,
      if (status != null) 'status': status,
      if (fileSize != null) 'file_size': fileSize,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? author,
    Value<String>? folderName,
    Value<String>? pdfFilename,
    Value<String?>? coverPath,
    Value<int>? totalPages,
    Value<int>? ocrProgress,
    Value<int>? aiProgress,
    Value<int>? lastReadPage,
    Value<double>? lastScrollOffset,
    Value<String>? languageCode,
    Value<String>? status,
    Value<int>? fileSize,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      folderName: folderName ?? this.folderName,
      pdfFilename: pdfFilename ?? this.pdfFilename,
      coverPath: coverPath ?? this.coverPath,
      totalPages: totalPages ?? this.totalPages,
      ocrProgress: ocrProgress ?? this.ocrProgress,
      aiProgress: aiProgress ?? this.aiProgress,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastScrollOffset: lastScrollOffset ?? this.lastScrollOffset,
      languageCode: languageCode ?? this.languageCode,
      status: status ?? this.status,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (pdfFilename.present) {
      map['pdf_filename'] = Variable<String>(pdfFilename.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (ocrProgress.present) {
      map['ocr_progress'] = Variable<int>(ocrProgress.value);
    }
    if (aiProgress.present) {
      map['ai_progress'] = Variable<int>(aiProgress.value);
    }
    if (lastReadPage.present) {
      map['last_read_page'] = Variable<int>(lastReadPage.value);
    }
    if (lastScrollOffset.present) {
      map['last_scroll_offset'] = Variable<double>(lastScrollOffset.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('folderName: $folderName, ')
          ..write('pdfFilename: $pdfFilename, ')
          ..write('coverPath: $coverPath, ')
          ..write('totalPages: $totalPages, ')
          ..write('ocrProgress: $ocrProgress, ')
          ..write('aiProgress: $aiProgress, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('lastScrollOffset: $lastScrollOffset, ')
          ..write('languageCode: $languageCode, ')
          ..write('status: $status, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessingQueueTable extends ProcessingQueue
    with TableInfo<$ProcessingQueueTable, ProcessingQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ocr'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    currentPage,
    phase,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessingQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessingQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProcessingQueueTable createAlias(String alias) {
    return $ProcessingQueueTable(attachedDatabase, alias);
  }
}

class ProcessingQueueData extends DataClass
    implements Insertable<ProcessingQueueData> {
  final String id;
  final String bookId;
  final int currentPage;
  final String phase;
  final String status;
  final String createdAt;
  const ProcessingQueueData({
    required this.id,
    required this.bookId,
    required this.currentPage,
    required this.phase,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['current_page'] = Variable<int>(currentPage);
    map['phase'] = Variable<String>(phase);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ProcessingQueueCompanion toCompanion(bool nullToAbsent) {
    return ProcessingQueueCompanion(
      id: Value(id),
      bookId: Value(bookId),
      currentPage: Value(currentPage),
      phase: Value(phase),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory ProcessingQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingQueueData(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      phase: serializer.fromJson<String>(json['phase']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'currentPage': serializer.toJson<int>(currentPage),
      'phase': serializer.toJson<String>(phase),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ProcessingQueueData copyWith({
    String? id,
    String? bookId,
    int? currentPage,
    String? phase,
    String? status,
    String? createdAt,
  }) => ProcessingQueueData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    currentPage: currentPage ?? this.currentPage,
    phase: phase ?? this.phase,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  ProcessingQueueData copyWithCompanion(ProcessingQueueCompanion data) {
    return ProcessingQueueData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      phase: data.phase.present ? data.phase.value : this.phase,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingQueueData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('currentPage: $currentPage, ')
          ..write('phase: $phase, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, currentPage, phase, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingQueueData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.currentPage == this.currentPage &&
          other.phase == this.phase &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ProcessingQueueCompanion extends UpdateCompanion<ProcessingQueueData> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> currentPage;
  final Value<String> phase;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ProcessingQueueCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.phase = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessingQueueCompanion.insert({
    required String id,
    required String bookId,
    this.currentPage = const Value.absent(),
    this.phase = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       createdAt = Value(createdAt);
  static Insertable<ProcessingQueueData> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? currentPage,
    Expression<String>? phase,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (currentPage != null) 'current_page': currentPage,
      if (phase != null) 'phase': phase,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessingQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? currentPage,
    Value<String>? phase,
    Value<String>? status,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ProcessingQueueCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingQueueCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('currentPage: $currentPage, ')
          ..write('phase: $phase, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ProcessingQueueTable processingQueue = $ProcessingQueueTable(
    this,
  );
  late final BooksDao booksDao = BooksDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    settings,
    processingQueue,
  ];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String name,
      Value<String> author,
      required String folderName,
      required String pdfFilename,
      Value<String?> coverPath,
      Value<int> totalPages,
      Value<int> ocrProgress,
      Value<int> aiProgress,
      Value<int> lastReadPage,
      Value<double> lastScrollOffset,
      Value<String> languageCode,
      Value<String> status,
      Value<int> fileSize,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> author,
      Value<String> folderName,
      Value<String> pdfFilename,
      Value<String?> coverPath,
      Value<int> totalPages,
      Value<int> ocrProgress,
      Value<int> aiProgress,
      Value<int> lastReadPage,
      Value<double> lastScrollOffset,
      Value<String> languageCode,
      Value<String> status,
      Value<int> fileSize,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfFilename => $composableBuilder(
    column: $table.pdfFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocrProgress => $composableBuilder(
    column: $table.ocrProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aiProgress => $composableBuilder(
    column: $table.aiProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastScrollOffset => $composableBuilder(
    column: $table.lastScrollOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfFilename => $composableBuilder(
    column: $table.pdfFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocrProgress => $composableBuilder(
    column: $table.ocrProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aiProgress => $composableBuilder(
    column: $table.aiProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastScrollOffset => $composableBuilder(
    column: $table.lastScrollOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pdfFilename => $composableBuilder(
    column: $table.pdfFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ocrProgress => $composableBuilder(
    column: $table.ocrProgress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aiProgress => $composableBuilder(
    column: $table.aiProgress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastScrollOffset => $composableBuilder(
    column: $table.lastScrollOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<String> pdfFilename = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<int> ocrProgress = const Value.absent(),
                Value<int> aiProgress = const Value.absent(),
                Value<int> lastReadPage = const Value.absent(),
                Value<double> lastScrollOffset = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                name: name,
                author: author,
                folderName: folderName,
                pdfFilename: pdfFilename,
                coverPath: coverPath,
                totalPages: totalPages,
                ocrProgress: ocrProgress,
                aiProgress: aiProgress,
                lastReadPage: lastReadPage,
                lastScrollOffset: lastScrollOffset,
                languageCode: languageCode,
                status: status,
                fileSize: fileSize,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> author = const Value.absent(),
                required String folderName,
                required String pdfFilename,
                Value<String?> coverPath = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<int> ocrProgress = const Value.absent(),
                Value<int> aiProgress = const Value.absent(),
                Value<int> lastReadPage = const Value.absent(),
                Value<double> lastScrollOffset = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                name: name,
                author: author,
                folderName: folderName,
                pdfFilename: pdfFilename,
                coverPath: coverPath,
                totalPages: totalPages,
                ocrProgress: ocrProgress,
                aiProgress: aiProgress,
                lastReadPage: lastReadPage,
                lastScrollOffset: lastScrollOffset,
                languageCode: languageCode,
                status: status,
                fileSize: fileSize,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ProcessingQueueTableCreateCompanionBuilder =
    ProcessingQueueCompanion Function({
      required String id,
      required String bookId,
      Value<int> currentPage,
      Value<String> phase,
      Value<String> status,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$ProcessingQueueTableUpdateCompanionBuilder =
    ProcessingQueueCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> currentPage,
      Value<String> phase,
      Value<String> status,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$ProcessingQueueTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingQueueTable> {
  $$ProcessingQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProcessingQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingQueueTable> {
  $$ProcessingQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProcessingQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingQueueTable> {
  $$ProcessingQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProcessingQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessingQueueTable,
          ProcessingQueueData,
          $$ProcessingQueueTableFilterComposer,
          $$ProcessingQueueTableOrderingComposer,
          $$ProcessingQueueTableAnnotationComposer,
          $$ProcessingQueueTableCreateCompanionBuilder,
          $$ProcessingQueueTableUpdateCompanionBuilder,
          (
            ProcessingQueueData,
            BaseReferences<
              _$AppDatabase,
              $ProcessingQueueTable,
              ProcessingQueueData
            >,
          ),
          ProcessingQueueData,
          PrefetchHooks Function()
        > {
  $$ProcessingQueueTableTableManager(
    _$AppDatabase db,
    $ProcessingQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessingQueueCompanion(
                id: id,
                bookId: bookId,
                currentPage: currentPage,
                phase: phase,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                Value<int> currentPage = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProcessingQueueCompanion.insert(
                id: id,
                bookId: bookId,
                currentPage: currentPage,
                phase: phase,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProcessingQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessingQueueTable,
      ProcessingQueueData,
      $$ProcessingQueueTableFilterComposer,
      $$ProcessingQueueTableOrderingComposer,
      $$ProcessingQueueTableAnnotationComposer,
      $$ProcessingQueueTableCreateCompanionBuilder,
      $$ProcessingQueueTableUpdateCompanionBuilder,
      (
        ProcessingQueueData,
        BaseReferences<
          _$AppDatabase,
          $ProcessingQueueTable,
          ProcessingQueueData
        >,
      ),
      ProcessingQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ProcessingQueueTableTableManager get processingQueue =>
      $$ProcessingQueueTableTableManager(_db, _db.processingQueue);
}
