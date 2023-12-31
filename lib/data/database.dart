import 'dart:async';

import 'package:floor/floor.dart';
import 'package:juejin_chat_demo/data/dao/session_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/message.dart';
import '../models/session.dart';
import 'converter/datetime_converter.dart';
import 'dao/message_dao.dart';

part 'database.g.dart';

@Database(version: 2, entities: [Message, Session])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  MessageDao get messageDao;
  SessionDao get sessionDao;
}
