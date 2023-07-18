import 'package:flutter/foundation.dart';
import 'package:juejin_chat_demo/data/database.dart';
import 'package:juejin_chat_demo/services/chatgpt_service.dart';
import 'package:juejin_chat_demo/services/local_store.dart';
import 'package:juejin_chat_demo/services/record.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final chatgpt = ChatGPTService();

final logger = Logger(level: kDebugMode ? Level.verbose : Level.info);

const uuid = Uuid();

late AppDatabase db;

final recorder = RecordService();

final localStorage = LocalStoreService();
