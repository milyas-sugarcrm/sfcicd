/*
 * Description: This class is for Account related functionalities
 * Author: Imran
 * Created Date: 27th July 2023
 * Name: AccountTrigger
 * Version:1.0.0 - Imran - 27th July 2023
 */
trigger AccountTrigger on Account(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  TriggerDispatcher.run(new AccountTriggerHanlderSample());
}
