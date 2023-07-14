import 'package:floor/floor.dart';
import 'package:juejin_chat_demo/models/message.dart';

@dao
abstract class MessageDao {
  @Query('SELECT * FROM Message')
  Future<List<Message>> findAllMessages();

  @Query('SELECT * FROM Message WHERE id = :id')
  Future<Message?> findMessageById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertMessage(Message message);

  @delete
  Future<void> deleteMessage(Message message);
}
