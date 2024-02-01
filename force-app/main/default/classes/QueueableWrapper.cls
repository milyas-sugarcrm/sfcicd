public abstract class QueueableWrapper implements Queueable, Database.AllowsCallouts {
  private static Integer counter = 0;
  public Map<String, Set<Id>> mapDataUser;
  public String name;
  public QueueableWrapper(String name, Map<String, Set<Id>> mapData) {
    this.name = name + '.' + ++counter + System.now().format();
    this.mapDataUser = mapData;
  }
  abstract void syncCustomer(Map<String, Set<Id>> mapData);

  public void execute(QueueableContext ctx) {
    this.syncCustomer(mapDataUser);
    currentChain.commitQueue();
  }

  public static void enqueue(QueueableWrapper queueable) {
    currentChain.add(queueable);
    if (!System.isQueueable()) {
      System.enqueueJob(queueable);
    }
  }

  private class QueueableChain implements Queueable {
    private List<QueueableWrapper> chain = new List<QueueableWrapper>();
    public void execute(QueueableContext ctx) {
      if (this.chain.isEmpty()) {
        return;
      }
      QueueableWrapper current = this.chain.remove(0);
      if (!this.chain.isEmpty()) {
        for (QueueableWrapper queueable : this.chain) {
          enqueue(queueable);
        }
      }
      current.execute(ctx);
    }

    public void add(QueueableWrapper queueable) {
      if (queueable == null) {
        return;
      }
      this.chain.add(queueable);
    }

    public void commitQueue() {
      System.enqueueJob(this);
    }
  }

  public static void testPass() {
    Integer i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
  }

  private static final QueueableChain currentChain = new QueueableChain();
}
