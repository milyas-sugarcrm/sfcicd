@isTest
public class PFAEventTriggerHandlerTest {
  @isTest
  static void testBeforeInsert() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> eventList = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled',
      Regions__c = '3'
    );
    eventList.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled',
      Regions__c = '2'
    );

    eventList.add(event2);

    PFA_Event__c event3 = new PFA_Event__c(
      Name = 'Event 3',
      Event_Status__c = '02. Canceled'
    );

    Test.startTest();
    handler.beforeInsert(eventList);
    insert event3;
    Test.stopTest();
  }

  @isTest
  static void testAfterInsert() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> eventList = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '01. Canceled'
    );
    eventList.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    eventList.add(event2);

    Map<Id, PFA_Event__c> newMap = new Map<Id, PFA_Event__c>();
    for (PFA_Event__c event : eventList) {
      newMap.put(event.Id, event);
    }

    Test.startTest();
    handler.afterInsert(eventList, newMap);
    Test.stopTest();
  }

  @isTest
  static void testBeforeUpdate() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> newEvents = new List<PFA_Event__c>();
    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    newEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled',
      Regions__c = '2'
    );
    newEvents.add(event2);

    Map<Id, PFA_Event__c> oldEventsMap = new Map<Id, PFA_Event__c>();
    PFA_Event__c event3 = new PFA_Event__c(
      Name = 'Event 3',
      Event_Status__c = '02. Canceled'
    );
    oldEventsMap.put(event3.Id, event3);

    PFA_Event__c event4 = new PFA_Event__c(
      Name = 'Event 4',
      Event_Status__c = '02. Canceled',
      Regions__c = '3'
    );
    oldEventsMap.put(event4.Id, event4);

    Test.startTest();
    handler.beforeUpdate(
      newEvents,
      new Map<Id, PFA_Event__c>(),
      new List<PFA_Event__c>(),
      oldEventsMap
    );
    Test.stopTest();
  }

  @isTest
  static void testAfterUpdate() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> newEvents = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    newEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    newEvents.add(event2);

    Map<Id, PFA_Event__c> oldEventsMap = new Map<Id, PFA_Event__c>();
    PFA_Event__c oldEvent1 = new PFA_Event__c(
      Id = event1.Id,
      Name = 'Event 1 Old',
      Event_Status__c = '01. Pending'
    );
    oldEventsMap.put(oldEvent1.Id, oldEvent1);

    PFA_Event__c oldEvent2 = new PFA_Event__c(
      Id = event2.Id,
      Name = 'Event 2 Old',
      Event_Status__c = '01. Pending'
    );
    oldEventsMap.put(oldEvent2.Id, oldEvent2);

    Test.startTest();
    handler.afterUpdate(
      newEvents,
      new Map<Id, PFA_Event__c>(),
      new List<PFA_Event__c>(),
      oldEventsMap
    );
    Test.stopTest();
  }

  @isTest
  static void testBeforeDelete() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> oldEvents = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    oldEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    oldEvents.add(event2);

    Test.startTest();
    handler.beforeDelete(oldEvents, new Map<Id, SObject>());
    Test.stopTest();
  }

  @isTest
  static void testAfterDelete() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> oldEvents = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    oldEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    oldEvents.add(event2);

    Test.startTest();
    handler.afterDelete(oldEvents, new Map<Id, SObject>());
    Test.stopTest();
  }

  @isTest
  static void testAfterUnDelete() {
    PFAEventTriggerHandler handler = new PFAEventTriggerHandler();
    List<PFA_Event__c> undeleteEvents = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    undeleteEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    undeleteEvents.add(event2);

    Test.startTest();
    handler.afterUnDelete(undeleteEvents, new Map<Id, SObject>());
    Test.stopTest();
  }

  @isTest
  static void testCancelStatusHandling() {
    List<PFA_Event__c> newEvents = new List<PFA_Event__c>();

    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );
    newEvents.add(event1);

    PFA_Event__c event2 = new PFA_Event__c(
      Name = 'Event 2',
      Event_Status__c = '02. Canceled'
    );
    newEvents.add(event2);

    Map<Id, PFA_Event__c> oldEventsMap = new Map<Id, PFA_Event__c>();
    PFA_Event__c oldEvent1 = new PFA_Event__c(
      Id = event1.Id,
      Name = 'Event 1 Old',
      Event_Status__c = '01. Pending'
    );
    oldEventsMap.put(oldEvent1.Id, oldEvent1);

    PFA_Event__c oldEvent2 = new PFA_Event__c(
      Id = event2.Id,
      Name = 'Event 2 Old',
      Event_Status__c = '01. Pending'
    );
    oldEventsMap.put(oldEvent2.Id, oldEvent2);

    Test.startTest();
    PFAEventTriggerService.StatusHandling(newEvents, oldEventsMap);
    Test.stopTest();
  }

  @isTest
  static void testDMLEvent() {
    PFA_Event__c event1 = new PFA_Event__c(
      Name = 'Event 1',
      Event_Status__c = '02. Canceled'
    );

    Test.startTest();
    insert event1;
    event1.Name = 'Event change';
    update event1;
    delete event1;
    Test.stopTest();
  }
}
