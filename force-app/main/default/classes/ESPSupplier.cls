public class ESPSupplier {
  public class Selections {
  }

  public List<Results> Results;
  public Selections Selections;
  public Selections Dimensions;
  public Links Links;
  public String Query;
  public Integer Page;
  public Integer ResultsPerPage;
  public Integer ResultsTotal;
  public Double CompletedIn;

  public class Address {
    public String Street1;
    public String City;
    public String State;
    public String Zip;
    public String Country;
  }

  public class Results {
    public Integer Id;
    public String Name;
    public String AsiNumber;
    public Address Address;
    public Phone Phone;
    public String Fax;
    public String Email;
    public List<String> Websites;
    public Integer Products;
    public Rating Rating;
  }

  public class Phone {
    public String Work;
    public Integer index;
  }

  public class Rating {
    public Integer Rating;
    public Integer Companies;
    public Integer Transactions;
  }

  public class Links {
    public String Self;
  }

  public static ESPSupplier parse(String json) {
    return (ESPSupplier) System.JSON.deserialize(json, ESPSupplier.class);
  }
}
