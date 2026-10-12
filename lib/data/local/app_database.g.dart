// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSettingsRowsTable extends UserSettingsRows
    with TableInfo<$UserSettingsRowsTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<String> voiceId = GeneratedColumn<String>(
    'voice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('calm_female_ru'),
  );
  static const VerificationMeta _speechRateMeta = const VerificationMeta(
    'speechRate',
  );
  @override
  late final GeneratedColumn<double> speechRate = GeneratedColumn<double>(
    'speech_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _pitchMeta = const VerificationMeta('pitch');
  @override
  late final GeneratedColumn<double> pitch = GeneratedColumn<double>(
    'pitch',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _commentLengthMeta = const VerificationMeta(
    'commentLength',
  );
  @override
  late final GeneratedColumn<String> commentLength = GeneratedColumn<String>(
    'comment_length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('short'),
  );
  static const VerificationMeta _defaultTimerMinutesMeta =
      const VerificationMeta('defaultTimerMinutes');
  @override
  late final GeneratedColumn<int> defaultTimerMinutes = GeneratedColumn<int>(
    'default_timer_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _cacheLimitGbMeta = const VerificationMeta(
    'cacheLimitGb',
  );
  @override
  late final GeneratedColumn<int> cacheLimitGb = GeneratedColumn<int>(
    'cache_limit_gb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _newsTopicsCsvMeta = const VerificationMeta(
    'newsTopicsCsv',
  );
  @override
  late final GeneratedColumn<String> newsTopicsCsv = GeneratedColumn<String>(
    'news_topics_csv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('technology,science'),
  );
  static const VerificationMeta _useCloudAiMeta = const VerificationMeta(
    'useCloudAi',
  );
  @override
  late final GeneratedColumn<bool> useCloudAi = GeneratedColumn<bool>(
    'use_cloud_ai',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_cloud_ai" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _booksReadOnlyMeta = const VerificationMeta(
    'booksReadOnly',
  );
  @override
  late final GeneratedColumn<bool> booksReadOnly = GeneratedColumn<bool>(
    'books_read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("books_read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    voiceId,
    speechRate,
    pitch,
    commentLength,
    defaultTimerMinutes,
    cacheLimitGb,
    newsTopicsCsv,
    useCloudAi,
    onboardingCompleted,
    booksReadOnly,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    }
    if (data.containsKey('speech_rate')) {
      context.handle(
        _speechRateMeta,
        speechRate.isAcceptableOrUnknown(data['speech_rate']!, _speechRateMeta),
      );
    }
    if (data.containsKey('pitch')) {
      context.handle(
        _pitchMeta,
        pitch.isAcceptableOrUnknown(data['pitch']!, _pitchMeta),
      );
    }
    if (data.containsKey('comment_length')) {
      context.handle(
        _commentLengthMeta,
        commentLength.isAcceptableOrUnknown(
          data['comment_length']!,
          _commentLengthMeta,
        ),
      );
    }
    if (data.containsKey('default_timer_minutes')) {
      context.handle(
        _defaultTimerMinutesMeta,
        defaultTimerMinutes.isAcceptableOrUnknown(
          data['default_timer_minutes']!,
          _defaultTimerMinutesMeta,
        ),
      );
    }
    if (data.containsKey('cache_limit_gb')) {
      context.handle(
        _cacheLimitGbMeta,
        cacheLimitGb.isAcceptableOrUnknown(
          data['cache_limit_gb']!,
          _cacheLimitGbMeta,
        ),
      );
    }
    if (data.containsKey('news_topics_csv')) {
      context.handle(
        _newsTopicsCsvMeta,
        newsTopicsCsv.isAcceptableOrUnknown(
          data['news_topics_csv']!,
          _newsTopicsCsvMeta,
        ),
      );
    }
    if (data.containsKey('use_cloud_ai')) {
      context.handle(
        _useCloudAiMeta,
        useCloudAi.isAcceptableOrUnknown(
          data['use_cloud_ai']!,
          _useCloudAiMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('books_read_only')) {
      context.handle(
        _booksReadOnlyMeta,
        booksReadOnly.isAcceptableOrUnknown(
          data['books_read_only']!,
          _booksReadOnlyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_id'],
      )!,
      speechRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speech_rate'],
      )!,
      pitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pitch'],
      )!,
      commentLength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_length'],
      )!,
      defaultTimerMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_timer_minutes'],
      )!,
      cacheLimitGb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_limit_gb'],
      )!,
      newsTopicsCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}news_topics_csv'],
      )!,
      useCloudAi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_cloud_ai'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      booksReadOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}books_read_only'],
      )!,
    );
  }

  @override
  $UserSettingsRowsTable createAlias(String alias) {
    return $UserSettingsRowsTable(attachedDatabase, alias);
  }
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  final int id;
  final String voiceId;
  final double speechRate;
  final double pitch;
  final String commentLength;
  final int defaultTimerMinutes;
  final int cacheLimitGb;
  final String newsTopicsCsv;
  final bool useCloudAi;
  final bool onboardingCompleted;
  final bool booksReadOnly;
  const UserSettingsRow({
    required this.id,
    required this.voiceId,
    required this.speechRate,
    required this.pitch,
    required this.commentLength,
    required this.defaultTimerMinutes,
    required this.cacheLimitGb,
    required this.newsTopicsCsv,
    required this.useCloudAi,
    required this.onboardingCompleted,
    required this.booksReadOnly,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['voice_id'] = Variable<String>(voiceId);
    map['speech_rate'] = Variable<double>(speechRate);
    map['pitch'] = Variable<double>(pitch);
    map['comment_length'] = Variable<String>(commentLength);
    map['default_timer_minutes'] = Variable<int>(defaultTimerMinutes);
    map['cache_limit_gb'] = Variable<int>(cacheLimitGb);
    map['news_topics_csv'] = Variable<String>(newsTopicsCsv);
    map['use_cloud_ai'] = Variable<bool>(useCloudAi);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['books_read_only'] = Variable<bool>(booksReadOnly);
    return map;
  }

  UserSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsRowsCompanion(
      id: Value(id),
      voiceId: Value(voiceId),
      speechRate: Value(speechRate),
      pitch: Value(pitch),
      commentLength: Value(commentLength),
      defaultTimerMinutes: Value(defaultTimerMinutes),
      cacheLimitGb: Value(cacheLimitGb),
      newsTopicsCsv: Value(newsTopicsCsv),
      useCloudAi: Value(useCloudAi),
      onboardingCompleted: Value(onboardingCompleted),
      booksReadOnly: Value(booksReadOnly),
    );
  }

  factory UserSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      voiceId: serializer.fromJson<String>(json['voiceId']),
      speechRate: serializer.fromJson<double>(json['speechRate']),
      pitch: serializer.fromJson<double>(json['pitch']),
      commentLength: serializer.fromJson<String>(json['commentLength']),
      defaultTimerMinutes: serializer.fromJson<int>(
        json['defaultTimerMinutes'],
      ),
      cacheLimitGb: serializer.fromJson<int>(json['cacheLimitGb']),
      newsTopicsCsv: serializer.fromJson<String>(json['newsTopicsCsv']),
      useCloudAi: serializer.fromJson<bool>(json['useCloudAi']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      booksReadOnly: serializer.fromJson<bool>(json['booksReadOnly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'voiceId': serializer.toJson<String>(voiceId),
      'speechRate': serializer.toJson<double>(speechRate),
      'pitch': serializer.toJson<double>(pitch),
      'commentLength': serializer.toJson<String>(commentLength),
      'defaultTimerMinutes': serializer.toJson<int>(defaultTimerMinutes),
      'cacheLimitGb': serializer.toJson<int>(cacheLimitGb),
      'newsTopicsCsv': serializer.toJson<String>(newsTopicsCsv),
      'useCloudAi': serializer.toJson<bool>(useCloudAi),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'booksReadOnly': serializer.toJson<bool>(booksReadOnly),
    };
  }

  UserSettingsRow copyWith({
    int? id,
    String? voiceId,
    double? speechRate,
    double? pitch,
    String? commentLength,
    int? defaultTimerMinutes,
    int? cacheLimitGb,
    String? newsTopicsCsv,
    bool? useCloudAi,
    bool? onboardingCompleted,
    bool? booksReadOnly,
  }) => UserSettingsRow(
    id: id ?? this.id,
    voiceId: voiceId ?? this.voiceId,
    speechRate: speechRate ?? this.speechRate,
    pitch: pitch ?? this.pitch,
    commentLength: commentLength ?? this.commentLength,
    defaultTimerMinutes: defaultTimerMinutes ?? this.defaultTimerMinutes,
    cacheLimitGb: cacheLimitGb ?? this.cacheLimitGb,
    newsTopicsCsv: newsTopicsCsv ?? this.newsTopicsCsv,
    useCloudAi: useCloudAi ?? this.useCloudAi,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    booksReadOnly: booksReadOnly ?? this.booksReadOnly,
  );
  UserSettingsRow copyWithCompanion(UserSettingsRowsCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      speechRate: data.speechRate.present
          ? data.speechRate.value
          : this.speechRate,
      pitch: data.pitch.present ? data.pitch.value : this.pitch,
      commentLength: data.commentLength.present
          ? data.commentLength.value
          : this.commentLength,
      defaultTimerMinutes: data.defaultTimerMinutes.present
          ? data.defaultTimerMinutes.value
          : this.defaultTimerMinutes,
      cacheLimitGb: data.cacheLimitGb.present
          ? data.cacheLimitGb.value
          : this.cacheLimitGb,
      newsTopicsCsv: data.newsTopicsCsv.present
          ? data.newsTopicsCsv.value
          : this.newsTopicsCsv,
      useCloudAi: data.useCloudAi.present
          ? data.useCloudAi.value
          : this.useCloudAi,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      booksReadOnly: data.booksReadOnly.present
          ? data.booksReadOnly.value
          : this.booksReadOnly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('voiceId: $voiceId, ')
          ..write('speechRate: $speechRate, ')
          ..write('pitch: $pitch, ')
          ..write('commentLength: $commentLength, ')
          ..write('defaultTimerMinutes: $defaultTimerMinutes, ')
          ..write('cacheLimitGb: $cacheLimitGb, ')
          ..write('newsTopicsCsv: $newsTopicsCsv, ')
          ..write('useCloudAi: $useCloudAi, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('booksReadOnly: $booksReadOnly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    voiceId,
    speechRate,
    pitch,
    commentLength,
    defaultTimerMinutes,
    cacheLimitGb,
    newsTopicsCsv,
    useCloudAi,
    onboardingCompleted,
    booksReadOnly,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.voiceId == this.voiceId &&
          other.speechRate == this.speechRate &&
          other.pitch == this.pitch &&
          other.commentLength == this.commentLength &&
          other.defaultTimerMinutes == this.defaultTimerMinutes &&
          other.cacheLimitGb == this.cacheLimitGb &&
          other.newsTopicsCsv == this.newsTopicsCsv &&
          other.useCloudAi == this.useCloudAi &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.booksReadOnly == this.booksReadOnly);
}

class UserSettingsRowsCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<int> id;
  final Value<String> voiceId;
  final Value<double> speechRate;
  final Value<double> pitch;
  final Value<String> commentLength;
  final Value<int> defaultTimerMinutes;
  final Value<int> cacheLimitGb;
  final Value<String> newsTopicsCsv;
  final Value<bool> useCloudAi;
  final Value<bool> onboardingCompleted;
  final Value<bool> booksReadOnly;
  const UserSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.speechRate = const Value.absent(),
    this.pitch = const Value.absent(),
    this.commentLength = const Value.absent(),
    this.defaultTimerMinutes = const Value.absent(),
    this.cacheLimitGb = const Value.absent(),
    this.newsTopicsCsv = const Value.absent(),
    this.useCloudAi = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.booksReadOnly = const Value.absent(),
  });
  UserSettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.speechRate = const Value.absent(),
    this.pitch = const Value.absent(),
    this.commentLength = const Value.absent(),
    this.defaultTimerMinutes = const Value.absent(),
    this.cacheLimitGb = const Value.absent(),
    this.newsTopicsCsv = const Value.absent(),
    this.useCloudAi = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.booksReadOnly = const Value.absent(),
  });
  static Insertable<UserSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? voiceId,
    Expression<double>? speechRate,
    Expression<double>? pitch,
    Expression<String>? commentLength,
    Expression<int>? defaultTimerMinutes,
    Expression<int>? cacheLimitGb,
    Expression<String>? newsTopicsCsv,
    Expression<bool>? useCloudAi,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? booksReadOnly,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voiceId != null) 'voice_id': voiceId,
      if (speechRate != null) 'speech_rate': speechRate,
      if (pitch != null) 'pitch': pitch,
      if (commentLength != null) 'comment_length': commentLength,
      if (defaultTimerMinutes != null)
        'default_timer_minutes': defaultTimerMinutes,
      if (cacheLimitGb != null) 'cache_limit_gb': cacheLimitGb,
      if (newsTopicsCsv != null) 'news_topics_csv': newsTopicsCsv,
      if (useCloudAi != null) 'use_cloud_ai': useCloudAi,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (booksReadOnly != null) 'books_read_only': booksReadOnly,
    });
  }

  UserSettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? voiceId,
    Value<double>? speechRate,
    Value<double>? pitch,
    Value<String>? commentLength,
    Value<int>? defaultTimerMinutes,
    Value<int>? cacheLimitGb,
    Value<String>? newsTopicsCsv,
    Value<bool>? useCloudAi,
    Value<bool>? onboardingCompleted,
    Value<bool>? booksReadOnly,
  }) {
    return UserSettingsRowsCompanion(
      id: id ?? this.id,
      voiceId: voiceId ?? this.voiceId,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      commentLength: commentLength ?? this.commentLength,
      defaultTimerMinutes: defaultTimerMinutes ?? this.defaultTimerMinutes,
      cacheLimitGb: cacheLimitGb ?? this.cacheLimitGb,
      newsTopicsCsv: newsTopicsCsv ?? this.newsTopicsCsv,
      useCloudAi: useCloudAi ?? this.useCloudAi,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      booksReadOnly: booksReadOnly ?? this.booksReadOnly,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<String>(voiceId.value);
    }
    if (speechRate.present) {
      map['speech_rate'] = Variable<double>(speechRate.value);
    }
    if (pitch.present) {
      map['pitch'] = Variable<double>(pitch.value);
    }
    if (commentLength.present) {
      map['comment_length'] = Variable<String>(commentLength.value);
    }
    if (defaultTimerMinutes.present) {
      map['default_timer_minutes'] = Variable<int>(defaultTimerMinutes.value);
    }
    if (cacheLimitGb.present) {
      map['cache_limit_gb'] = Variable<int>(cacheLimitGb.value);
    }
    if (newsTopicsCsv.present) {
      map['news_topics_csv'] = Variable<String>(newsTopicsCsv.value);
    }
    if (useCloudAi.present) {
      map['use_cloud_ai'] = Variable<bool>(useCloudAi.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (booksReadOnly.present) {
      map['books_read_only'] = Variable<bool>(booksReadOnly.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('voiceId: $voiceId, ')
          ..write('speechRate: $speechRate, ')
          ..write('pitch: $pitch, ')
          ..write('commentLength: $commentLength, ')
          ..write('defaultTimerMinutes: $defaultTimerMinutes, ')
          ..write('cacheLimitGb: $cacheLimitGb, ')
          ..write('newsTopicsCsv: $newsTopicsCsv, ')
          ..write('useCloudAi: $useCloudAi, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('booksReadOnly: $booksReadOnly')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
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
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _charOffsetMeta = const VerificationMeta(
    'charOffset',
  );
  @override
  late final GeneratedColumn<int> charOffset = GeneratedColumn<int>(
    'char_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<double> percent = GeneratedColumn<double>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    filePath,
    format,
    coverPath,
    chapterId,
    charOffset,
    percent,
    importedAt,
    lastOpenedAt,
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('char_offset')) {
      context.handle(
        _charOffsetMeta,
        charOffset.isAcceptableOrUnknown(data['char_offset']!, _charOffsetMeta),
      );
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
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
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      ),
      charOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_offset'],
      )!,
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percent'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String title;
  final String? author;
  final String filePath;
  final String format;
  final String? coverPath;
  final String? chapterId;
  final int charOffset;
  final double percent;
  final DateTime? importedAt;
  final DateTime? lastOpenedAt;
  const Book({
    required this.id,
    required this.title,
    this.author,
    required this.filePath,
    required this.format,
    this.coverPath,
    this.chapterId,
    required this.charOffset,
    required this.percent,
    this.importedAt,
    this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['file_path'] = Variable<String>(filePath);
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    map['char_offset'] = Variable<int>(charOffset);
    map['percent'] = Variable<double>(percent);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      filePath: Value(filePath),
      format: Value(format),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      charOffset: Value(charOffset),
      percent: Value(percent),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      filePath: serializer.fromJson<String>(json['filePath']),
      format: serializer.fromJson<String>(json['format']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      charOffset: serializer.fromJson<int>(json['charOffset']),
      percent: serializer.fromJson<double>(json['percent']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'filePath': serializer.toJson<String>(filePath),
      'format': serializer.toJson<String>(format),
      'coverPath': serializer.toJson<String?>(coverPath),
      'chapterId': serializer.toJson<String?>(chapterId),
      'charOffset': serializer.toJson<int>(charOffset),
      'percent': serializer.toJson<double>(percent),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    Value<String?> author = const Value.absent(),
    String? filePath,
    String? format,
    Value<String?> coverPath = const Value.absent(),
    Value<String?> chapterId = const Value.absent(),
    int? charOffset,
    double? percent,
    Value<DateTime?> importedAt = const Value.absent(),
    Value<DateTime?> lastOpenedAt = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    filePath: filePath ?? this.filePath,
    format: format ?? this.format,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    charOffset: charOffset ?? this.charOffset,
    percent: percent ?? this.percent,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      format: data.format.present ? data.format.value : this.format,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      charOffset: data.charOffset.present
          ? data.charOffset.value
          : this.charOffset,
      percent: data.percent.present ? data.percent.value : this.percent,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('filePath: $filePath, ')
          ..write('format: $format, ')
          ..write('coverPath: $coverPath, ')
          ..write('chapterId: $chapterId, ')
          ..write('charOffset: $charOffset, ')
          ..write('percent: $percent, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    filePath,
    format,
    coverPath,
    chapterId,
    charOffset,
    percent,
    importedAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.filePath == this.filePath &&
          other.format == this.format &&
          other.coverPath == this.coverPath &&
          other.chapterId == this.chapterId &&
          other.charOffset == this.charOffset &&
          other.percent == this.percent &&
          other.importedAt == this.importedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> filePath;
  final Value<String> format;
  final Value<String?> coverPath;
  final Value<String?> chapterId;
  final Value<int> charOffset;
  final Value<double> percent;
  final Value<DateTime?> importedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.filePath = const Value.absent(),
    this.format = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.percent = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    required String filePath,
    required String format,
    this.coverPath = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.percent = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       filePath = Value(filePath),
       format = Value(format);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? filePath,
    Expression<String>? format,
    Expression<String>? coverPath,
    Expression<String>? chapterId,
    Expression<int>? charOffset,
    Expression<double>? percent,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (filePath != null) 'file_path': filePath,
      if (format != null) 'format': format,
      if (coverPath != null) 'cover_path': coverPath,
      if (chapterId != null) 'chapter_id': chapterId,
      if (charOffset != null) 'char_offset': charOffset,
      if (percent != null) 'percent': percent,
      if (importedAt != null) 'imported_at': importedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? filePath,
    Value<String>? format,
    Value<String?>? coverPath,
    Value<String?>? chapterId,
    Value<int>? charOffset,
    Value<double>? percent,
    Value<DateTime?>? importedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      coverPath: coverPath ?? this.coverPath,
      chapterId: chapterId ?? this.chapterId,
      charOffset: charOffset ?? this.charOffset,
      percent: percent ?? this.percent,
      importedAt: importedAt ?? this.importedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (charOffset.present) {
      map['char_offset'] = Variable<int>(charOffset.value);
    }
    if (percent.present) {
      map['percent'] = Variable<double>(percent.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
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
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('filePath: $filePath, ')
          ..write('format: $format, ')
          ..write('coverPath: $coverPath, ')
          ..write('chapterId: $chapterId, ')
          ..write('charOffset: $charOffset, ')
          ..write('percent: $percent, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookChaptersTable extends BookChapters
    with TableInfo<$BookChaptersTable, BookChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookChaptersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    title,
    orderIndex,
    startOffset,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookChapter> instance, {
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookChapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $BookChaptersTable createAlias(String alias) {
    return $BookChaptersTable(attachedDatabase, alias);
  }
}

class BookChapter extends DataClass implements Insertable<BookChapter> {
  final String id;
  final String bookId;
  final String title;
  final int orderIndex;
  final int startOffset;
  final String content;
  const BookChapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.orderIndex,
    required this.startOffset,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['title'] = Variable<String>(title);
    map['order_index'] = Variable<int>(orderIndex);
    map['start_offset'] = Variable<int>(startOffset);
    map['content'] = Variable<String>(content);
    return map;
  }

  BookChaptersCompanion toCompanion(bool nullToAbsent) {
    return BookChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      title: Value(title),
      orderIndex: Value(orderIndex),
      startOffset: Value(startOffset),
      content: Value(content),
    );
  }

  factory BookChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookChapter(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String>(title),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'startOffset': serializer.toJson<int>(startOffset),
      'content': serializer.toJson<String>(content),
    };
  }

  BookChapter copyWith({
    String? id,
    String? bookId,
    String? title,
    int? orderIndex,
    int? startOffset,
    String? content,
  }) => BookChapter(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    orderIndex: orderIndex ?? this.orderIndex,
    startOffset: startOffset ?? this.startOffset,
    content: content ?? this.content,
  );
  BookChapter copyWithCompanion(BookChaptersCompanion data) {
    return BookChapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookChapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, title, orderIndex, startOffset, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookChapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.orderIndex == this.orderIndex &&
          other.startOffset == this.startOffset &&
          other.content == this.content);
}

class BookChaptersCompanion extends UpdateCompanion<BookChapter> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> title;
  final Value<int> orderIndex;
  final Value<int> startOffset;
  final Value<String> content;
  final Value<int> rowid;
  const BookChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookChaptersCompanion.insert({
    required String id,
    required String bookId,
    required String title,
    required int orderIndex,
    this.startOffset = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       title = Value(title),
       orderIndex = Value(orderIndex);
  static Insertable<BookChapter> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<int>? orderIndex,
    Expression<int>? startOffset,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (orderIndex != null) 'order_index': orderIndex,
      if (startOffset != null) 'start_offset': startOffset,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? title,
    Value<int>? orderIndex,
    Value<int>? startOffset,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return BookChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      startOffset: startOffset ?? this.startOffset,
      content: content ?? this.content,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceMaterialsTable extends SourceMaterials
    with TableInfo<$SourceMaterialsTable, SourceMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedTextMeta = const VerificationMeta(
    'extractedText',
  );
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
    'extracted_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    rawText,
    extractedText,
    status,
    errorMessage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceMaterial> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('extracted_text')) {
      context.handle(
        _extractedTextMeta,
        extractedText.isAcceptableOrUnknown(
          data['extracted_text']!,
          _extractedTextMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceMaterial(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      extractedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_text'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $SourceMaterialsTable createAlias(String alias) {
    return $SourceMaterialsTable(attachedDatabase, alias);
  }
}

class SourceMaterial extends DataClass implements Insertable<SourceMaterial> {
  final String id;
  final String title;
  final String? url;
  final String? rawText;
  final String? extractedText;
  final String status;
  final String? errorMessage;
  final DateTime? createdAt;
  const SourceMaterial({
    required this.id,
    required this.title,
    this.url,
    this.rawText,
    this.extractedText,
    required this.status,
    this.errorMessage,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || extractedText != null) {
      map['extracted_text'] = Variable<String>(extractedText);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  SourceMaterialsCompanion toCompanion(bool nullToAbsent) {
    return SourceMaterialsCompanion(
      id: Value(id),
      title: Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      extractedText: extractedText == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedText),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory SourceMaterial.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceMaterial(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      extractedText: serializer.fromJson<String?>(json['extractedText']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String?>(url),
      'rawText': serializer.toJson<String?>(rawText),
      'extractedText': serializer.toJson<String?>(extractedText),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  SourceMaterial copyWith({
    String? id,
    String? title,
    Value<String?> url = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
    Value<String?> extractedText = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => SourceMaterial(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url.present ? url.value : this.url,
    rawText: rawText.present ? rawText.value : this.rawText,
    extractedText: extractedText.present
        ? extractedText.value
        : this.extractedText,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  SourceMaterial copyWithCompanion(SourceMaterialsCompanion data) {
    return SourceMaterial(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      extractedText: data.extractedText.present
          ? data.extractedText.value
          : this.extractedText,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceMaterial(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('rawText: $rawText, ')
          ..write('extractedText: $extractedText, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    url,
    rawText,
    extractedText,
    status,
    errorMessage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceMaterial &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.rawText == this.rawText &&
          other.extractedText == this.extractedText &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class SourceMaterialsCompanion extends UpdateCompanion<SourceMaterial> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> url;
  final Value<String?> rawText;
  final Value<String?> extractedText;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const SourceMaterialsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.rawText = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceMaterialsCompanion.insert({
    required String id,
    required String title,
    this.url = const Value.absent(),
    this.rawText = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<SourceMaterial> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? rawText,
    Expression<String>? extractedText,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (rawText != null) 'raw_text': rawText,
      if (extractedText != null) 'extracted_text': extractedText,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceMaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? url,
    Value<String?>? rawText,
    Value<String?>? extractedText,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return SourceMaterialsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      rawText: rawText ?? this.rawText,
      extractedText: extractedText ?? this.extractedText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('rawText: $rawText, ')
          ..write('extractedText: $extractedText, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scriptMeta = const VerificationMeta('script');
  @override
  late final GeneratedColumn<String> script = GeneratedColumn<String>(
    'script',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    script,
    audioPath,
    durationMs,
    sourceId,
    isFavorite,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('script')) {
      context.handle(
        _scriptMeta,
        script.isAcceptableOrUnknown(data['script']!, _scriptMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      script: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  final String id;
  final String title;
  final String type;
  final String? script;
  final String? audioPath;
  final int? durationMs;
  final String? sourceId;
  final bool isFavorite;
  final DateTime? createdAt;
  const Episode({
    required this.id,
    required this.title,
    required this.type,
    this.script,
    this.audioPath,
    this.durationMs,
    this.sourceId,
    required this.isFavorite,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || script != null) {
      map['script'] = Variable<String>(script);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      script: script == null && nullToAbsent
          ? const Value.absent()
          : Value(script),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      isFavorite: Value(isFavorite),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      script: serializer.fromJson<String?>(json['script']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'script': serializer.toJson<String?>(script),
      'audioPath': serializer.toJson<String?>(audioPath),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sourceId': serializer.toJson<String?>(sourceId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Episode copyWith({
    String? id,
    String? title,
    String? type,
    Value<String?> script = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    bool? isFavorite,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Episode(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    script: script.present ? script.value : this.script,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      script: data.script.present ? data.script.value : this.script,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('script: $script, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceId: $sourceId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    script,
    audioPath,
    durationMs,
    sourceId,
    isFavorite,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.script == this.script &&
          other.audioPath == this.audioPath &&
          other.durationMs == this.durationMs &&
          other.sourceId == this.sourceId &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> script;
  final Value<String?> audioPath;
  final Value<int?> durationMs;
  final Value<String?> sourceId;
  final Value<bool> isFavorite;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.script = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodesCompanion.insert({
    required String id,
    required String title,
    required String type,
    this.script = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type);
  static Insertable<Episode> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? script,
    Expression<String>? audioPath,
    Expression<int>? durationMs,
    Expression<String>? sourceId,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (script != null) 'script': script,
      if (audioPath != null) 'audio_path': audioPath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sourceId != null) 'source_id': sourceId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<String?>? script,
    Value<String?>? audioPath,
    Value<int?>? durationMs,
    Value<String?>? sourceId,
    Value<bool>? isFavorite,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      script: script ?? this.script,
      audioPath: audioPath ?? this.audioPath,
      durationMs: durationMs ?? this.durationMs,
      sourceId: sourceId ?? this.sourceId,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (script.present) {
      map['script'] = Variable<String>(script.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('script: $script, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceId: $sourceId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListenHistoryRowsTable extends ListenHistoryRows
    with TableInfo<$ListenHistoryRowsTable, ListenHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListenHistoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<String> episodeId = GeneratedColumn<String>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    episodeId,
    startedAt,
    endedAt,
    listenedMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listen_history_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListenHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListenHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListenHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      )!,
    );
  }

  @override
  $ListenHistoryRowsTable createAlias(String alias) {
    return $ListenHistoryRowsTable(attachedDatabase, alias);
  }
}

class ListenHistoryRow extends DataClass
    implements Insertable<ListenHistoryRow> {
  final String id;
  final String episodeId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int listenedMs;
  const ListenHistoryRow({
    required this.id,
    required this.episodeId,
    required this.startedAt,
    this.endedAt,
    required this.listenedMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['episode_id'] = Variable<String>(episodeId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['listened_ms'] = Variable<int>(listenedMs);
    return map;
  }

  ListenHistoryRowsCompanion toCompanion(bool nullToAbsent) {
    return ListenHistoryRowsCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      listenedMs: Value(listenedMs),
    );
  }

  factory ListenHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListenHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      episodeId: serializer.fromJson<String>(json['episodeId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      listenedMs: serializer.fromJson<int>(json['listenedMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'episodeId': serializer.toJson<String>(episodeId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'listenedMs': serializer.toJson<int>(listenedMs),
    };
  }

  ListenHistoryRow copyWith({
    String? id,
    String? episodeId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? listenedMs,
  }) => ListenHistoryRow(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    listenedMs: listenedMs ?? this.listenedMs,
  );
  ListenHistoryRow copyWithCompanion(ListenHistoryRowsCompanion data) {
    return ListenHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListenHistoryRow(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('listenedMs: $listenedMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, episodeId, startedAt, endedAt, listenedMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListenHistoryRow &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.listenedMs == this.listenedMs);
}

class ListenHistoryRowsCompanion extends UpdateCompanion<ListenHistoryRow> {
  final Value<String> id;
  final Value<String> episodeId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> listenedMs;
  final Value<int> rowid;
  const ListenHistoryRowsCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListenHistoryRowsCompanion.insert({
    required String id,
    required String episodeId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       episodeId = Value(episodeId),
       startedAt = Value(startedAt);
  static Insertable<ListenHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? episodeId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? listenedMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (listenedMs != null) 'listened_ms': listenedMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListenHistoryRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? episodeId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? listenedMs,
    Value<int>? rowid,
  }) {
    return ListenHistoryRowsCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      listenedMs: listenedMs ?? this.listenedMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListenHistoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsRowsTable userSettingsRows = $UserSettingsRowsTable(
    this,
  );
  late final $BooksTable books = $BooksTable(this);
  late final $BookChaptersTable bookChapters = $BookChaptersTable(this);
  late final $SourceMaterialsTable sourceMaterials = $SourceMaterialsTable(
    this,
  );
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $ListenHistoryRowsTable listenHistoryRows =
      $ListenHistoryRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userSettingsRows,
    books,
    bookChapters,
    sourceMaterials,
    episodes,
    listenHistoryRows,
  ];
}

typedef $$UserSettingsRowsTableCreateCompanionBuilder =
    UserSettingsRowsCompanion Function({
      Value<int> id,
      Value<String> voiceId,
      Value<double> speechRate,
      Value<double> pitch,
      Value<String> commentLength,
      Value<int> defaultTimerMinutes,
      Value<int> cacheLimitGb,
      Value<String> newsTopicsCsv,
      Value<bool> useCloudAi,
      Value<bool> onboardingCompleted,
      Value<bool> booksReadOnly,
    });
typedef $$UserSettingsRowsTableUpdateCompanionBuilder =
    UserSettingsRowsCompanion Function({
      Value<int> id,
      Value<String> voiceId,
      Value<double> speechRate,
      Value<double> pitch,
      Value<String> commentLength,
      Value<int> defaultTimerMinutes,
      Value<int> cacheLimitGb,
      Value<String> newsTopicsCsv,
      Value<bool> useCloudAi,
      Value<bool> onboardingCompleted,
      Value<bool> booksReadOnly,
    });

class $$UserSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsRowsTable> {
  $$UserSettingsRowsTableFilterComposer({
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

  ColumnFilters<String> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pitch => $composableBuilder(
    column: $table.pitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentLength => $composableBuilder(
    column: $table.commentLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTimerMinutes => $composableBuilder(
    column: $table.defaultTimerMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheLimitGb => $composableBuilder(
    column: $table.cacheLimitGb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newsTopicsCsv => $composableBuilder(
    column: $table.newsTopicsCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useCloudAi => $composableBuilder(
    column: $table.useCloudAi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get booksReadOnly => $composableBuilder(
    column: $table.booksReadOnly,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsRowsTable> {
  $$UserSettingsRowsTableOrderingComposer({
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

  ColumnOrderings<String> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pitch => $composableBuilder(
    column: $table.pitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentLength => $composableBuilder(
    column: $table.commentLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTimerMinutes => $composableBuilder(
    column: $table.defaultTimerMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheLimitGb => $composableBuilder(
    column: $table.cacheLimitGb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newsTopicsCsv => $composableBuilder(
    column: $table.newsTopicsCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useCloudAi => $composableBuilder(
    column: $table.useCloudAi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get booksReadOnly => $composableBuilder(
    column: $table.booksReadOnly,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsRowsTable> {
  $$UserSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pitch =>
      $composableBuilder(column: $table.pitch, builder: (column) => column);

  GeneratedColumn<String> get commentLength => $composableBuilder(
    column: $table.commentLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTimerMinutes => $composableBuilder(
    column: $table.defaultTimerMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cacheLimitGb => $composableBuilder(
    column: $table.cacheLimitGb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newsTopicsCsv => $composableBuilder(
    column: $table.newsTopicsCsv,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get useCloudAi => $composableBuilder(
    column: $table.useCloudAi,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get booksReadOnly => $composableBuilder(
    column: $table.booksReadOnly,
    builder: (column) => column,
  );
}

class $$UserSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsRowsTable,
          UserSettingsRow,
          $$UserSettingsRowsTableFilterComposer,
          $$UserSettingsRowsTableOrderingComposer,
          $$UserSettingsRowsTableAnnotationComposer,
          $$UserSettingsRowsTableCreateCompanionBuilder,
          $$UserSettingsRowsTableUpdateCompanionBuilder,
          (
            UserSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsRowsTable,
              UserSettingsRow
            >,
          ),
          UserSettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsRowsTableTableManager(
    _$AppDatabase db,
    $UserSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> voiceId = const Value.absent(),
                Value<double> speechRate = const Value.absent(),
                Value<double> pitch = const Value.absent(),
                Value<String> commentLength = const Value.absent(),
                Value<int> defaultTimerMinutes = const Value.absent(),
                Value<int> cacheLimitGb = const Value.absent(),
                Value<String> newsTopicsCsv = const Value.absent(),
                Value<bool> useCloudAi = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> booksReadOnly = const Value.absent(),
              }) => UserSettingsRowsCompanion(
                id: id,
                voiceId: voiceId,
                speechRate: speechRate,
                pitch: pitch,
                commentLength: commentLength,
                defaultTimerMinutes: defaultTimerMinutes,
                cacheLimitGb: cacheLimitGb,
                newsTopicsCsv: newsTopicsCsv,
                useCloudAi: useCloudAi,
                onboardingCompleted: onboardingCompleted,
                booksReadOnly: booksReadOnly,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> voiceId = const Value.absent(),
                Value<double> speechRate = const Value.absent(),
                Value<double> pitch = const Value.absent(),
                Value<String> commentLength = const Value.absent(),
                Value<int> defaultTimerMinutes = const Value.absent(),
                Value<int> cacheLimitGb = const Value.absent(),
                Value<String> newsTopicsCsv = const Value.absent(),
                Value<bool> useCloudAi = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> booksReadOnly = const Value.absent(),
              }) => UserSettingsRowsCompanion.insert(
                id: id,
                voiceId: voiceId,
                speechRate: speechRate,
                pitch: pitch,
                commentLength: commentLength,
                defaultTimerMinutes: defaultTimerMinutes,
                cacheLimitGb: cacheLimitGb,
                newsTopicsCsv: newsTopicsCsv,
                useCloudAi: useCloudAi,
                onboardingCompleted: onboardingCompleted,
                booksReadOnly: booksReadOnly,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsRowsTable, UserSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsRowsTable,
                    UserSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsRowsTable,
      UserSettingsRow,
      $$UserSettingsRowsTableFilterComposer,
      $$UserSettingsRowsTableOrderingComposer,
      $$UserSettingsRowsTableAnnotationComposer,
      $$UserSettingsRowsTableCreateCompanionBuilder,
      $$UserSettingsRowsTableUpdateCompanionBuilder,
      (
        UserSettingsRow,
        BaseReferences<_$AppDatabase, $UserSettingsRowsTable, UserSettingsRow>,
      ),
      UserSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String title,
      Value<String?> author,
      required String filePath,
      required String format,
      Value<String?> coverPath,
      Value<String?> chapterId,
      Value<int> charOffset,
      Value<double> percent,
      Value<DateTime?> importedAt,
      Value<DateTime?> lastOpenedAt,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> author,
      Value<String> filePath,
      Value<String> format,
      Value<String?> coverPath,
      Value<String?> chapterId,
      Value<int> charOffset,
      Value<double> percent,
      Value<DateTime?> importedAt,
      Value<DateTime?> lastOpenedAt,
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );
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
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> chapterId = const Value.absent(),
                Value<int> charOffset = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                filePath: filePath,
                format: format,
                coverPath: coverPath,
                chapterId: chapterId,
                charOffset: charOffset,
                percent: percent,
                importedAt: importedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> author = const Value.absent(),
                required String filePath,
                required String format,
                Value<String?> coverPath = const Value.absent(),
                Value<String?> chapterId = const Value.absent(),
                Value<int> charOffset = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                filePath: filePath,
                format: format,
                coverPath: coverPath,
                chapterId: chapterId,
                charOffset: charOffset,
                percent: percent,
                importedAt: importedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  BaseReferences<_$AppDatabase, $BooksTable, Book>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
typedef $$BookChaptersTableCreateCompanionBuilder =
    BookChaptersCompanion Function({
      required String id,
      required String bookId,
      required String title,
      required int orderIndex,
      Value<int> startOffset,
      Value<String> content,
      Value<int> rowid,
    });
typedef $$BookChaptersTableUpdateCompanionBuilder =
    BookChaptersCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> title,
      Value<int> orderIndex,
      Value<int> startOffset,
      Value<String> content,
      Value<int> rowid,
    });

class $$BookChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$BookChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookChaptersTable,
          BookChapter,
          $$BookChaptersTableFilterComposer,
          $$BookChaptersTableOrderingComposer,
          $$BookChaptersTableAnnotationComposer,
          $$BookChaptersTableCreateCompanionBuilder,
          $$BookChaptersTableUpdateCompanionBuilder,
          (
            BookChapter,
            BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>,
          ),
          BookChapter,
          PrefetchHooks Function()
        > {
  $$BookChaptersTableTableManager(_$AppDatabase db, $BookChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion(
                id: id,
                bookId: bookId,
                title: title,
                orderIndex: orderIndex,
                startOffset: startOffset,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String title,
                required int orderIndex,
                Value<int> startOffset = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                title: title,
                orderIndex: orderIndex,
                startOffset: startOffset,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookChaptersTable, BookChapter>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BookChaptersTable,
                    BookChapter
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookChaptersTable,
      BookChapter,
      $$BookChaptersTableFilterComposer,
      $$BookChaptersTableOrderingComposer,
      $$BookChaptersTableAnnotationComposer,
      $$BookChaptersTableCreateCompanionBuilder,
      $$BookChaptersTableUpdateCompanionBuilder,
      (
        BookChapter,
        BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>,
      ),
      BookChapter,
      PrefetchHooks Function()
    >;
typedef $$SourceMaterialsTableCreateCompanionBuilder =
    SourceMaterialsCompanion Function({
      required String id,
      required String title,
      Value<String?> url,
      Value<String?> rawText,
      Value<String?> extractedText,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$SourceMaterialsTableUpdateCompanionBuilder =
    SourceMaterialsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> url,
      Value<String?> rawText,
      Value<String?> extractedText,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$SourceMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceMaterialsTable> {
  $$SourceMaterialsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourceMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceMaterialsTable> {
  $$SourceMaterialsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceMaterialsTable> {
  $$SourceMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SourceMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceMaterialsTable,
          SourceMaterial,
          $$SourceMaterialsTableFilterComposer,
          $$SourceMaterialsTableOrderingComposer,
          $$SourceMaterialsTableAnnotationComposer,
          $$SourceMaterialsTableCreateCompanionBuilder,
          $$SourceMaterialsTableUpdateCompanionBuilder,
          (
            SourceMaterial,
            BaseReferences<
              _$AppDatabase,
              $SourceMaterialsTable,
              SourceMaterial
            >,
          ),
          SourceMaterial,
          PrefetchHooks Function()
        > {
  $$SourceMaterialsTableTableManager(
    _$AppDatabase db,
    $SourceMaterialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceMaterialsCompanion(
                id: id,
                title: title,
                url: url,
                rawText: rawText,
                extractedText: extractedText,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> url = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceMaterialsCompanion.insert(
                id: id,
                title: title,
                url: url,
                rawText: rawText,
                extractedText: extractedText,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceMaterialsTable, SourceMaterial>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SourceMaterialsTable,
                    SourceMaterial
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourceMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceMaterialsTable,
      SourceMaterial,
      $$SourceMaterialsTableFilterComposer,
      $$SourceMaterialsTableOrderingComposer,
      $$SourceMaterialsTableAnnotationComposer,
      $$SourceMaterialsTableCreateCompanionBuilder,
      $$SourceMaterialsTableUpdateCompanionBuilder,
      (
        SourceMaterial,
        BaseReferences<_$AppDatabase, $SourceMaterialsTable, SourceMaterial>,
      ),
      SourceMaterial,
      PrefetchHooks Function()
    >;
typedef $$EpisodesTableCreateCompanionBuilder =
    EpisodesCompanion Function({
      required String id,
      required String title,
      required String type,
      Value<String?> script,
      Value<String?> audioPath,
      Value<int?> durationMs,
      Value<String?> sourceId,
      Value<bool> isFavorite,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$EpisodesTableUpdateCompanionBuilder =
    EpisodesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<String?> script,
      Value<String?> audioPath,
      Value<int?> durationMs,
      Value<String?> sourceId,
      Value<bool> isFavorite,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get script =>
      $composableBuilder(column: $table.script, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, BaseReferences<_$AppDatabase, $EpisodesTable, Episode>),
          Episode,
          PrefetchHooks Function()
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> script = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                title: title,
                type: type,
                script: script,
                audioPath: audioPath,
                durationMs: durationMs,
                sourceId: sourceId,
                isFavorite: isFavorite,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String type,
                Value<String?> script = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                title: title,
                type: type,
                script: script,
                audioPath: audioPath,
                durationMs: durationMs,
                sourceId: sourceId,
                isFavorite: isFavorite,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  BaseReferences<_$AppDatabase, $EpisodesTable, Episode>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, BaseReferences<_$AppDatabase, $EpisodesTable, Episode>),
      Episode,
      PrefetchHooks Function()
    >;
typedef $$ListenHistoryRowsTableCreateCompanionBuilder =
    ListenHistoryRowsCompanion Function({
      required String id,
      required String episodeId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> listenedMs,
      Value<int> rowid,
    });
typedef $$ListenHistoryRowsTableUpdateCompanionBuilder =
    ListenHistoryRowsCompanion Function({
      Value<String> id,
      Value<String> episodeId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> listenedMs,
      Value<int> rowid,
    });

class $$ListenHistoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ListenHistoryRowsTable> {
  $$ListenHistoryRowsTableFilterComposer({
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

  ColumnFilters<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListenHistoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListenHistoryRowsTable> {
  $$ListenHistoryRowsTableOrderingComposer({
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

  ColumnOrderings<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListenHistoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListenHistoryRowsTable> {
  $$ListenHistoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );
}

class $$ListenHistoryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListenHistoryRowsTable,
          ListenHistoryRow,
          $$ListenHistoryRowsTableFilterComposer,
          $$ListenHistoryRowsTableOrderingComposer,
          $$ListenHistoryRowsTableAnnotationComposer,
          $$ListenHistoryRowsTableCreateCompanionBuilder,
          $$ListenHistoryRowsTableUpdateCompanionBuilder,
          (
            ListenHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $ListenHistoryRowsTable,
              ListenHistoryRow
            >,
          ),
          ListenHistoryRow,
          PrefetchHooks Function()
        > {
  $$ListenHistoryRowsTableTableManager(
    _$AppDatabase db,
    $ListenHistoryRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListenHistoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListenHistoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListenHistoryRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> episodeId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListenHistoryRowsCompanion(
                id: id,
                episodeId: episodeId,
                startedAt: startedAt,
                endedAt: endedAt,
                listenedMs: listenedMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String episodeId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListenHistoryRowsCompanion.insert(
                id: id,
                episodeId: episodeId,
                startedAt: startedAt,
                endedAt: endedAt,
                listenedMs: listenedMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListenHistoryRowsTable, ListenHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ListenHistoryRowsTable,
                    ListenHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListenHistoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListenHistoryRowsTable,
      ListenHistoryRow,
      $$ListenHistoryRowsTableFilterComposer,
      $$ListenHistoryRowsTableOrderingComposer,
      $$ListenHistoryRowsTableAnnotationComposer,
      $$ListenHistoryRowsTableCreateCompanionBuilder,
      $$ListenHistoryRowsTableUpdateCompanionBuilder,
      (
        ListenHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $ListenHistoryRowsTable,
          ListenHistoryRow
        >,
      ),
      ListenHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsRowsTableTableManager get userSettingsRows =>
      $$UserSettingsRowsTableTableManager(_db, _db.userSettingsRows);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookChaptersTableTableManager get bookChapters =>
      $$BookChaptersTableTableManager(_db, _db.bookChapters);
  $$SourceMaterialsTableTableManager get sourceMaterials =>
      $$SourceMaterialsTableTableManager(_db, _db.sourceMaterials);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$ListenHistoryRowsTableTableManager get listenHistoryRows =>
      $$ListenHistoryRowsTableTableManager(_db, _db.listenHistoryRows);
}
