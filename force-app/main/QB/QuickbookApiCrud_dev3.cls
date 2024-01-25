public class QuickbookApiCrud implements Queueable, Database.AllowsCallouts {
  public String key;
  public Set<Id> mapQBInstanceVendorAccountId;
  //Schema
  public class PrimaryPhone {
    public String FreeFormNumber;
  }
  public class AlternatePhone {
    public String FreeFormNumber;
  }
  public class Mobile {
    public String FreeFormNumber;
  }
  public class Fax {
    public String FreeFormNumber;
  }
  public class WebAddr {
    public String URI;
  }
  public class PrimaryEmailAddr {
    public String Address;
  }
  public class ParentRef {
    public String value;
    public String name;
  }
  public class ClassRef {
    public String value;
    public String name;
  }
  public class CurrencyRef {
    public String name;
    public String value;
  }
  public class DefaultTaxCodeRef {
    public String value;
  }
  public class PaymentMethodRef {
    public String value;
  }
  public class TermRef {
    public string value;
  }
  public class LinkedTxn {
    public String TxnId;
    public String TxnType;
  }
  public class TxnTaxDetail {
    public Decimal TotalTax;
  }
  public class ShipFromAddr {
    public String Id;
    public String Line1;
    public String Line2;
  }
  public class SalesTermRef {
    public String value;
  }
  public class TaxExemptionRef {
    public String name;
  }
  public class BillEmail {
    public String Address { get; set; }
  }
  // new added fields
  public class AcceptedDate {
    public Date acceptedDate { get; set; }
  }
  public class DueDate {
    public Date dueDate { get; set; }
  }
  //
  public class ItemRef {
    public String name;
    public String value;
  }
  public class CustomerRef {
    public String name;
    public String value;
  }
  public class ShipMethodRef {
    public String value;
    public String name;
  }
  public class BillAddr {
    public String Line1;
    public String City;
    public String Country;
    public String PostalCode;
    public String CountrySubDivisionCode;
  }
  public class ShipAddr {
    public String Line1;
    public String City;
    public String Country;
    public String PostalCode;
    public String CountrySubDivisionCode;
  }
  public class TaxCode {
    public string Name;
    public string Description;
    public Boolean Active;
    public Boolean Hidden;
    public Boolean sparse;
    public string Id;
    public string SyncToken;
    public Boolean Taxable;
  }
  public class PaymentMethod {
    public string Name;
    public string Type;
    public Boolean Active;
    public Boolean sparse;
    public string Id;
    public string SyncToken;
  }
  public class Term {
    public string Name;
    public string Type;
    public Boolean Active;
    public Decimal DueDays;
    public Decimal DiscountDays;
    public Boolean sparse;
    public string Id;
    public string SyncToken;
  }
  public class Classr {
    public string Name;
    public string FullyQualifiedName;
    public Boolean Active;
    public Boolean SubClass;
    public Boolean sparse;
    public string Id;
    public string SyncToken;
  }
  public class CustomField {
    public String DefinitionId;
    public String Name;
    public String StringValue;
    public String Type;

    public CustomField(String defID, String nam, String value) {
      DefinitionId = defID;
      Name = nam;
      StringValue = value;
      Type = 'StringType';
    }
  }
  public class Line {
    public Decimal Amount;
    public String Description;
    public String DetailType;
    public List<LinkedTxn> LinkedTxn;
    public SalesItemLineDetail SalesItemLineDetail;
    public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
  }
  public class SalesItemLineDetail {
    public String Qty;
    public ItemRef ItemRef;
    public String ServiceDate;
    public String UnitPrice;
  }

  //Objects
  public class Estimate {
    public String Id;
    public String SyncToken;
    public AcceptedDate AcceptedDate;
    public DueDate DueDate;
    public BillEmail BillEmail;
    public ShipAddr ShipAddr;
    public BillAddr BillAddr;
    public ClassRef ClassRef;
    public String ExpirationDate;
    public List<Line> Line;
    public CustomerRef CustomerRef;
    public List<CustomField> CustomField;
  }
  public class Payment {
    public String Id;
    public Decimal TotalAmt;
    public CustomerRef CustomerRef;
    public String SyncToken;
    public List<Line> Line;
    public CurrencyRef CurrencyRef;
    public LinkedTxn LinkedTxn;
  }
  public class VendorRef {
    public String name;
    public String value;
  }
  public class AccountBasedExpenseLineDetail {
    public TaxCodeRef TaxCodeRef;
    public CustomerRef CustomerRef;
    public AccountRef AccountRef;
    public String BillableStatus;
  }
  public class AccountRef {
    public String name;
    public String value;
  }
  public class TaxCodeRef {
    public String value;
  }
  public class Bill {
    public String Id;
    public String SyncToken;
    public List<Line> Line;
    public VendorRef VendorRef;
    public String DueDate;
  }
  public class Invoice {
    public Decimal Deposit;
    public String SyncToken;
    public String Id;
    public List<CustomField> CustomField;
    public String DocNumber;
    public String TxnDate;
    public CurrencyRef CurrencyRef;
    public List<LinkedTxn> LinkedTxn;
    public List<Line> Line;
    public TxnTaxDetail TxnTaxDetail;
    public CustomerRef CustomerRef;
    public BillAddr BillAddr;
    public ShipAddr ShipAddr;
    public ClassRef ClassRef;
    public Boolean FreeFormAddress;
    public ShipFromAddr ShipFromAddr;
    public ShipMethodRef ShipMethodRef;
    public SalesTermRef SalesTermRef;
    public String ShipDate;
    public String DueDate;
    public Decimal TotalAmt;
    public boolean ApplyTaxAfterDiscount;
    public String PrintStatus;
    public String EmailStatus;
    public BillEmail BillEmail;
    public Decimal Balance;
    public TaxExemptionRef TaxExemptionRef;
  }

  public virtual class ContactDetails {
    public String Id;
    public String domain;
    public Boolean sparse;
    public String SyncToken;
    public Boolean Active;

    public String Title;
    public String GivenName;
    public String MiddleName;
    public String FamilyName;
    public String Suffix;
    public String CompanyName;
    public String DisplayName;

    public PrimaryPhone PrimaryPhone;
    public AlternatePhone AlternatePhone;
    public Mobile Mobile;
    public Fax Fax;
    public PrimaryEmailAddr PrimaryEmailAddr;
    public WebAddr WebAddr;

    public BillAddr BillAddr;
    public ShipAddr ShipAddr;
    public String Notes;
    public Decimal Balance;

    public String PrintOnCheckName;
    public CurrencyRef CurrencyRef;
    public SalesTermRef SalesTermRef;
    public List<CustomField> CustomField;
  }
  public class Customer extends ContactDetails {
    public String FullyQualifiedName;
    public Boolean IsProject;
    public ParentRef ParentRef;
    public Boolean Job;
    public boolean Taxable;
    public String ResaleNum;
    public DefaultTaxCodeRef DefaultTaxCodeRef;
    public PaymentMethodRef PaymentMethodRef;
  }
  public class Vendor extends ContactDetails {
    public TermRef TermRef;
    public Decimal BillRate;
    public String AcctNum;
    public Boolean Vendor1099;
    public String TaxIdentifier;
  }

  //Response Structure
  public virtual class QueryResponse {
    public Integer startPosition;
    public Integer maxResults;
    public Integer totalCount;
  }

  public class InvoiceQueryResponse extends QueryResponse {
    public List<Invoice> Invoice;
  }
  public class InvoiceResponse {
    public InvoiceQueryResponse QueryResponse;
  }

  public class TaxCodeQueryResponse extends QueryResponse {
    public List<TaxCode> TaxCode;
  }
  public class TaxCodeResponse {
    public TaxCodeQueryResponse QueryResponse;
  }

  public class CustomerQueryResponse extends QueryResponse {
    public List<Customer> Customers;
  }
  public class CustomerResponse {
    public CustomerQueryResponse QueryResponse;
  }

  public class PaymentQueryResponse extends QueryResponse {
    public List<PaymentMethod> PaymentMethod;
  }
  public class PaymentMethodResponse {
    public PaymentQueryResponse QueryResponse;
  }

  public class TermResponse extends QueryResponse {
    public List<Term> Term;
  }
  public class SalesTermResponse {
    public TermResponse QueryResponse;
  }

  public class ClassResponse extends QueryResponse {
    public List<Classr> Clas;
  }
  public class ClassValueResponse {
    public ClassResponse QueryResponse;
  }

  public class VendorAccountResponse {
    public Boolean Sparse { get; set; }
    public String Id { get; set; }
    public String DisplayName { get; set; }
  }
  public class CustomerAccountResponse {
    public Boolean Sparse { get; set; }
    public String Id { get; set; }
  }
  public class QueryResponseAccount {
    public List<VendorAccountResponse> vendor { get; set; }
    public List<CustomerAccountResponse> customer { get; set; }
    public Integer startPosition;
    public Integer maxResults;
  }
  public class AccountResponse {
    public QueryResponseAccount QueryResponse { get; set; }
    public DateTime timee;
  }
  public class DuplicateAccountResponse {
    public Boolean isDuplicateEntityExist { get; set; }
    public QBO_Details__c qboDetails { get; set; }
  }

  public QuickbookApiCrud(Set<Id> mapQBInstanceVendorAccountId, String key) {
    System.debug('In the constructor');
    this.key = key;
    this.mapQBInstanceVendorAccountId = mapQBInstanceVendorAccountId;
  }
  //Api Communication Methods
  //@future(callout=true)
  public static void makePayment(
    Set<Id> orderIds,
    Map<Id, String> OrderAccountMap,
    Map<Id, String> orderToQbIdMap
  ) {
    List<Order> orders = [
      SELECT id, Name, AccountId, QBId__c, Invoice_Total__c
      FROM Order
      WHERE id IN :orderIds
    ];
    Set<Id> accountIds = new Set<Id>();
    for (Order order : orders) {
      accountIds.add(order.AccountId);
    }
    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Account__r.Name,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c = :accountIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :OrderAccountMap.Values()
    ];

    Map<Id, QBO_Details__c> orderQBOAccountMap = new Map<Id, QBO_Details__c>();
    for (Order order : orders) {
      for (QBO_Details__c qboAccount : qboDetailsList) {
        if (qboAccount.Account__c == order.AccountId) {
          orderQBOAccountMap.put(order.id, qboAccount);
        }
      }
    }
    List<QB_Credentials__c> QBOCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c IN :OrderAccountMap.Values()
    ];
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c IN :OrderAccountMap.Values()
    ];
    Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
    for (QB_Credentials__c QBOCred : QBOCredentials) {
      for (
        Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
      ) {
        if (
          accConfig.Quickbooks_Account_Tittle__c ==
          QBOCred.Synced_Account_Title__c
        ) {
          QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
            QBOCred,
            accConfig
          );
          for (Id key : OrderAccountMap.keySet()) {
            if (OrderAccountMap.get(key) == QBOCred.Synced_Account_Title__c) {
              qboConfigs.put(key, qboConfig);
              System.debug('qboConfigs: ' + qboConfigs.get(key));
            }
          }
        }
      }
    }
    for (Order order : orders) {
      Payment payment = new Payment();
      payment.TotalAmt = order.Invoice_Total__c;
      payment.CustomerRef = new CustomerRef();
      payment.CustomerRef.value = (String) orderQBOAccountMap.get(order.id)
        .QB_Id__c;
      payment.CustomerRef.name = orderQBOAccountMap.get(order.id)
        .Account__r.Name;
      payment.Line = new List<Line>();
      Line ln = new Line();
      ln.Amount = order.Invoice_Total__c;
      ln.LinkedTxn = new List<LinkedTxn>();
      Linkedtxn LTxn = new Linkedtxn();
      LTxn.TxnId = orderToQbIdMap.get(order.Id);
      LTxn.TxnType = 'Invoice';
      ln.LinkedTxn.add(LTxn);
      payment.Line.add(ln);
      String json = JSON.serialize(payment, true);
      /*
            String json = '{'
                +'"TotalAmt": 65.0,'
                +'"Line": ['
                +'{'
                +'"Amount": 55.0,'
                +'"LinkedTxn": ['
                +'{'
                +'"TxnId": "'+ payment.LinkedTxn.TxnId+'",' 
                +'"TxnType": "Invoice"'
                +'}'
                +']'
                +'}'
                +'],'
                +'"CustomerRef": {'
                +'"name": "'+payment.CustomerRef.name+'",'
                +'"value": "'+payment.CustomerRef.value+'"'
                +'}'
                +'}';
            */
      System.debug(json);
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      request.setHeader(
        'Authorization',
        'Bearer ' + qboConfigs.get(order.id).accessToken
      );
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(json);
      request.setMethod('POST');
      if (Test.isRunningTest()) {
        request.setEndPoint('http://test.com/test/sendInvoicce');
      } else {
        request.setEndPoint(
          qboConfigs.get(order.id).qbApiEndPoint +
            '/v3/company/' +
            qboConfigs.get(order.id).realMId +
            '/payment?minorversion=55'
        );
      }
      System.debug('response.getStatusCode(): ' + response.getStatusCode());
      response = http.send(request);
      System.debug(response);
      if (response.getStatusCode() == 200) {
        System.debug('PAYMENT CREATED');
      } else if (response.getStatusCode() == 401) {
        authenticationErrorEmail(response, '', 'Create Payment', '');
      } else {
        serverErrorEmails(
          response,
          order.Name,
          'Order',
          OrderAccountMap.get(order.id),
          'Class QuickbookApiCrud , createInvoice',
          'Invoice',
          order.Id
        );
      }
    }
  }
  public static String getAccountJson(
    Account acc,
    String objectType,
    String qbId,
    String syncToken,
    String accountTitle
  ) {
    ContactDetails c;
    Map<Id, Tax_Code__c> taxcodes = new Map<Id, Tax_Code__c>(
      [
        SELECT Id, Id__c
        FROM Tax_Code__c
        WHERE QBO_Account__c = :accountTitle
      ]
    );
    Map<Id, Payment_Method__c> methods = new Map<Id, Payment_Method__c>(
      [
        SELECT Id, Id__c
        FROM Payment_Method__c
        WHERE QBO_Account__c = :accountTitle
      ]
    );
    Map<Id, Sales_Term__c> terms = new Map<Id, Sales_Term__c>(
      [
        SELECT Id, Id__c
        FROM Sales_Term__c
        WHERE QBO_Account__c = :accountTitle
      ]
    );

    Map<String, Map<Id, Object>> references = new Map<String, Map<Id, Object>>();
    references.put('TaxCode', taxcodes);
    references.put('PaymentMethod', methods);
    references.put('Terms', terms);

    if (objectType.equals('Customer')) {
      c = new Customer();
    } else if (objectType.equals('Vendor')) {
      c = new Vendor();
    }

    if (qbId != null) {
      c.Id = qbId;
      c.SyncToken = syncToken;
      c.sparse = true;
    }

    if (objectType.equals('Vendor')) {
      c.CustomField = new List<CustomField>();
      c.CustomField.add(new CustomField('1', 'ASI Number', acc.ASI_Number__c));
    }

    if (
      acc.Billing_Contact__r.FirstName != null &&
      acc.Billing_Contact__r.LastName != null
    ) {
      c.GivenName = acc.Billing_Contact__r.FirstName;
      c.FamilyName = acc.Billing_Contact__r.LastName;
    } else {
      c.GivenName = acc.Name.subStringBefore(' ');
      String LastName = '';
      if (
        acc.Name.subStringAfter(' ') == null ||
        acc.Name.subStringAfter(' ') == ''
      ) {
        LastName = acc.Name.subString(0, 1).toUpperCase();
      } else {
        LastName = acc.Name.subStringAfter(' ');
      }
      c.FamilyName = LastName;
    }
    c.CompanyName = acc.Name;
    c.DisplayName = acc.Name;
    c.PrintOnCheckName = acc.Name;

    c.PrimaryPhone = new PrimaryPhone();
    if (acc.Billing_Contact__r.Id != null) {
      c.PrimaryPhone.FreeFormNumber = acc.Billing_Contact__r.Phone;
    } else {
      c.PrimaryPhone.FreeFormNumber = acc.Phone;
    }

    c.Mobile = new Mobile();
    c.Mobile.FreeFormNumber = acc.Billing_Contact__r.MobilePhone;

    c.Fax = new Fax();
    c.Fax.FreeFormNumber = acc.Fax;

    c.PrimaryEmailAddr = new PrimaryEmailAddr();
    c.PrimaryEmailAddr.Address = acc.Billing_Email__c;

    c.WebAddr = new WebAddr();
    c.WebAddr.URI = acc.Website;

    BillAddr bAddr = new BillAddr();
    bAddr.Line1 = (String) (acc.get('BillingStreet') == null
      ? ''
      : acc.get('BillingStreet'));
    bAddr.City = (String) (acc.get('BillingCity') == null
      ? ''
      : acc.get('BillingCity'));
    bAddr.Country = (String) (acc.get('BillingCountry') == null
      ? ''
      : acc.get('BillingCountry'));
    bAddr.PostalCode = (String) (acc.get('BillingPostalCode') == null
      ? ''
      : acc.get('BillingPostalCode'));
    bAddr.CountrySubDivisionCode = (String) (acc.get('BillingState') == null
      ? ''
      : acc.get('BillingState'));

    c.BillAddr = bAddr;
    ShipAddr ShipAddr = new ShipAddr();
    ShipAddr.Line1 = (String) (acc.get('ShippingStreet') == null
      ? ''
      : acc.get('ShippingStreet'));
    ShipAddr.City = (String) (acc.get('ShippingCity') == null
      ? ''
      : acc.get('ShippingCity'));
    ShipAddr.Country = (String) (acc.get('ShippingCountry') == null
      ? ''
      : acc.get('ShippingCountry'));
    ShipAddr.PostalCode = (String) (acc.get('ShippingPostalCode') == null
      ? ''
      : acc.get('ShippingPostalCode'));
    ShipAddr.CountrySubDivisionCode = (String) (acc.get('ShippingState') == null
      ? ''
      : acc.get('ShippingState'));
    c.ShipAddr = ShipAddr;

    c.Notes = acc.Notes__c;
    if (objectType.equals('Customer')) {
      populateCustomerFields((Customer) c, acc, references);
    } else if (objectType.equals('Vendor')) {
      populateVendorFields((Vendor) c, acc, references);
    }

    return JSON.serialize(c, true);
  }
  public static void populateCustomerFields(
    Customer c,
    Account acc,
    Map<String, Map<Id, Object>> references
  ) {
    c.FullyQualifiedName = acc.Name;
    c.ResaleNum = acc.Tax_Exemption_Code__c;
    c.Taxable = acc.Taxable__c;
    if (acc.Tax_Code__c != null) {
      c.DefaultTaxCodeRef = new DefaultTaxCodeRef();
      if (references.get('TaxCode').containsKey(acc.Tax_Code__c)) {
        c.DefaultTaxCodeRef.value = ((Tax_Code__c) references.get('TaxCode')
            .get(acc.Tax_Code__c))
          .Id__c;
      }
    }
    if (acc.Payment_Method__c != null) {
      c.PaymentMethodRef = new PaymentMethodRef();
      if (references.get('TaxCode').ContainsKey(acc.Tax_Code__c)) {
        c.PaymentMethodRef.value = ((Payment_Method__c) references.get(
              'PaymentMethod'
            )
            .get(acc.Payment_Method__c))
          .Id__c;
      }
    }
    if (acc.Sales_Terms__c != null) {
      c.SalesTermRef = new SalesTermRef();
      system.debug('terms---->>>');
      system.debug(references.get('Terms'));
      if (references.get('Terms').ContainsKey(acc.Sales_Terms__c)) {
        c.SalesTermRef.value = ((Sales_Term__c) references.get('Terms')
            .get(acc.Sales_Terms__c))
          .Id__c;
      }
    }
  }
  public static void populateVendorFields(
    Vendor v,
    Account acc,
    Map<String, Map<Id, Object>> references
  ) {
    v.AcctNum = acc.Team_Phun_Account_Number__c;
    if (acc.Sales_Terms__c != null) {
      v.TermRef = new TermRef();
      v.TermRef.value = ((Sales_Term__c) references.get('Terms')
          .get(acc.Sales_Terms__c))
        .Id__c;
    }
  }

  public static Map<String, String> getSyncTokenMap(
    Set<String> estimateIds,
    String accountTitle
  ) {
    //TODO: Add the account Name
    String recordDetails = 'EstimatesIds ' + estimateIds.toString();
    String functionName = 'Sync Token Map (getSyncTokenMap)';
    Boolean isSyncTokenReceived = false;
    Map<String, String> qbSyncTokenMap = new Map<String, String>();

    if (estimateIds != null && estimateIds.size() > 0) {
      List<QB_Credentials__c> qbcList = [
        SELECT
          Id,
          Access_token__c,
          Refresh_token__c,
          realmid__c,
          Synced_Account_Title__c
        FROM QB_Credentials__c
        WHERE Synced_Account_Title__c = :accountTitle
        ORDER BY LastModifiedDate DESC
      ];
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
        SELECT
          Id,
          QBO_Custom_Field_1__c,
          QBO_Custom_Field_1_Id__c,
          QB_Access_token_End_Point__c,
          QB_API_End_Point__c,
          QB_Authorization_End_Point__c,
          QB_Authorization_Scope__c,
          QB_Client_Id__c,
          QB_Client_Secret__c,
          QB_ID__c,
          QB_Redirect_URI__c,
          QB_Timezone__c,
          Quickbooks_Account_Tittle__c,
          Service_Id_Breakdown__c,
          Service_Id_Brokerage__c,
          Service_Id_Duty__c,
          Service_Id_FixedCharges__c,
          Service_Id_InboundFreight__c,
          Service_Id_RunCharges__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :accountTitle
      ];

      if (qbcList.size() > 0) {
        String query = 'select id, syncToken from estimate where id in(';
        Integer count = 1;
        for (String estimateId : estimateIds) {
          query = query + '\'' + estimateId + '\'';
          if (count < estimateIds.size()) {
            query = query + ',';
          }
          count = count + 1;
        }
        query = query + ')';

        query = EncodingUtil.urlEncode(query, 'UTF-8');
        system.debug(query);

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('GET');
        request.setHeader(
          'Authorization',
          'Bearer ' + qbcList[0].Access_token__c
        );
        request.setHeader('Accept', 'application/json');
        if (Test.isRunningTest()) {
          request.setEndPoint('http://test.com/test/getSyncToken');
        } else {
          request.setEndPoint(
            accountConfiguration[0].QB_API_End_Point__c +
              '/v3/company/' +
              qbcList[0].realmid__c +
              '/query?query=' +
              query
          ); //Realmid
        }
        response = http.send(request);
        system.debug('response.send()');
        if (response.getStatusCode() == 200) {
          isSyncTokenReceived = true;
        } else if (response.getStatusCode() == 401) {
          authenticationErrorEmail(
            response,
            recordDetails,
            functionName,
            accountTitle
          );
        } else {
          serverErrorEmails(
            response,
            '',
            'Estimate',
            accountTitle,
            'Class QuickbookApiCrud , getSyncTokenMap ',
            'Estimate',
            null
          );

          //     serverErrorEmails(response,opp.Name,'Opportunity',accountName,'Class QuickbookApiCrud , UpdateEstimate ','Estimate',opp.Id);
        }
        if (isSyncTokenReceived) {
          Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
            response.getBody()
          );
          List<Object> responseArray = (List<Object>) ((Map<String, Object>) results.get(
              'QueryResponse'
            ))
            .get('Estimate');
          if (responseArray != null) {
            for (Object res : responseArray) {
              Map<String, Object> token = (Map<String, Object>) res;
              qbSyncTokenMap.put(
                String.valueof(token.get('Id')),
                String.valueof(token.get('SyncToken'))
              );
            }
          }
        } else {
          System.debug('badRequest' + response.getBody());
        }
        return qbSyncTokenMap;
      }
    }
    return qbSyncTokenMap;
  }
  public static Map<String, String> getSyncTokenMapForOrders(
    Map<String, String> OrderIds,
    String objectType,
    List<QB_Credentials__c> QBOCredentials,
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration
  ) {
    String recordDetails = 'OrderIds ' + OrderIds.toString();
    String functionName = 'Sync Token Map (getSyncTokenMap)';
    Boolean isSyncTokenReceived = false;
    Map<String, String> qbSyncTokenMap = new Map<String, String>();

    if (OrderIds != null && OrderIds.size() > 0) {
      QB_Credentials__c QBOCredentialsForTP = new QB_Credentials__c();
      QB_Credentials__c QBOCredentialsForTPSypplyCo = new QB_Credentials__c();
      Quickbooks_Accounts_Configurations__c accountConfigurationForTP = new Quickbooks_Accounts_Configurations__c();
      Quickbooks_Accounts_Configurations__c accountConfigurationForTPSupplyCo = new Quickbooks_Accounts_Configurations__c();
      for (QB_Credentials__c QBOCredential : QBOCredentials) {
        if (
          QBOCredential.Synced_Account_Title__c == 'Team Phun' &&
          QBOCredential.Access_token__c != null &&
          QBOCredential.Refresh_token__c != null
        ) {
          QBOCredentialsForTP = QBOCredential;
        } else {
          QBOCredentialsForTPSypplyCo = QBOCredential;
        }
      }
      for (
        Quickbooks_Accounts_Configurations__c QBOConfigurations : accountConfiguration
      ) {
        if (QBOConfigurations.Quickbooks_Account_Tittle__c == 'Team Phun') {
          accountConfigurationForTP = QBOConfigurations;
        } else {
          accountConfigurationForTPSupplyCo = QBOConfigurations;
        }
      }
      List<String> OrdersForTeamPhun = new List<String>();
      List<String> OrdersForTPSupplyCo = new List<String>();
      for (String key : orderIds.keySet()) {
        if (orderIds.get(key) == 'Team Phun') {
          OrdersForTeamPhun.add(key);
        } else {
          OrdersForTPSupplyCo.add(key);
        }
      }
      ///// for TP
      if (OrdersForTeamPhun.size() > 0) {
        String query =
          'select id, syncToken from ' +
          objectType +
          ' where id in(';
        Integer count = 1;
        for (String key : OrdersForTeamPhun) {
          query = query + '\'' + key + '\'';
          if (count < orderIds.size()) {
            query = query + ',';
          }
          count = count + 1;
        }
        query = query + ')';
        system.debug(query);
        query = EncodingUtil.urlEncode(query, 'UTF-8');

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('GET');
        request.setHeader(
          'Authorization',
          'Bearer ' + QBOCredentialsForTP.Access_token__c
        );
        request.setHeader('Accept', 'application/json');
        if (Test.isRunningTest()) {
          request.setEndPoint('http://test.com/test/getSyncToken');
        } else {
          request.setEndPoint(
            accountConfigurationForTP.QB_API_End_Point__c +
              '/v3/company/' +
              QBOCredentialsForTP.realmid__c +
              '/query?query=' +
              query
          ); //Realmid
        }
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          isSyncTokenReceived = true;
        } else if (response.getStatusCode() == 401) {
          authenticationErrorEmail(
            response,
            recordDetails,
            functionName,
            'Team Phun'
          );
        } else {
          serverErrorEmails(
            response,
            '',
            objectType,
            'Team Phun',
            'Class QuickbookApiCrud , getSyncTokenMap ',
            objectType,
            null
          );
        }
        if (isSyncTokenReceived) {
          Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
            response.getBody()
          );
          List<Object> responseArray = (List<Object>) ((Map<String, Object>) results.get(
              'QueryResponse'
            ))
            .get(objectType);
          if (responseArray != null)
            for (Object res : responseArray) {
              Map<String, Object> token = (Map<String, Object>) res;
              qbSyncTokenMap.put(
                String.valueof(token.get('Id')),
                String.valueof(token.get('SyncToken'))
              );
            }
        } else {
          System.debug('badRequest' + response.getBody());
        }
      }
      //// for TP Supply CO
      if (OrdersForTPSupplyCo.size() > 0) {
        String query =
          'select id, syncToken from ' +
          objectType +
          ' where id in(';
        Integer count = 1;
        for (String key : OrdersForTPSupplyCo) {
          query = query + '\'' + key + '\'';
          if (count < orderIds.size()) {
            query = query + ',';
          }
          count = count + 1;
        }
        query = query + ')';

        query = EncodingUtil.urlEncode(query, 'UTF-8');
        system.debug(query);

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('GET');
        request.setHeader(
          'Authorization',
          'Bearer ' + QBOCredentialsForTPSypplyCo.Access_token__c
        );
        request.setHeader('Accept', 'application/json');
        if (Test.isRunningTest()) {
          request.setEndPoint('http://test.com/test/getSyncToken');
        } else {
          request.setEndPoint(
            accountConfigurationForTPSupplyCo.QB_API_End_Point__c +
              '/v3/company/' +
              QBOCredentialsForTPSypplyCo.realmid__c +
              '/query?query=' +
              query
          ); //Realmid
        }
        response = http.send(request);
        system.debug('response.send()');
        if (response.getStatusCode() == 200) {
          isSyncTokenReceived = true;
        } else if (response.getStatusCode() == 401) {
          authenticationErrorEmail(
            response,
            recordDetails,
            functionName,
            'TP SupplyCo'
          );
        } else {
          serverErrorEmails(
            response,
            '',
            objectType,
            'TP SupplyCo',
            'Class QuickbookApiCrud , getSyncTokenMap ',
            objectType,
            null
          );
        }
        if (isSyncTokenReceived) {
          Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
            response.getBody()
          );
          List<Object> responseArray = (List<Object>) ((Map<String, Object>) results.get(
              'QueryResponse'
            ))
            .get(objectType);
          if (responseArray != null) {
            for (Object res : responseArray) {
              Map<String, Object> token = (Map<String, Object>) res;
              qbSyncTokenMap.put(
                String.valueof(token.get('Id')),
                String.valueof(token.get('SyncToken'))
              );
            }
          }
        } else {
          System.debug('badRequest' + response.getBody());
        }
      }
    }
    return qbSyncTokenMap;
  }
  public static Map<Id, QBO_Details__c> getestimateQboRecordsMap(
    Set<Id> estimateIds,
    String accountName
  ) {
    Map<Id, QBO_Details__c> mapToReturn = new Map<Id, QBO_Details__c>();
    List<Estimate__c> estimatesList = [
      SELECT
        Id,
        Estimate_QB_Id__c,
        Order_Date__c,
        Estimate_Number__c,
        Currency__c,
        Terms__c,
        In_Hands_Date__c,
        Default_Margin__c,
        Default_Tax__c,
        Customer_PO__c,
        Opportunity__c,
        Introduction__c
      FROM Estimate__c
      WHERE Id = :estimateIds
    ];
    Set<Id> opportunityIds = new Set<Id>();
    for (Estimate__c est : estimatesList) {
      opportunityIds.add(est.Opportunity__c);
    }
    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Opportunity__c = :opportunityIds
        AND id_Type__c = :'Estimate'
        AND QBO_Account__c = :accountName
    ];

    for (Estimate__c est : estimatesList) {
      for (QBO_Details__c qboRecord : qboDetailsList) {
        if (
          (qboRecord.Opportunity__c == est.Opportunity__c) &&
          (qboRecord.Salesforce_Record_Id__c == est.Id)
        ) {
          mapToReturn.put(est.Id, qboRecord);
        }
      }
    }
    return mapToReturn;
  }

  @future(callout=true)
  public static void updateEstimate(
    Set<Id> oppIds,
    Set<Id> estimateIds,
    String accountName
  ) {
    String recordDetails =
      'Opportunities Records <br/>' +
      oppIds.toString() +
      '<br/><br/> EstimatesIds ' +
      estimateIds.toString();
    String functionName = 'Update Estimate (updateEstimate)';
    QuicbooksConfiguration quickbooksConfiguration = getQuicbooksConfiguration(
      accountName
    );
    Map<Id, QBO_Details__c> estimateQboRecordMap = getestimateQboRecordsMap(
      estimateIds,
      accountName
    );
    if (QuickbooksConfiguration != null) {
      Set<String> estimateIdsForSyncToken = new Set<String>();
      Map<Id, Estimate__c> estimateMap = new Map<Id, Estimate__c>(
        [
          SELECT
            Id,
            Selected_Quickbook_Instance__c,
            Estimate_QB_Id__c,
            Order_Date__c,
            Estimate_Number__c,
            Currency__c,
            Terms__c,
            In_Hands_Date__c,
            Default_Margin__c,
            Default_Tax__c,
            Customer_PO__c,
            Opportunity__c,
            Introduction__c
          FROM Estimate__c
          WHERE Id = :estimateIds
        ]
      );
      List<Estimate__c> estimatesList = [
        SELECT
          Id,
          OwnerId,
          Selected_Quickbook_Instance__c,
          Estimate_QB_Id__c,
          Order_Date__c,
          Estimate_Number__c,
          Currency__c,
          Terms__c,
          In_Hands_Date__c,
          Default_Margin__c,
          Default_Tax__c,
          Customer_PO__c,
          Opportunity__c,
          Introduction__c
        FROM Estimate__c
        WHERE Id = :estimateIds
      ];
      Map<Id, Estimate__c> opportunityEstimateMap = new Map<Id, Estimate__c>();
      if (estimateQboRecordMap != null && estimateQboRecordMap.size() > 0) {
        for (Estimate__c est : estimatesList) {
          if (estimateQboRecordMap.containsKey(est.Id)) {
            QBO_Details__c relatedQboRecord = estimateQboRecordMap.get(est.Id);
            estimateIdsForSyncToken.add(relatedQboRecord.QB_Id__c);
          }
          opportunityEstimateMap.put(est.Opportunity__c, est);
        }
      }
      List<OpportunityLineItem__c> oppoLineItemListUnsorted = [
        SELECT
          Id,
          qbo_product_service_id__c,
          Product__r.Design_Project__c,
          Name,
          Description__c,
          Opportunity__c,
          Estimate__c,
          Quantity_Estimate__c,
          Total__c,
          Total_QBO__c,
          Product__r.Name,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :estimateIds
        ORDER BY Sorting_Date__c ASC
      ];
      //New Sorting Logic Start
      List<OpportunityLineItem__c> oppoLineItemList = ProductsSorting.sortProducts(
        oppoLineItemListUnsorted
      );

      List<Id> allLineItemIds = new List<Id>();
      for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
        allLineItemIds.add(oppLineItem.id);
      }
      ////
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :allLineItemIds
      ];
      Map<Id, Id> estimateOwnerMap = new Map<Id, Id>();
      List<Id> estimateOwnerList = new List<Id>();
      for (Estimate__c est : estimatesList) {
        estimateOwnerMap.put(est.id, est.OwnerId);
        estimateOwnerList.add(est.OwnerId);
      }
      List<User> users = [
        SELECT id, Design_Bank__c
        FROM User
        WHERE Id = :estimateOwnerList
      ];
      Map<Id, Decimal> userDesignBankMap = new Map<Id, Decimal>();
      for (User user : users) {
        userDesignBankMap.put(user.id, user.Design_Bank__c);
      }
      List<Id> lineItemIds = new List<Id>();
      for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
        lineItemIds.add(oppLineItem.id);
        /*Decimal usedCredits = 0;
                for(Design_Project__c designProject: designProjects)
                {
                if(designProject.Product__c == oppLineItem.id)
                usedCredits = usedCredits + designProject.Credits__c;
                }
                if(usedCredits <= userDesignBankMap.get(estimateOwnerMap.get(oppLineItem.Estimate__c)))
                lineItemIds.add(oppLineItem.id);
                else if(!oppLineItem.Product__r.Design_Project__c)
                lineItemIds.add(oppLineItem.id);*/
      }
      ///////
      List<ExtraChargesEstimate__c> extraCharges = [
        SELECT
          Id,
          Title__c,
          index__c,
          Quantity__c,
          Credit_Available__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :lineItemIds
        ORDER BY CreatedDate ASC
      ];

      List<PricingLineItem__c> pricingList = [
        SELECT
          Id,
          Quantity__c,
          index__c,
          OpportunityLineItem__c,
          Retail_Price__c,
          Total__c,
          Estimated_Quantity__c,
          Size__c,
          Color__c,
          Net_Cost__c,
          Credit_Available__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c IN :lineItemIds
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
      Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
      for (OpportunityLineItem__c lineItem : oppoLineItemList) {
        List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
        List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
        for (PricingLineItem__c pricing : pricingList) {
          if (pricing.OpportunityLineItem__c == lineItem.Id) {
            pricings.add(pricing);
          }
        }
        if (pricings.size() > 0) {
          pricingMap.put(lineItem.Id, pricings);
        }
        for (ExtraChargesEstimate__c extraCharge : extraCharges) {
          if (extraCharge.OpportunityLineItem__c == lineItem.Id) {
            extraChargesList.add(extraCharge);
          }
        }
        if (extraChargesList.size() > 0) {
          extraChargesMap.put(lineItem.Id, extraChargesList);
        }
      }
      Map<Id, List<OpportunityLineItem__c>> estimateOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
      for (Estimate__c est : estimatesList) {
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
          if (
            opplineItem.Estimate__c == est.Id &&
            lineItemIds.contains(opplineItem.id)
          ) {
            oppLineItemList.add(opplineItem);
          }
        }
        if (oppLineItemList.size() > 0)
          estimateOpportunityLineItemMap.put(est.Id, oppLineItemList);
      }
      List<Opportunity> opportunities = Database.query(
        'SELECT Owner.Name,Account.Name, Account.Billing_Email__c, Account.BillingStreet, Account.BillingCity,' +
          ' Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.ShippingStreet, Account.ShippingCity,' +
          ' Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState,' +
          String.join(
            new List<String>(
              Schema.getGlobalDescribe()
                .get('Opportunity')
                .getDescribe()
                .fields.getMap()
                .keySet()
            ),
            ','
          ) +
          ' FROM Opportunity where id in :oppIds'
      );

      //get sync token map for estimates to update
      Map<String, String> estimateSyncTokenMap = new Map<String, String>();

      estimateSyncTokenMap = getSyncTokenMap(
        estimateIdsForSyncToken,
        accountName
      );
      Map<String, String> classRefs = new Map<String, String>();
      for (Class__c classR : [
        SELECT Id, Name, QBO_Account__c, Fully_Qualified_Name__c, Id__c
        FROM Class__c
        WHERE QBO_Account__c = :accountName
      ]) {
        classRefs.put(classR.Fully_Qualified_Name__c, classR.Id__c);
      }
      List<ExtraChargesEstimate__c> extraChargeList = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricing = new List<PricingLineItem__c>();
      List<ExtraChargesEstimate__c> extraChargeListToBeUpdated = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricingToBeUpdated = new List<PricingLineItem__c>();
      List<Estimate> estimates = new List<Estimate>();
      List<Estimate__c> estimatesToUpdate = new List<Estimate__c>();
      List<Estimate__c> estimatesErrorList = new List<Estimate__c>();
      List<QBO_Details__c> qboDetailsObjectToAdd = new List<QBO_Details__c>();
      Set<Id> setOppIds = new Set<Id>();
      for (Opportunity opp : opportunities) {
        setOppIds.add(opp.Id);
      }
      Map<Id, List<QBO_Details__c>> mapOppAccountQBId = OpportunityTriggerService.getMapOfSyncedQBORecordsAndAccount(
        setOppIds
      );
      for (Opportunity opp : opportunities) {
        Estimate__c SfEstimate = opportunityEstimateMap.get(opp.Id);

        if (
          SfEstimate != null &&
          SfEstimate.Selected_Quickbook_Instance__c == accountName
        ) {
          QBO_Details__c relatedQboRecord = new QBO_Details__c();
          if (estimateQboRecordMap.containsKey(SfEstimate.Id)) {
            relatedQboRecord = estimateQboRecordMap.get(SfEstimate.Id);
          }
          if (estimateSyncTokenMap.get(relatedQboRecord.QB_Id__c) != null) {
            List<OpportunityLineItem__c> oppLineItemRelatedToEstimate = estimateOpportunityLineItemMap.get(
              SfEstimate.Id
            );
            Estimate oppEstimate = new Estimate();
            oppEstimate.Id = relatedQboRecord.QB_Id__c;
            oppEstimate.SyncToken = estimateSyncTokenMap.get(
              relatedQboRecord.QB_Id__c
            );
            oppEstimate.ExpirationDate = String.valueOf(opp.Order_Date__c);
            oppEstimate.CustomerRef = new CustomerRef();
            oppEstimate.CustomerRef.name = opp.Account.Name;
            for (
              QBO_Details__c qboDetailsObj : mapOppAccountQBId.get(
                opp.AccountId
              )
            ) {
              if (
                qboDetailsObj.QBO_Account__c.equals(accountName) &&
                qboDetailsObj.Id_Type__c.equals('Account')
              ) {
                oppEstimate.CustomerRef.value = qboDetailsObj.QB_Id__c;
              }
            }
            oppEstimate.Line = new List<Line>();
            if (
              oppLineItemRelatedToEstimate == null ||
              oppLineItemRelatedToEstimate.size() <= 0
            ) {
              Line lineItem1 = new Line();
              lineItem1.Amount = 0;
              lineItem1.Description = 'Temp line item in case of 0 products in Salesforce';
              lineItem1.DetailType = 'SalesItemLineDetail';
              lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
              lineItem1.SalesItemLineDetail.Qty = '1';
              lineItem1.SalesItemLineDetail.UnitPrice = '0';
              lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
              lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
              oppEstimate.Line.add(lineItem1);
            } else {
              for (
                OpportunityLineItem__c sfLineItem : oppLineItemRelatedToEstimate
              ) {
                List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
                extraChargeList = extraChargesMap.get(sfLineItem.Id);
                pricing = pricingMap.get(sfLineItem.Id);
                Decimal quantity = 0;
                Decimal total = 0;
                Decimal retailPrice = 0;
                Integer count = 1;
                if (pricing != null && pricing.size() > 0) {
                  for (PricingLineItem__c rec : pricing) {
                    if (rec.OpportunityLineItem__c == sfLineItem.id) {
                      EstimateEditClass estBreakdownObj = new EstimateEditClass();
                      Decimal rQuantity = (rec.Estimated_Quantity__c == null)
                        ? 0
                        : rec.Estimated_Quantity__c;
                      estBreakdownObj.Quantity = rQuantity.setScale(2);
                      Decimal rPrice = (rec.Retail_Price__c == null)
                        ? 0
                        : rec.Retail_Price__c;
                      estBreakdownObj.retailPrice = rPrice.setScale(2);
                      if (rec.Credit_Available__c) {
                        rec.Valid_Net_Cost__c = (rec.Net_Cost__c == null)
                          ? 0
                          : rec.Net_Cost__c;
                        rec.Valid_Quantity__c = estBreakdownObj.Quantity;
                        rec.Valid_Retail_Price__c = estBreakdownObj.retailPrice;
                        pricingToBeUpdated.add(rec);
                      } else {
                        System.debug(
                          'Estimate can not be updated because of less credits'
                        );
                        return;
                      }
                      estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
                      estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
                      estBreakdownObj.description =
                        '\nDescription : ' +
                        (sfLineItem.Description__c != null
                          ? sfLineItem.Description__c
                          : '');
                      estBreakdownObj.ObjectName = 'Pricing';
                      estBreakdownObj.index = Integer.valueOf(rec.index__c);
                      EstimateLineItemBreakdownList.add(estBreakdownObj);
                    }
                  }
                }
                if (extraChargeList != null && extraChargeList.size() > 0) {
                  for (ExtraChargesEstimate__c rec : extraChargeList) {
                    if (rec.OpportunityLineItem__c == sfLineItem.id) {
                      EstimateEditClass estBreakdownObj = new EstimateEditClass();
                      Decimal rQuantity = (rec.Quantity__c == null)
                        ? 0
                        : rec.Quantity__c;
                      Decimal rPrice = (rec.Retail_Price__c == null)
                        ? 0
                        : rec.Retail_Price__c;
                      estBreakdownObj.Quantity = rQuantity.setScale(2);
                      estBreakdownObj.retailPrice = rPrice.setScale(2);
                      if (rec.Credit_Available__c) {
                        rec.Valid_Net_Cost__c = rec.Net_Cost__c;
                        rec.Valid_Quantity__c = rec.Quantity__c;
                        rec.Valid_Retail_Price__c = rec.Retail_Price__c;
                        extraChargeListToBeUpdated.add(rec);
                      } else {
                        System.debug(
                          'Estimate can not be updated because of less credits'
                        );
                        return;
                      }
                      estBreakdownObj.ProductName =
                        sfLineItem.Name +
                        '\n' +
                        rec.Title__c;
                      estBreakdownObj.ObjectName = 'ExtraCharges';
                      estBreakdownObj.recordType = rec.Charge_Type__c;
                      estBreakdownObj.index = Integer.valueOf(rec.index__c);
                      EstimateLineItemBreakdownList.add(estBreakdownObj);
                    }
                  }
                }
                //extra Charges
                EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
                  EstimateLineItemBreakdownList
                );
                for (
                  EstimateEditClass breakdown : EstimateLineItemBreakdownList
                ) {
                  if (breakdown.ObjectName == 'ExtraCharges') {
                    quantity = breakdown.Quantity;
                    quantity = quantity.setScale(2);
                    retailPrice = breakdown.retailPrice;
                    retailPrice = retailPrice.setScale(2);
                    Line lineItem1 = new Line();
                    lineItem1.Amount = quantity * retailPrice;
                    lineItem1.Description = breakdown.ProductName;
                    lineItem1.DetailType = 'SalesItemLineDetail';
                    lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                    lineItem1.SalesItemLineDetail.Qty = String.valueOf(
                      quantity
                    );
                    lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                      retailPrice
                    );
                    lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                    if (breakdown.recordType == 'AdditionalCost_FixedCharge') {
                      lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.decorationServiceId;
                    } else if (
                      breakdown.recordType == 'AdditionalCost_RunCharge'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.decorationServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_Brokerage'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_Duty'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_InboundFreight'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                    }
                    oppEstimate.Line.add(lineItem1);
                  } else if (breakdown.ObjectName == 'Pricing') {
                    quantity = breakdown.Quantity;
                    quantity = quantity.setScale(2);
                    retailPrice = breakdown.retailPrice;
                    retailPrice = retailPrice.setScale(2);
                    Line lineItem1 = new Line();
                    //   lineItem1.Amount = total;
                    lineItem1.Amount = quantity * retailPrice;
                    lineItem1.Description =
                      sfLineItem.Name +
                      breakdown.Color +
                      breakdown.Size +
                      breakdown.description;
                    lineItem1.DetailType = 'SalesItemLineDetail';
                    lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                    lineItem1.SalesItemLineDetail.Qty = String.valueOf(
                      quantity
                    );
                    lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                      retailPrice
                    );
                    lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                    System.debug(
                      '---QuickbookApiCrud--update estimate-SalesItemLineDetail----------' +
                      sfLineItem.qbo_product_service_id__c
                    );
                    String itemRef = String.valueOf(
                        sfLineItem.qbo_product_service_id__c
                      ) != null
                      ? String.valueOf(sfLineItem.qbo_product_service_id__c)
                      : quickbooksConfiguration.breakdownServiceId;
                    //lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
                    lineItem1.SalesItemLineDetail.ItemRef.value = itemRef;
                    System.debug(
                      '---QuickbookApiCrud--update estimate-SalesItemLineDetail---itemRef-------' +
                      itemRef
                    );
                    oppEstimate.Line.add(lineItem1);
                  }
                }
              }
            }
            oppEstimate.BillEmail = new BillEmail();
            oppEstimate.BillEmail.Address = opp.Account.Billing_Email__c;
            Address billingAddress = opp.Billing_Address1__c;
            BillAddr bAddr = new BillAddr();
            if (billingAddress != null) {
              bAddr.Line1 = billingAddress.getStreet() == null
                ? ''
                : billingAddress.getStreet();
              bAddr.City = billingAddress.getCity() == null
                ? ''
                : billingAddress.getCity();
              bAddr.Country = billingAddress.getCountry() == null
                ? ''
                : billingAddress.getCountry();
              bAddr.PostalCode = billingAddress.getPostalCode() == null
                ? ''
                : billingAddress.getPostalCode();
              bAddr.CountrySubDivisionCode = billingAddress.getState() == null
                ? ''
                : billingAddress.getState();
            } else {
              bAddr.Line1 = opp.Account.BillingStreet == null
                ? ''
                : opp.Account.BillingStreet;
              bAddr.City = opp.Account.BillingCity == null
                ? ''
                : opp.Account.BillingCity;
              bAddr.Country = opp.Account.BillingCountry == null
                ? ''
                : opp.Account.BillingCountry;
              bAddr.PostalCode = opp.Account.BillingPostalCode == null
                ? ''
                : opp.Account.BillingPostalCode;
              bAddr.CountrySubDivisionCode = opp.Account.BillingState == null
                ? ''
                : opp.Account.BillingState;
            }

            ShipAddr sAddr = new ShipAddr();
            Address shippingAddress = opp.Shipping_Address__c;
            if (shippingAddress != null) {
              sAddr.Line1 = shippingAddress.getStreet() == null
                ? ''
                : shippingAddress.getStreet();
              sAddr.City = shippingAddress.getCity() == null
                ? ''
                : shippingAddress.getCity();
              sAddr.Country = shippingAddress.getCountry() == null
                ? ''
                : shippingAddress.getCountry();
              sAddr.PostalCode = shippingAddress.getPostalCode() == null
                ? ''
                : shippingAddress.getPostalCode();
              sAddr.CountrySubDivisionCode = shippingAddress.getState() == null
                ? ''
                : shippingAddress.getState();
            } else {
              sAddr.Line1 = opp.Account.ShippingStreet == null
                ? ''
                : opp.Account.ShippingStreet;
              sAddr.City = opp.Account.ShippingCity == null
                ? ''
                : opp.Account.ShippingCity;
              sAddr.Country = opp.Account.ShippingCountry == null
                ? ''
                : opp.Account.ShippingCountry;
              sAddr.PostalCode = opp.Account.ShippingPostalCode == null
                ? ''
                : opp.Account.ShippingPostalCode;
              sAddr.CountrySubDivisionCode = opp.Account.ShippingState == null
                ? ''
                : opp.Account.ShippingState;
            }

            oppEstimate.BillAddr = bAddr;
            oppEstimate.ShipAddr = sAddr;

            oppEstimate.CustomField = new List<CustomField>();
            oppEstimate.CustomField.add(
              new CustomField(
                quickbooksConfiguration.qbCustomFieldId,
                quickbooksConfiguration.qbCustomField,
                opp.Id
              )
            );

            if (classRefs.get(opp.Owner.Name) != null) {
              oppEstimate.ClassRef = new ClassRef();
              oppEstimate.ClassRef.name = opp.Owner.Name;
              oppEstimate.ClassRef.value = classRefs.get(opp.Owner.Name);
            }

            String json = JSON.serialize(oppEstimate, true);

            system.debug('json---->>>>>>>>' + json);
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            request.setHeader(
              'Authorization',
              'Bearer ' + quickbooksConfiguration.accessToken
            );
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(json);
            request.setMethod('POST');
            if (Test.isRunningTest()) {
              request.setEndPoint('http://test.com/test/sendEstimate');
            } else {
              request.setEndPoint(
                quickbooksConfiguration.qbApiEndPoint +
                  '/v3/company/' +
                  quickbooksConfiguration.realMId +
                  '/estimate?minorversion=38'
              );
            }
            response = http.send(request);
            if (response.getStatusCode() == 200) {
              Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
                response.getBody()
              );

              relatedQboRecord.QB_Id__c = (String) ((Map<String, Object>) results.get(
                  'Estimate'
                ))
                .get('Id');
              relatedQboRecord.QB_Estimate_Number__c = (String) ((Map<String, Object>) results.get(
                  'Estimate'
                ))
                .get('DocNumber');
              qboDetailsObjectToAdd.add(relatedQboRecord);
              //          SfEstimate.Estimate_Number__c=(String)((Map<String,Object>)results.get('Estimate')).get('DocNumber');
              //         SfEstimate.Estimate_QB_Id__c = (String)((Map<String,Object>)results.get('Estimate')).get('Id');
              estimatesToUpdate.add(SfEstimate);
            } else if (response.getStatusCode() == 401) {
              authenticationErrorEmail(
                response,
                recordDetails,
                functionName,
                accountName
              );
            } else {
              serverErrorEmails(
                response,
                opp.Name,
                'Opportunity',
                accountName,
                'Class QuickbookApiCrud , UpdateEstimate ',
                'Estimate',
                opp.Id
              );
            }
          } else {
            System.debug('ERROR IN SYNCING: estimateSyncToken doesnt exist');
          }
        }
      }
      if (
        extraChargeListToBeUpdated != null &&
        extraChargeListToBeUpdated.size() > 0
      )
        update extraChargeListToBeUpdated;
      if (pricingToBeUpdated != null && pricingToBeUpdated.size() > 0)
        update pricingToBeUpdated;
      update qboDetailsObjectToAdd;
      if (estimatesToUpdate.size() > 0) {
        for (Estimate__c est : estimatesToUpdate) {
          est.QB_Update__c = false;
          est.Data_Changed__c = false;
        }
        update estimatesToUpdate;
      }
    } else {
      authenticationErrorEmail(recordDetails, functionName, accountName);
    }
  }

  @future(callout=true)
  public static void createEstimate(
    Set<Id> oppIds,
    Set<Id> estimateIds,
    String accountName
  ) {
    //String OpportunityId
    String recordDetails =
      'Opportunities Records <br/>' +
      oppIds.toString() +
      '<br/><br/> EstimatesIds ' +
      estimateIds.toString();
    String functionName = 'Create Estimate (createEstimate)';
    QuicbooksConfiguration quickbooksConfiguration = getQuicbooksConfiguration(
      accountName
    );
    if (QuickbooksConfiguration != null) {
      Map<Id, Estimate__c> estimateMap = new Map<Id, Estimate__c>(
        [
          SELECT
            Id,
            Opportunity__c,
            Future_Call_In_Progress__c,
            Selected_Quickbook_Instance__c,
            In_Hands_Date__c,
            Order_Date__c,
            Terms__c,
            Status__c
          FROM Estimate__c
          WHERE Id = :estimateIds
        ]
      );
      List<Estimate__c> estimatesList = [
        SELECT
          Id,
          OwnerId,
          Future_Call_In_Progress__c,
          Opportunity__c,
          Selected_Quickbook_Instance__c,
          In_Hands_Date__c,
          Order_Date__c,
          Terms__c,
          Status__c
        FROM Estimate__c
        WHERE Id = :estimateIds
      ];
      Map<Id, Estimate__c> opportunityEstimateMap = new Map<Id, Estimate__c>();
      for (Estimate__c est : estimatesList) {
        opportunityEstimateMap.put(est.Opportunity__c, est);
      }
      List<OpportunityLineItem__c> oppoLineItemListUnsorted = [
        SELECT
          Id,
          qbo_product_service_id__c,
          Product__r.Design_Project__c,
          Name,
          Description__c,
          Opportunity__c,
          Estimate__c,
          Quantity_Estimate__c,
          Total__c,
          Total_QBO__c,
          Product__r.Name,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :estimateIds
        ORDER BY Sorting_Date__c ASC
      ];

      //New Sorting Logic Start
      List<OpportunityLineItem__c> oppoLineItemList = new List<OpportunityLineItem__c>();

      for (Integer i = 0; i < oppoLineItemListUnsorted.size(); i++) {
        oppoLineItemList.add(oppoLineItemListUnsorted[i]);
        for (Integer j = oppoLineItemListUnsorted.size() - 1; j > i; j--) {
          if (
            oppoLineItemList[oppoLineItemList.size() - 1].Product__r.Name ==
            oppoLineItemListUnsorted[j].Product__r.Name
          ) {
            oppoLineItemList.add(oppoLineItemListUnsorted[j]);
            oppoLineItemListUnsorted.remove(j);
          }
        }
      }

      //New Sorting Logic End

      List<Id> allLineItemIds = new List<Id>();
      for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
        allLineItemIds.add(oppLineItem.id);
      }
      ////
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :allLineItemIds
      ];
      Map<Id, Id> estimateOwnerMap = new Map<Id, Id>();
      List<Id> estimateOwnerList = new List<Id>();
      for (Estimate__c est : estimatesList) {
        estimateOwnerMap.put(est.id, est.OwnerId);
        estimateOwnerList.add(est.OwnerId);
      }
      List<User> users = [
        SELECT id, Design_Bank__c
        FROM User
        WHERE Id = :estimateOwnerList
      ];
      Map<Id, Decimal> userDesignBankMap = new Map<Id, Decimal>();
      for (User user : users) {
        userDesignBankMap.put(user.id, user.Design_Bank__c);
      }
      List<Id> lineItemIds = new List<Id>();
      for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
        /*Decimal usedCredits = 0;
                for(Design_Project__c designProject: designProjects)
                {
                if(designProject.Product__c == oppLineItem.id)
                usedCredits = usedCredits + designProject.Credits__c;
                }
                if(usedCredits <= userDesignBankMap.get(estimateOwnerMap.get(oppLineItem.Estimate__c)))
                lineItemIds.add(oppLineItem.id);
                else if(!oppLineItem.Product__r.Design_Project__c)*/
        lineItemIds.add(oppLineItem.id);
      }
      List<ExtraChargesEstimate__c> extraCharges = [
        SELECT
          Id,
          Title__c,
          index__c,
          Quantity__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Credit_Available__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :lineItemIds
        ORDER BY CreatedDate ASC
      ];
      List<PricingLineItem__c> pricingList = [
        SELECT
          Id,
          Quantity__c,
          index__c,
          Net_Cost__c,
          Credit_Available__c,
          OpportunityLineItem__c,
          Color__c,
          Size__c,
          Retail_Price__c,
          Total__c,
          Estimated_Quantity__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c IN :lineItemIds
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
      Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
      List<ExtraChargesEstimate__c> extraChargeList = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricing = new List<PricingLineItem__c>();
      List<ExtraChargesEstimate__c> extraChargeListToBeUpdated = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricingToBeUpdated = new List<PricingLineItem__c>();
      for (OpportunityLineItem__c lineItem : oppoLineItemList) {
        List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
        List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
        for (PricingLineItem__c price : pricingList) {
          if (price.OpportunityLineItem__c == lineItem.Id) {
            pricings.add(price);
          }
        }
        if (pricings.size() > 0) {
          pricingMap.put(lineItem.Id, pricings);
        }
        for (ExtraChargesEstimate__c extCharge : extraCharges) {
          if (extCharge.OpportunityLineItem__c == lineItem.Id) {
            extraChargesList.add(extCharge);
          }
        }
        if (extraChargesList.size() > 0) {
          extraChargesMap.put(lineItem.Id, extraChargesList);
        }
      }
      Map<Id, List<OpportunityLineItem__c>> estimateOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
      for (Estimate__c est : estimatesList) {
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
        for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
          if (
            opplineItem.Estimate__c == est.Id &&
            lineItemIds.contains(opplineItem.id)
          ) {
            oppLineItemList.add(opplineItem);
          }
        }
        if (oppLineItemList.size() > 0)
          estimateOpportunityLineItemMap.put(est.Id, oppLineItemList);
      }
      List<Opportunity> opportunities = Database.query(
        'SELECT Owner.Name,Account.Name,  Account.Billing_Email__c, Account.BillingStreet, Account.BillingCity,' +
          ' Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.ShippingStreet, Account.ShippingCity,' +
          ' Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState,' +
          String.join(
            new List<String>(
              Schema.getGlobalDescribe()
                .get('Opportunity')
                .getDescribe()
                .fields.getMap()
                .keySet()
            ),
            ','
          ) +
          ' FROM Opportunity where id in :oppIds'
      );
      Map<String, String> classRefs = new Map<String, String>();
      for (Class__c classR : [
        SELECT Id, Name, QBO_Account__c, Fully_Qualified_Name__c, Id__c
        FROM Class__c
        WHERE QBO_Account__c = :accountName
      ]) {
        classRefs.put(classR.Fully_Qualified_Name__c, classR.Id__c);
      }
      List<Estimate> estimates = new List<Estimate>();
      List<QBO_Details__c> qboDetailsObjectToAdd = new List<QBO_Details__c>();
      Set<Id> setOppIds = new Set<Id>();
      for (Opportunity opp : opportunities) {
        setOppIds.add(opp.Id);
      }
      Map<Id, List<QBO_Details__c>> mapOppAccountQBId = OpportunityTriggerService.getMapOfSyncedQBORecordsAndAccount(
        setOppIds
      );

      Map<Id, Boolean> isEstimateCreatedMap = new Map<Id, Boolean>();
      Map<Id, Boolean> estimateQboRecordExistsMap = getQBODetailsExistsMap(
        estimateIds,
        accountName
      );
      for (Opportunity opp : opportunities) {
        QBO_Details__c qboRelatedRecord = new QBO_Details__c();
        qboRelatedRecord.Name = 'Estimate - (' + accountName + ')';
        qboRelatedRecord.Account__c = opp.AccountId;
        if (opportunityEstimateMap.containsKey(opp.Id)) {
          qboRelatedRecord.Salesforce_Record_Id__c = opportunityEstimateMap.get(
              opp.Id
            )
            .Id;
        }
        qboRelatedRecord.Opportunity__c = opp.Id;
        qboRelatedRecord.Id_Type__c = 'Estimate';
        qboRelatedRecord.QBO_Account__c = accountName;

        Estimate__c SfEstimate = opportunityEstimateMap.get(opp.Id);
        if (
          SfEstimate != null &&
          SfEstimate.Selected_Quickbook_Instance__c == accountName &&
          !(isEstimateCreatedMap.containsKey(SfEstimate.Id)) &&
          !(estimateQboRecordExistsMap.containsKey(SfEstimate.Id))
        ) {
          List<OpportunityLineItem__c> oppLineItemRelatedToEstimate = estimateOpportunityLineItemMap.get(
            SfEstimate.Id
          );
          Estimate oppEstimate = new Estimate();
          oppEstimate.ExpirationDate = String.valueOf(opp.Order_Date__c);

          oppEstimate.CustomerRef = new CustomerRef();
          oppEstimate.CustomerRef.name = opp.Account.Name;
          for (
            QBO_Details__c qboDetailsObj : mapOppAccountQBId.get(opp.AccountId)
          ) {
            if (
              qboDetailsObj.QBO_Account__c.equals(accountName) &&
              qboDetailsObj.Id_Type__c.equals('Account')
            ) {
              oppEstimate.CustomerRef.value = qboDetailsObj.QB_Id__c;
              system.debug(
                'oppEstimate.CustomerRef.value--->>>' +
                oppEstimate.CustomerRef.value
              );
            }
          }
          oppEstimate.Line = new List<Line>();
          if (
            oppLineItemRelatedToEstimate != null &&
            oppLineItemRelatedToEstimate.size() > 0
          ) {
            //TODO
            //individual pricing will
            for (
              OpportunityLineItem__c sfLineItem : oppLineItemRelatedToEstimate
            ) {
              List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
              extraChargeList = extraChargesMap.get(sfLineItem.Id);
              pricing = pricingMap.get(sfLineItem.Id);
              Decimal quantity = 0;
              Decimal total = 0;
              Decimal retailPrice = 0;
              Integer count = 1;
              if (pricing != null && pricing.size() > 0) {
                for (PricingLineItem__c rec : pricing) {
                  if (rec.OpportunityLineItem__c == sfLineItem.id) {
                    EstimateEditClass estBreakdownObj = new EstimateEditClass();
                    Decimal estQty = (rec.Estimated_Quantity__c == null)
                      ? 0
                      : rec.Estimated_Quantity__c;
                    estBreakdownObj.Quantity = estQty.setScale(2);
                    Decimal rPrice = (rec.Retail_Price__c == null)
                      ? 0
                      : rec.Retail_Price__c;
                    estBreakdownObj.retailPrice = rPrice.setScale(2);
                    if (rec.Credit_Available__c) {
                      rec.Valid_Net_Cost__c = (rec.Net_Cost__c == null)
                        ? 0
                        : rec.Net_Cost__c;
                      rec.Valid_Quantity__c = estBreakdownObj.Quantity;
                      rec.Valid_Retail_Price__c = estBreakdownObj.retailPrice;
                      pricingToBeUpdated.add(rec);
                    } else {
                      System.debug(
                        'Estimate can not be inserted because of less credits'
                      );
                      return;
                    }
                    estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
                    estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
                    estBreakdownObj.description =
                      '\nDescription : ' +
                      (sfLineItem.Description__c != null
                        ? sfLineItem.Description__c
                        : '');
                    estBreakdownObj.ObjectName = 'Pricing';
                    estBreakdownObj.index = Integer.valueOf(rec.index__c);
                    EstimateLineItemBreakdownList.add(estBreakdownObj);
                  }
                }
              }
              if (extraChargeList != null && extraChargeList.size() > 0) {
                for (ExtraChargesEstimate__c rec : extraChargeList) {
                  if (rec.OpportunityLineItem__c == sfLineItem.id) {
                    EstimateEditClass estBreakdownObj = new EstimateEditClass();
                    Decimal Qty = (rec.Quantity__c == null)
                      ? 0
                      : rec.Quantity__c;
                    estBreakdownObj.Quantity = Qty.setScale(2);
                    Decimal rPrice = (rec.Retail_Price__c == null)
                      ? 0
                      : rec.Retail_Price__c;
                    estBreakdownObj.retailPrice = rPrice.setScale(2);
                    if (rec.Credit_Available__c) {
                      rec.Valid_Net_Cost__c = (rec.Net_Cost__c == null)
                        ? 0
                        : rec.Net_Cost__c;
                      rec.Valid_Quantity__c = estBreakdownObj.Quantity;
                      rec.Valid_Retail_Price__c = estBreakdownObj.retailPrice;
                      extraChargeListToBeUpdated.add(rec);
                    } else {
                      System.debug(
                        'Estimate can not be inserted because of less credits'
                      );
                      return;
                    }
                    estBreakdownObj.ProductName =
                      sfLineItem.Name +
                      '\n' +
                      rec.Title__c;
                    estBreakdownObj.ObjectName = 'ExtraCharges';
                    estBreakdownObj.recordType = rec.Charge_Type__c;
                    estBreakdownObj.index = Integer.valueOf(rec.index__c);
                    EstimateLineItemBreakdownList.add(estBreakdownObj);
                  }
                }
              }
              //extra Charges
              EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
                EstimateLineItemBreakdownList
              );
              for (
                EstimateEditClass breakdown : EstimateLineItemBreakdownList
              ) {
                if (breakdown.ObjectName == 'ExtraCharges') {
                  quantity = breakdown.Quantity;
                  quantity = quantity.setScale(2);
                  retailPrice = breakdown.retailPrice;
                  retailPrice = retailPrice.setScale(2);
                  Line lineItem1 = new Line();
                  lineItem1.Amount = quantity * retailPrice;
                  lineItem1.Description = breakdown.ProductName;
                  lineItem1.DetailType = 'SalesItemLineDetail';
                  lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                  lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
                  lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                    retailPrice
                  );
                  lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                  if (breakdown.recordType == 'AdditionalCost_FixedCharge') {
                    lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.decorationServiceId;
                  } else if (
                    breakdown.recordType == 'AdditionalCost_RunCharge'
                  ) {
                    lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.decorationServiceId;
                  } else if (
                    breakdown.recordType == 'InternationalCost_Brokerage'
                  ) {
                    lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                  } else if (breakdown.recordType == 'InternationalCost_Duty') {
                    lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                  } else if (
                    breakdown.recordType == 'InternationalCost_InboundFreight'
                  ) {
                    lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.fulfillmentServiceId;
                  }
                  oppEstimate.Line.add(lineItem1);
                } else if (breakdown.ObjectName == 'Pricing') {
                  quantity = breakdown.Quantity;
                  quantity = quantity.setScale(2);
                  retailPrice = breakdown.retailPrice;
                  retailPrice = retailPrice.setScale(2);
                  Line lineItem1 = new Line();
                  //   lineItem1.Amount = total;
                  lineItem1.Amount = quantity * retailPrice;
                  lineItem1.Description =
                    sfLineItem.Name +
                    breakdown.Color +
                    breakdown.Size +
                    breakdown.description;
                  lineItem1.DetailType = 'SalesItemLineDetail';
                  lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                  lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
                  lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                    retailPrice
                  );
                  lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                  System.debug(
                    '---QuickbookApiCrud--create estimate-SalesItemLineDetail----------' +
                    sfLineItem.qbo_product_service_id__c
                  );
                  // lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
                  String itemRef = String.valueOf(
                      sfLineItem.qbo_product_service_id__c
                    ) != null
                    ? String.valueOf(sfLineItem.qbo_product_service_id__c)
                    : quickbooksConfiguration.breakdownServiceId;
                  System.debug(
                    '---QuickbookApiCrud--create estimate-SalesItemLineDetail---itemRef-------' +
                    itemRef
                  );
                  lineItem1.SalesItemLineDetail.ItemRef.value = itemRef;
                  oppEstimate.Line.add(lineItem1);
                }
              }
            }
          } else {
            Line lineItem1 = new Line();
            lineItem1.Amount = 0;
            lineItem1.Description = 'Temp line item in case of 0 products in Salesforce';
            lineItem1.DetailType = 'SalesItemLineDetail';
            lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
            lineItem1.SalesItemLineDetail.Qty = '1';
            lineItem1.SalesItemLineDetail.UnitPrice = '0';
            lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
            lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
            oppEstimate.Line.add(lineItem1);
          }
          oppEstimate.BillEmail = new BillEmail();
          oppEstimate.BillEmail.Address = opp.Account.Billing_Email__c;
          Address billingAddress = opp.Billing_Address1__c;
          BillAddr bAddr = new BillAddr();
          if (billingAddress != null) {
            bAddr.Line1 = billingAddress.getStreet() == null
              ? ''
              : billingAddress.getStreet();
            bAddr.City = billingAddress.getCity() == null
              ? ''
              : billingAddress.getCity();
            bAddr.Country = billingAddress.getCountry() == null
              ? ''
              : billingAddress.getCountry();
            bAddr.PostalCode = billingAddress.getPostalCode() == null
              ? ''
              : billingAddress.getPostalCode();
            bAddr.CountrySubDivisionCode = billingAddress.getState() == null
              ? ''
              : billingAddress.getState();
          } else {
            bAddr.Line1 = opp.Account.BillingStreet == null
              ? ''
              : opp.Account.BillingStreet;
            bAddr.City = opp.Account.BillingCity == null
              ? ''
              : opp.Account.BillingCity;
            bAddr.Country = opp.Account.BillingCountry == null
              ? ''
              : opp.Account.BillingCountry;
            bAddr.PostalCode = opp.Account.BillingPostalCode == null
              ? ''
              : opp.Account.BillingPostalCode;
            bAddr.CountrySubDivisionCode = opp.Account.BillingState == null
              ? ''
              : opp.Account.BillingState;
          }

          ShipAddr sAddr = new ShipAddr();
          Address shippingAddress = opp.Shipping_Address__c;
          if (shippingAddress != null) {
            sAddr.Line1 = shippingAddress.getStreet() == null
              ? ''
              : shippingAddress.getStreet();
            sAddr.City = shippingAddress.getCity() == null
              ? ''
              : shippingAddress.getCity();
            sAddr.Country = shippingAddress.getCountry() == null
              ? ''
              : shippingAddress.getCountry();
            sAddr.PostalCode = shippingAddress.getPostalCode() == null
              ? ''
              : shippingAddress.getPostalCode();
            sAddr.CountrySubDivisionCode = shippingAddress.getState() == null
              ? ''
              : shippingAddress.getState();
          } else {
            sAddr.Line1 = opp.Account.ShippingStreet == null
              ? ''
              : opp.Account.ShippingStreet;
            sAddr.City = opp.Account.ShippingCity == null
              ? ''
              : opp.Account.ShippingCity;
            sAddr.Country = opp.Account.ShippingCountry == null
              ? ''
              : opp.Account.ShippingCountry;
            sAddr.PostalCode = opp.Account.ShippingPostalCode == null
              ? ''
              : opp.Account.ShippingPostalCode;
            sAddr.CountrySubDivisionCode = opp.Account.ShippingState == null
              ? ''
              : opp.Account.ShippingState;
          }

          oppEstimate.BillAddr = bAddr;
          oppEstimate.ShipAddr = sAddr;

          oppEstimate.CustomField = new List<CustomField>();

          oppEstimate.CustomField.add(
            new CustomField(
              quickbooksConfiguration.qbCustomFieldId,
              quickbooksConfiguration.qbCustomField,
              opp.Id
            )
          );

          if (classRefs.get(opp.Owner.Name) != null) {
            oppEstimate.ClassRef = new ClassRef();
            oppEstimate.ClassRef.name = opp.Owner.Name;
            system.debug(
              'oppEstimate.ClassRef.name---->>>' + oppEstimate.ClassRef.name
            );
            oppEstimate.ClassRef.value = classRefs.get(opp.Owner.Name);
          }

          String json = JSON.serialize(oppEstimate, true);
          HttpRequest request = new HttpRequest();
          HttpResponse response = new HttpResponse();
          Http http = new Http();
          request.setHeader(
            'Authorization',
            'Bearer ' + quickbooksConfiguration.accessToken
          );
          request.setHeader('Accept', 'application/json');
          request.setHeader('Content-Type', 'application/json;charset=UTF-8');
          request.setBody(json);
          request.setMethod('POST');
          if (Test.isRunningTest()) {
            request.setEndPoint('http://test.com/test/sendEstimate');
          } else {
            request.setEndPoint(
              quickbooksConfiguration.qbApiEndPoint +
                '/v3/company/' +
                quickbooksConfiguration.realMId +
                '/estimate?minorversion=38'
            );
          }
          response = http.send(request);
          if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
              response.getBody()
            );
            qboRelatedRecord.QB_Id__c = (String) ((Map<String, Object>) results.get(
                'Estimate'
              ))
              .get('Id');
            qboRelatedRecord.Salesforce_Record_Id__c = SfEstimate.Id;
            qboRelatedRecord.Name =
              'Estimate - ' +
              qboRelatedRecord.QB_Id__c +
              ' (' +
              accountName +
              ')';
            qboRelatedRecord.QB_Estimate_Number__c = (String) ((Map<String, Object>) results.get(
                'Estimate'
              ))
              .get('DocNumber');
            isEstimateCreatedMap.put(SfEstimate.Id, true);
            qboDetailsObjectToAdd.add(qboRelatedRecord);
          } else if (response.getStatusCode() == 401) {
            authenticationErrorEmail(
              response,
              recordDetails,
              functionName,
              accountName
            );
          } else {
            serverErrorEmails(
              response,
              opp.Name,
              'Opportunity',
              accountName,
              'Class QuickbookApiCrud , createEstimate ',
              'Estimate',
              opp.Id
            );
          }
        } else if (SfEstimate == null) {
          customErrorEmail(
            'Issue in syncing. Estimate Doesnt exist.<br/>',
            opp.Id,
            opp.Name,
            'Class QuickbookApiCrud, CreateEstimate'
          );
        }
      }

      if (qboDetailsObjectToAdd.size() > 0) {
        if (
          extraChargeListToBeUpdated != null &&
          extraChargeListToBeUpdated.size() > 0
        )
          update extraChargeListToBeUpdated;
        if (pricingToBeUpdated != null && pricingToBeUpdated.size() > 0)
          update pricingToBeUpdated;
        upsert qboDetailsObjectToAdd;
      }
    } else {
      authenticationErrorEmail(recordDetails, functionName, accountName);
    }
  }

  @future(callout=true)
  public static void createInvoiceUpdated(
    Set<Id> orderIds,
    Map<Id, String> accountNames
  ) {
    try {
      List<Order> ordersList = getOrders(orderIds);
      List<QB_Credentials__c> QBOCredentials = getQBOCredentials(accountNames);
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = getAccountConfigurations(
        accountNames
      );
      Map<Id, QuicbooksConfiguration> qboConfigs = getQuicbooksConfigurations(
        QBOCredentials,
        accountConfiguration,
        accountNames
      );
      List<OpportunityLineItem__c> oppoLineItemList = getOpportunityLineItems(
        orderIds
      );
      Map<Id, List<ExtraChargesEstimate__c>> extraChargesMap = getExtraChargesMap(
        oppoLineItemList
      );
      Map<Id, List<PricingLineItem__c>> pricingMap = getPricingMap(
        oppoLineItemList
      );
      Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap = getOrderOpportunityLineItemMap(
        ordersList,
        oppoLineItemList
      );
      Map<String, String> termRefs = getSalesTermReferences(accountNames);
      List<QBO_Details__c> qboDetailsList = getQboDetailsList(
        ordersList,
        accountNames
      );
      List<Order> ordersToUpdate = new List<Order>();

      for (Order orderObj : ordersList) {
        Invoice inv = buildInvoice(
          orderObj,
          qboConfigs,
          termRefs,
          qboDetailsList,
          orderOpportunityLineItemMap,
          extraChargesMap,
          pricingMap
        );
        HttpRequest request = buildHttpRequest(inv, qboConfigs, orderObj);
        HttpResponse response = sendHttpRequest(request);
        handleResponse(response, orderObj, accountNames, qboConfigs);
        ordersToUpdate.add(orderObj);
      }

      OrderTriggerService.markInvoicesPaid(ordersToUpdate);
      update ordersToUpdate;
    } catch (Exception ex) {
      System.debug(
        'Exception in Create Invoice-->>>>>>' +
          ex.getMessage() +
          '->>>>>' +
          ex.getCause() +
          '--------->>>>>>>>' +
          ex.getStackTraceString()
      );
    }
  }

  private static List<Order> getOrders(Set<Id> orderIds) {
    return [
      SELECT
        Id,
        Name,
        OpportunityId,
        AccountId,
        Invoice_Email__c,
        Order_Amount__c,
        Balance_Due__c,
        Balance_Due_Formula__c,
        Quickbooks_Instance__c,
        Invoice_Date__c,
        Invoice_Due_Date__c,
        Invoice_Ship_Date__c,
        Invoice_Terms__c
      FROM Order
      WHERE Id IN :orderIds
    ];
  }

  private static List<QB_Credentials__c> getQBOCredentials(
    Map<Id, String> accountNames
  ) {
    return [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c IN :accountNames.Values()
    ];
  }

  private static List<Quickbooks_Accounts_Configurations__c> getAccountConfigurations(
    Map<Id, String> accountNames
  ) {
    return [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c,
        Service_Id_Decoration__c,
        Service_Id_Fulfillment__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c IN :accountNames.Values()
    ];
  }

  private static Map<Id, QuicbooksConfiguration> getQuicbooksConfigurations(
    List<QB_Credentials__c> QBOCredentials,
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration,
    Map<Id, String> accountNames
  ) {
    Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();

    for (QB_Credentials__c QBOCred : QBOCredentials) {
      for (
        Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
      ) {
        if (
          accConfig.Quickbooks_Account_Tittle__c ==
          QBOCred.Synced_Account_Title__c
        ) {
          QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
            QBOCred,
            accConfig
          );
          for (Id key : accountNames.keySet()) {
            if (accountNames.get(key) == QBOCred.Synced_Account_Title__c) {
              qboConfigs.put(key, qboConfig);
            }
          }
        }
      }
    }
    return qboConfigs;
  }

  private static List<OpportunityLineItem__c> getOpportunityLineItems(
    Set<Id> orderIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Work_Order__c,
        Description__c,
        Opportunity__c,
        Estimate__c,
        Quantity_Estimate__c,
        Total__c,
        Total_QBO__c,
        Product__r.Name,
        Sorting_Date__c,
        qbo_product_service_id__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :orderIds
      ORDER BY Sorting_Date__c ASC
    ];
  }

  private static Map<Id, List<ExtraChargesEstimate__c>> getExtraChargesMap(
    List<OpportunityLineItem__c> oppoLineItemList
  ) {
    List<Id> lineItemIds = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
      lineItemIds.add(oppLineItem.Id);
    }

    Map<Id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<Id, List<ExtraChargesEstimate__c>>();

    for (ExtraChargesEstimate__c extraCharge : [
      SELECT
        Id,
        Title__c,
        index__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :lineItemIds
      ORDER BY CreatedDate ASC
    ]) {
      if (!extraChargesMap.containsKey(extraCharge.OpportunityLineItem__c)) {
        extraChargesMap.put(
          extraCharge.OpportunityLineItem__c,
          new List<ExtraChargesEstimate__c>()
        );
      }
      extraChargesMap.get(extraCharge.OpportunityLineItem__c).add(extraCharge);
    }

    return extraChargesMap;
  }

  private static Map<Id, List<PricingLineItem__c>> getPricingMap(
    List<OpportunityLineItem__c> oppoLineItemList
  ) {
    List<Id> lineItemIds = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
      lineItemIds.add(oppLineItem.Id);
    }

    Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();

    for (PricingLineItem__c pricing : [
      SELECT
        Id,
        Quantity__c,
        index__c,
        OpportunityLineItem__c,
        Color__c,
        Size__c,
        Retail_Price__c,
        Total__c,
        Estimated_Quantity__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :lineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ]) {
      if (!pricingMap.containsKey(pricing.OpportunityLineItem__c)) {
        pricingMap.put(
          pricing.OpportunityLineItem__c,
          new List<PricingLineItem__c>()
        );
      }
      pricingMap.get(pricing.OpportunityLineItem__c).add(pricing);
    }

    return pricingMap;
  }

  private static Map<Id, List<OpportunityLineItem__c>> getOrderOpportunityLineItemMap(
    List<Order> ordersList,
    List<OpportunityLineItem__c> oppoLineItemList
  ) {
    Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();

    for (Order order : ordersList) {
      List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
      for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
        if (opplineItem.Work_Order__c == order.Id) {
          oppLineItemList.add(opplineItem);
        }
      }
      orderOpportunityLineItemMap.put(order.Id, oppLineItemList);
    }

    return orderOpportunityLineItemMap;
  }

  private static Map<String, String> getSalesTermReferences(
    Map<Id, String> accountNames
  ) {
    Map<String, String> termRefs = new Map<String, String>();

    for (Sales_Term__c term : [
      SELECT Id, Id__c, Name, QBO_Account__c
      FROM Sales_Term__c
      WHERE QBO_Account__c IN :accountNames.Values()
    ]) {
      termRefs.put(term.Name, term.Id__c);
    }

    return termRefs;
  }

  private static List<QBO_Details__c> getQboDetailsList(
    List<Order> ordersList,
    Map<Id, String> accountNames
  ) {
    return [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Account__r.Name,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c = :ordersList[0].AccountId
        AND Id_Type__c = :'Account'
        AND QBO_Account__c IN :accountNames.Values()
    ];
  }

  private static Invoice buildInvoice(
    Order orderObj,
    Map<Id, QuicbooksConfiguration> qboConfigs,
    Map<String, String> termRefs,
    List<QBO_Details__c> qboDetailsList,
    Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap,
    Map<Id, List<ExtraChargesEstimate__c>> extraChargesMap,
    Map<Id, List<PricingLineItem__c>> pricingMap
  ) {
    Invoice inv = new Invoice();
    inv.CustomerRef = new CustomerRef();

    if (qboDetailsList != null && !qboDetailsList.isEmpty()) {
      inv.CustomerRef.name = qboDetailsList[0].Account__r.Name;
      inv.CustomerRef.value = (String) qboDetailsList[0].QB_Id__c;
    }

    inv.TotalAmt = orderObj.Order_Amount__c;
    inv.Balance = orderObj.Balance_Due__c;
    inv.BillEmail = new billEmail();
    inv.BillEmail.Address = orderObj.Invoice_Email__c != null
      ? orderObj.Invoice_Email__c
      : null;
    inv.TxnDate = String.valueOf(orderObj.Invoice_Date__c);
    inv.DueDate = String.valueOf(orderObj.Invoice_Due_Date__c);
    inv.ShipDate = orderObj.Invoice_Ship_Date__c;
    inv.SalesTermRef = new SalesTermRef();
    inv.SalesTermRef.value = termRefs.get(orderObj.Invoice_Terms__c) != null
      ? termRefs.get(orderObj.Invoice_Terms__c)
      : '';
    inv.CustomField = new List<CustomField>();

    if (qboConfigs != null && qboConfigs.get(orderObj.Id) != null) {
      inv.CustomField.add(
        new CustomField(
          qboConfigs.get(orderObj.Id).qbCustomFieldId,
          qboConfigs.get(orderObj.Id).qbCustomField,
          orderObj.OpportunityId
        )
      );
    }

    inv.Line = new List<Line>();

    List<OpportunityLineItem__c> oppLineItemRelatedToOrderUnsorted = orderOpportunityLineItemMap.get(
      orderObj.Id
    );

    //New Sorting Logic Start
    List<OpportunityLineItem__c> oppLineItemRelatedToOrder = new List<OpportunityLineItem__c>();

    for (Integer i = 0; i < oppLineItemRelatedToOrderUnsorted.size(); i++) {
      oppLineItemRelatedToOrder.add(oppLineItemRelatedToOrderUnsorted[i]);
      for (
        Integer j = oppLineItemRelatedToOrderUnsorted.size() - 1; j > i; j--
      ) {
        if (
          oppLineItemRelatedToOrder[oppLineItemRelatedToOrder.size() - 1]
            .Product__r.Name ==
          oppLineItemRelatedToOrderUnsorted[j].Product__r.Name
        ) {
          oppLineItemRelatedToOrder.add(oppLineItemRelatedToOrderUnsorted[j]);
          oppLineItemRelatedToOrderUnsorted.remove(j);
        }
      }
    }

    //New Sorting Logic End

    if (oppLineItemRelatedToOrder.size() > 0) {
      for (OpportunityLineItem__c sfLineItem : oppLineItemRelatedToOrder) {
        List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
        List<ExtraChargesEstimate__c> extraChargeList = extraChargesMap.get(
          sfLineItem.Id
        );
        List<PricingLineItem__c> pricing = pricingMap.get(sfLineItem.Id);
        Decimal quantity = 0;
        Decimal total = 0;
        Decimal retailPrice = 0;
        Integer count = 1;
        if (pricing != null && pricing.size() > 0) {
          for (PricingLineItem__c rec : pricing) {
            if (rec.OpportunityLineItem__c == sfLineItem.id) {
              EstimateEditClass estBreakdownObj = new EstimateEditClass();
              Decimal estQty = (rec.Estimated_Quantity__c == null)
                ? 0
                : rec.Estimated_Quantity__c;
              estBreakdownObj.Quantity = estQty.setScale(2);
              Decimal rPrice = (rec.Retail_Price__c == null)
                ? 0
                : rec.Retail_Price__c;
              estBreakdownObj.retailPrice = rPrice.setScale(2);
              estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
              estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
              estBreakdownObj.ObjectName = 'Pricing';
              estBreakdownObj.index = Integer.valueOf(rec.index__c);
              EstimateLineItemBreakdownList.add(estBreakdownObj);
            }
          }
        }
        if (extraChargeList != null && extraChargeList.size() > 0) {
          for (ExtraChargesEstimate__c rec : extraChargeList) {
            if (rec.OpportunityLineItem__c == sfLineItem.id) {
              EstimateEditClass estBreakdownObj = new EstimateEditClass();
              Decimal Qty = (rec.Quantity__c == null) ? 0 : rec.Quantity__c;
              estBreakdownObj.Quantity = Qty.setScale(2);
              Decimal rPrice = (rec.Retail_Price__c == null)
                ? 0
                : rec.Retail_Price__c;
              estBreakdownObj.retailPrice = rPrice.setScale(2);
              estBreakdownObj.ProductName =
                sfLineItem.Name +
                '\n' +
                rec.Title__c;
              estBreakdownObj.ObjectName = 'ExtraCharges';
              estBreakdownObj.recordType = rec.Charge_Type__c;
              estBreakdownObj.index = Integer.valueOf(rec.index__c);
              EstimateLineItemBreakdownList.add(estBreakdownObj);
            }
          }
        }
        //extra Charges
        EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
          EstimateLineItemBreakdownList
        );
        for (EstimateEditClass breakdown : EstimateLineItemBreakdownList) {
          if (breakdown.ObjectName == 'ExtraCharges') {
            quantity = breakdown.Quantity;
            quantity = quantity.setScale(2);
            retailPrice = breakdown.retailPrice;
            retailPrice = retailPrice.setScale(2);
            Line lineItem1 = new Line();
            lineItem1.Amount = quantity * retailPrice;
            lineItem1.Description = breakdown.ProductName;
            lineItem1.DetailType = 'SalesItemLineDetail';
            lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
            lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
            lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
              retailPrice
            );
            lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
            if (breakdown.recordType == 'AdditionalCost_FixedCharge') {
              lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                  orderObj.id
                )
                .decorationServiceId;
            } else if (breakdown.recordType == 'AdditionalCost_RunCharge') {
              lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                  orderObj.id
                )
                .decorationServiceId;
            } else if (breakdown.recordType == 'InternationalCost_Brokerage') {
              lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                  orderObj.id
                )
                .fulfillmentServiceId;
            } else if (breakdown.recordType == 'InternationalCost_Duty') {
              lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                  orderObj.id
                )
                .fulfillmentServiceId;
            } else if (
              breakdown.recordType == 'InternationalCost_InboundFreight'
            ) {
              lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                  orderObj.id
                )
                .fulfillmentServiceId;
            }
            inv.Line.add(lineItem1);
          } else if (breakdown.ObjectName == 'Pricing') {
            quantity = breakdown.Quantity != null ? breakdown.Quantity : 0;
            quantity = quantity.setScale(2);
            retailPrice = breakdown.retailPrice != null
              ? breakdown.retailPrice
              : 0;
            retailPrice = retailPrice.setScale(2);
            Line lineItem1 = new Line();
            lineItem1.Amount = quantity * retailPrice;
            lineItem1.Description =
              sfLineItem.Name +
              breakdown.Color +
              breakdown.Size +
              '\nDescription: ' +
              (sfLineItem.Description__c == null
                ? ''
                : sfLineItem.Description__c);
            lineItem1.DetailType = 'SalesItemLineDetail';
            lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
            lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
            lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
              retailPrice
            );
            lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
            System.debug(
              '--QuickbookApiCrud--update invoice--qbo_product_service_id__c--' +
              sfLineItem.qbo_product_service_id__c
            );
            String itemRef = String.valueOf(
                sfLineItem.qbo_product_service_id__c
              ) != null
              ? String.valueOf(sfLineItem.qbo_product_service_id__c)
              : qboConfigs.get(orderObj.id).breakdownServiceId;
            //lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
            lineItem1.SalesItemLineDetail.ItemRef.value = itemRef;
            System.debug(
              '--QuickbookApiCrud--update invoice--itemRef--' + itemRef
            );
            inv.Line.add(lineItem1);
          }
        }
      }
    } else {
      Integer quantity = 0;
      Integer retailPrice = 0;
      Line lineItem1 = new Line();
      lineItem1.Amount = quantity * retailPrice;
      lineItem1.Description = 'Temp line item in case of 0 products in Salesforce';
      lineItem1.DetailType = 'SalesItemLineDetail';
      lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
      lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
      lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(retailPrice);
      lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(orderObj.id)
        .breakdownServiceId;
      inv.Line.add(lineItem1);
    }

    return inv;
  }

  private static HttpRequest buildHttpRequest(
    Invoice inv,
    Map<Id, QuicbooksConfiguration> qboConfigs,
    Order orderObj
  ) {
    String json = JSON.serialize(inv, true);
    HttpRequest request = new HttpRequest();
    request.setHeader(
      'Authorization',
      'Bearer ' + qboConfigs.get(orderObj.Id).accessToken
    );
    request.setHeader('Accept', 'application/json');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setBody(json);
    request.setMethod('POST');

    if (Test.isRunningTest()) {
      request.setEndPoint('http://test.com/test/sendInvoice');
    } else {
      request.setEndPoint(
        qboConfigs.get(orderObj.Id).qbApiEndPoint +
          '/v3/company/' +
          qboConfigs.get(orderObj.Id).realMId +
          '/invoice?minorversion=40&include=invoiceLink'
      );
    }

    return request;
  }

  private static HttpResponse sendHttpRequest(HttpRequest request) {
    HttpResponse response = new HttpResponse();
    Http http = new Http();
    response = http.send(request);

    return response;
  }

  private static void handleResponse(
    HttpResponse response,
    Order orderObj,
    Map<Id, String> accountNames,
    Map<Id, QuicbooksConfiguration> qboConfigs
  ) {
    if (response.getStatusCode() == 200) {
      Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
        response.getBody()
      );
      orderObj.QBId__c = (String) ((Map<String, Object>) results.get('Invoice'))
        .get('Id');
      orderObj.QBO_Invoice_Detail__c =
        accountNames.get(orderObj.Id) +
        '(' +
        ((Map<String, Object>) results.get('Invoice')).get('DocNumber') +
        ')';
      orderObj.Invoice_Number__c = (String) ((Map<String, Object>) results.get(
          'Invoice'
        ))
        .get('DocNumber');
      orderObj.Payment_Link__c = (String) ((Map<String, Object>) results.get(
          'Invoice'
        ))
        .get('InvoiceLink');
    } else if (response.getStatusCode() == 401) {
      authenticationErrorEmail(
        response,
        'Order# ' + orderObj.Id,
        'Create Invoice',
        accountNames.get(orderObj.Id)
      );
    } else {
      serverErrorEmails(
        response,
        orderObj.Name,
        'Order',
        accountNames.get(orderObj.Id),
        'Class QuickbookApiCrud , createInvoice',
        'Invoice',
        orderObj.Id
      );
    }
  }

  @future(callout=true)
  public static void createPurchaseOrder(
    Set<Id> orderIds,
    Map<Id, String> accountNames
  ) {
    List<PurchaseOrder_LineItem__c> ordersList = [
      SELECT
        Id,
        Delivery_Date_Time__c,
        WO_Status__c,
        Production_Rep__c,
        Name,
        Work_Order__r.AccountId,
        Shipping_Information__r.Ship_To__c,
        Shipping_Information__r.In_Hands_Date__c,
        Shipping_Information__r.supplier__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id IN :orderIds
    ];
    List<QB_Credentials__c> QBOCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c IN :accountNames.Values()
    ];
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c,
        Service_Id_Fulfillment__c,
        Service_Id_Decoration__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c IN :accountNames.Values()
    ];
    Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
    for (QB_Credentials__c QBOCred : QBOCredentials) {
      for (
        Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
      ) {
        if (
          accConfig.Quickbooks_Account_Tittle__c ==
          QBOCred.Synced_Account_Title__c
        ) {
          QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
            QBOCred,
            accConfig
          );
          for (Id key : accountNames.keySet()) {
            if (accountNames.get(key) == QBOCred.Synced_Account_Title__c) {
              qboConfigs.put(key, qboConfig);
            }
          }
        }
      }
    }
    Set<Id> supplierIds = new Set<Id>();
    List<OpportunityLineItem__c> oppoLineItemList = [
      SELECT
        Id,
        Account__c,
        PurchaseOrder_LineItem__c,
        Name,
        Work_Order__c,
        Description__c,
        Opportunity__c,
        Estimate__c,
        Quantity_Estimate__c,
        Total__c,
        Total_QBO__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :orderIds
      ORDER BY CreatedDate DESC
    ];

    List<Id> lineItemIds = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
      lineItemIds.add(oppLineItem.id);
      supplierIds.add(oppLineItem.Account__c);
    }
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Title__c,
        index__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :lineItemIds
      ORDER BY CreatedDate ASC
    ];
    List<PricingLineItem__c> pricingList = [
      SELECT
        Id,
        Net_Cost__c,
        Quantity__c,
        index__c,
        OpportunityLineItem__c,
        Color__c,
        Size__c,
        Retail_Price__c,
        Total__c,
        Estimated_Quantity__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :lineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
    Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
    for (OpportunityLineItem__c lineItem : oppoLineItemList) {
      List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
      for (PricingLineItem__c pricing : pricingList) {
        if (pricing.OpportunityLineItem__c == lineItem.Id) {
          pricings.add(pricing);
        }
      }
      if (pricings.size() > 0) {
        pricingMap.put(lineItem.Id, pricings);
      }
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        if (extraCharge.OpportunityLineItem__c == lineItem.Id) {
          extraChargesList.add(extraCharge);
        }
      }
      if (extraChargesList.size() > 0) {
        extraChargesMap.put(lineItem.Id, extraChargesList);
      }
    }
    Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
    for (PurchaseOrder_LineItem__c order : ordersList) {
      List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
      for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
        if (opplineItem.PurchaseOrder_LineItem__c == order.Id) {
          oppLineItemList.add(opplineItem);
        }
      }
      orderOpportunityLineItemMap.put(order.Id, oppLineItemList);
    }

    for (PurchaseOrder_LineItem__c poLineItem : ordersList) {
      supplierIds.add(poLineItem.Shipping_Information__r.supplier__c);
      supplierIds.add(poLineItem.Work_Order__r.AccountId);
    }
    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Account__r.Name,
        Account__r.Primary_Category__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c IN :supplierIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountNames.Values()
    ];
    for (PurchaseOrder_LineItem__c orderObj : ordersList) {
      Bill bill = new Bill();
      String expenseAccountRef = '';
      String customerAccName = '';
      String customerAccValue = '';
      bill.VendorRef = new VendorRef();
      if (qboDetailsList != null && qboDetailsList.size() > 0) {
        for (QBO_Details__c qboDetails : qboDetailsList) {
          if (
            qboDetails.Account__c ==
            orderObj.Shipping_Information__r.supplier__c
          ) {
            bill.VendorRef.name = qboDetails.Account__r.Name;
            bill.VendorRef.value = (String) qboDetails.QB_Id__c;
            System.debug(
              '--getVendorAccountExpenseId-primary-' +
              qboDetails.Account__r.Primary_Category__c
            );
            expenseAccountRef = getVendorAccountExpenseId(
              (String) qboDetails.Account__r.Primary_Category__c
            );
            System.debug(
              '--getVendorAccountExpenseId-expenseAccountRef-' +
              expenseAccountRef
            );
          }
          if (qboDetails.Account__c == orderObj.Work_Order__r.AccountId) {
            customerAccName = qboDetails.Account__r.Name;
            customerAccValue = (String) qboDetails.QB_Id__c;
          }
        }
      }
      bill.DueDate = string.valueof(orderObj.Delivery_Date_Time__c);
      bill.Line = new List<Line>();
      List<OpportunityLineItem__c> oppLineItemRelatedToOrder = orderOpportunityLineItemMap.get(
        orderObj.Id
      );
      if (oppLineItemRelatedToOrder.size() > 0) {
        for (OpportunityLineItem__c sfLineItem : oppLineItemRelatedToOrder) {
          String prodAccName = '';
          String prodAccValue = '';
          if (qboDetailsList != null && qboDetailsList.size() > 0) {
            for (QBO_Details__c qboDetails : qboDetailsList) {
              if (qboDetails.Account__c == sfLineItem.Account__c) {
                prodAccName = qboDetails.Account__r.Name;
                prodAccValue = (String) qboDetails.QB_Id__c;
              }
            }
          }
          List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
          List<ExtraChargesEstimate__c> extraChargeList = extraChargesMap.get(
            sfLineItem.Id
          );
          List<PricingLineItem__c> pricing = pricingMap.get(sfLineItem.Id);
          if (pricing != null && pricing.size() > 0) {
            for (PricingLineItem__c rec : pricing) {
              if (rec.OpportunityLineItem__c == sfLineItem.id) {
                EstimateEditClass estBreakdownObj = new EstimateEditClass();
                estBreakdownObj.Quantity = (rec.Estimated_Quantity__c == null)
                  ? 0
                  : rec.Estimated_Quantity__c;
                estBreakdownObj.CostPrice = (rec.Net_Cost__c == null)
                  ? 0
                  : rec.Net_Cost__c;
                estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
                estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
                estBreakdownObj.description =
                  '\nDescription : ' +
                  (sfLineItem.Description__c != null
                    ? sfLineItem.Description__c
                    : '');
                estBreakdownObj.ObjectName = 'Pricing';
                estBreakdownObj.index = Integer.valueOf(rec.index__c);
                EstimateLineItemBreakdownList.add(estBreakdownObj);
              }
            }
          }
          if (extraChargeList != null && extraChargeList.size() > 0) {
            for (ExtraChargesEstimate__c rec : extraChargeList) {
              if (rec.OpportunityLineItem__c == sfLineItem.id) {
                EstimateEditClass estBreakdownObj = new EstimateEditClass();
                estBreakdownObj.Quantity = (rec.Quantity__c == null)
                  ? 0
                  : rec.Quantity__c;
                estBreakdownObj.CostPrice = (rec.Net_Cost__c == null)
                  ? 0
                  : rec.Net_Cost__c;
                estBreakdownObj.ProductName =
                  sfLineItem.Name +
                  '\n' +
                  rec.Title__c;
                estBreakdownObj.ObjectName = 'ExtraCharges';
                estBreakdownObj.recordType = rec.Charge_Type__c;
                estBreakdownObj.index = Integer.valueOf(rec.index__c);
                EstimateLineItemBreakdownList.add(estBreakdownObj);
              }
            }
          }
          //extra Charges
          EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
            EstimateLineItemBreakdownList
          );
          for (EstimateEditClass breakdown : EstimateLineItemBreakdownList) {
            if (breakdown.ObjectName == 'ExtraCharges') {
              Line lineItem1 = new Line();
              lineItem1.Amount =
                (breakdown.Quantity != null ? breakdown.Quantity : 0) *
                (breakdown.CostPrice != null ? breakdown.CostPrice : 0);
              lineItem1.Description = breakdown.ProductName;
              lineItem1.DetailType = 'AccountBasedExpenseLineDetail';
              lineItem1.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetail();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef = new TaxCodeRef();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef.Value = 'TAX';
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef = new CustomerRef();
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.name = customerAccName;
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.value = customerAccValue;
              lineItem1.AccountBasedExpenseLineDetail.AccountRef = new AccountRef();
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.name = 'ob Expenses:Job Materials:Decks and Patios';
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.name = '';
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = expenseAccountRef !=
                null
                ? expenseAccountRef
                : '64';
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.name =   prodAccName;
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = prodAccValue;
              lineItem1.AccountBasedExpenseLineDetail.BillableStatus = 'NotBillable';
              bill.Line.add(lineItem1);
            } else if (breakdown.ObjectName == 'Pricing') {
              Line lineItem1 = new Line();
              lineItem1.Amount =
                (breakdown.Quantity != null ? breakdown.Quantity : 0) *
                (breakdown.CostPrice != null ? breakdown.CostPrice : 0);
              lineItem1.Description =
                sfLineItem.Name +
                breakdown.Color +
                breakdown.Size +
                breakdown.description;
              lineItem1.DetailType = 'AccountBasedExpenseLineDetail';
              lineItem1.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetail();
              // lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef = new TaxCodeRef();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef.Value = 'TAX';
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef = new CustomerRef();
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.name = customerAccName;
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.value = customerAccValue;
              lineItem1.AccountBasedExpenseLineDetail.AccountRef = new AccountRef();
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.name = 'ob Expenses:Job Materials:Decks and Patios';
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = expenseAccountRef !=
                null
                ? expenseAccountRef
                : '64';
              lineItem1.AccountBasedExpenseLineDetail.BillableStatus = 'NotBillable';
              bill.Line.add(lineItem1);
            }
          }
        }
      } else {
        System.debug('No Product Exist');
        return;
      }
      String json = JSON.serialize(bill, true);
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      if (
        qboConfigs != null &&
        qboConfigs.get(orderObj.id) != null &&
        qboConfigs.get(orderObj.id).accessToken != null
      )
        request.setHeader(
          'Authorization',
          'Bearer ' + qboConfigs.get(orderObj.id).accessToken
        );
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(json);
      request.setMethod('POST');
      if (Test.isRunningTest()) {
        request.setEndPoint('http://test.com/test/sendPurchaseOrder');
      } else {
        request.setEndPoint(
          qboConfigs.get(orderObj.id).qbApiEndPoint +
            '/v3/company/' +
            qboConfigs.get(orderObj.id).realMId +
            '/bill?minorversion=55'
        );
      }
      response = http.send(request);
      if (
        response.getStatusCode() == 200 && !(String.isEmpty(response.getBody()))
      ) {
        System.debug('response.getBody: ' + response.getBody());
        Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
          response.getBody()
        );
        orderObj.QBO_Bill__c = (String) ((Map<String, Object>) results.get(
            'Bill'
          ))
          .get('Id');
      } else if (response.getStatusCode() == 401) {
        authenticationErrorEmail(
          response,
          'Purchase Order# ' + orderIds.ToString(),
          'Create Bill',
          accountNames.get(orderObj.id)
        );
      } else {
        serverErrorEmails(
          response,
          orderObj.Name,
          'Purchase Order',
          accountNames.get(orderObj.id),
          'Class QuickbookApiCrud , createBill',
          'Bill',
          orderObj.Id
        );
      }
    }
    update ordersList;
  }

  /**
   * This function return the Purchase order Expense Account referenec based on vendor primary category
   * @param primaryCat
   * @return  `String`
   */
  public static String getVendorAccountExpenseId(String primaryCat) {
    String expenseAccount = '64';

    if (primaryCat == 'Apparel') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Apparel')
          .qbo_expense_account_id__c
      );
    } else if (primaryCat == 'Decorator') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Decorator')
          .qbo_expense_account_id__c
      );
    } else if (primaryCat == 'Promotional Products') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Promotional_Products')
          .qbo_expense_account_id__c
      );
    } else if (primaryCat == 'Trade Show & Signage') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Trade_Show_Signage')
          .qbo_expense_account_id__c
      );
    } else if (primaryCat == 'Design Services') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Design_Services')
          .qbo_expense_account_id__c
      );
    } else if (primaryCat == 'Fulfillment') {
      expenseAccount = String.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Fulfillment')
          .qbo_expense_account_id__c
      );
    }
    return expenseAccount;
  }

  @future(callout=true)
  public static void updatePurchaseOrder(
    Set<Id> orderIds,
    Map<Id, String> accountNames
  ) {
    List<PurchaseOrder_LineItem__c> ordersList = [
      SELECT
        Id,
        QBO_Bill__c,
        Delivery_Date_Time__c,
        WO_Status__c,
        Production_Rep__c,
        Name,
        Work_Order__r.AccountId,
        Shipping_Information__r.Ship_To__c,
        Shipping_Information__r.In_Hands_Date__c,
        Shipping_Information__r.supplier__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id IN :orderIds
    ];
    List<QB_Credentials__c> QBOCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c IN :accountNames.Values()
    ];
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c,
        Service_Id_Decoration__c,
        Service_Id_Fulfillment__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c IN :accountNames.Values()
    ];
    Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
    for (QB_Credentials__c QBOCred : QBOCredentials) {
      for (
        Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
      ) {
        if (
          accConfig.Quickbooks_Account_Tittle__c ==
          QBOCred.Synced_Account_Title__c
        ) {
          QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
            QBOCred,
            accConfig
          );
          for (Id key : accountNames.keySet()) {
            if (accountNames.get(key) == QBOCred.Synced_Account_Title__c) {
              qboConfigs.put(key, qboConfig);
            }
          }
        }
      }
    }
    Set<Id> supplierIds = new Set<Id>();
    List<OpportunityLineItem__c> oppoLineItemList = [
      SELECT
        Id,
        Account__c,
        PurchaseOrder_LineItem__c,
        Name,
        Work_Order__c,
        Description__c,
        Opportunity__c,
        Estimate__c,
        Quantity_Estimate__c,
        Total__c,
        Total_QBO__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :orderIds
      ORDER BY CreatedDate DESC
    ];

    List<Id> lineItemIds = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
      lineItemIds.add(oppLineItem.id);
      supplierIds.add(oppLineItem.Account__c);
    }
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Title__c,
        index__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :lineItemIds
      ORDER BY CreatedDate ASC
    ];
    List<PricingLineItem__c> pricingList = [
      SELECT
        Id,
        Net_Cost__c,
        Quantity__c,
        index__c,
        OpportunityLineItem__c,
        Color__c,
        Size__c,
        Retail_Price__c,
        Total__c,
        Estimated_Quantity__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :lineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
    Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
    for (OpportunityLineItem__c lineItem : oppoLineItemList) {
      List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
      for (PricingLineItem__c pricing : pricingList) {
        if (pricing.OpportunityLineItem__c == lineItem.Id) {
          pricings.add(pricing);
        }
      }
      if (pricings.size() > 0) {
        pricingMap.put(lineItem.Id, pricings);
      }
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        if (extraCharge.OpportunityLineItem__c == lineItem.Id) {
          extraChargesList.add(extraCharge);
        }
      }
      if (extraChargesList.size() > 0) {
        extraChargesMap.put(lineItem.Id, extraChargesList);
      }
    }
    Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
    Map<String, String> orderIdsForSyncToken = new Map<String, String>();
    for (PurchaseOrder_LineItem__c order : ordersList) {
      orderIdsForSyncToken.put(order.QBO_Bill__c, accountNames.get(order.id));
      List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
      for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
        if (opplineItem.PurchaseOrder_LineItem__c == order.Id) {
          oppLineItemList.add(opplineItem);
        }
      }
      orderOpportunityLineItemMap.put(order.Id, oppLineItemList);
    }

    for (PurchaseOrder_LineItem__c poLineItem : ordersList) {
      supplierIds.add(poLineItem.Shipping_Information__r.supplier__c);
      supplierIds.add(poLineItem.Work_Order__r.AccountId);
    }
    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Account__r.Name,
        Account__r.Primary_Category__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c IN :supplierIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountNames.Values()
    ];
    Map<String, String> orderSyncTokenMap = new Map<String, String>();
    orderSyncTokenMap = getSyncTokenMapForOrders(
      orderIdsForSyncToken,
      'Bill',
      QBOCredentials,
      accountConfiguration
    );
    for (PurchaseOrder_LineItem__c orderObj : ordersList) {
      Bill bill = new Bill();
      bill.Id = orderObj.QBO_Bill__c;
      bill.SyncToken = orderSyncTokenMap.get(orderObj.QBO_Bill__c);
      System.debug('SYNC TOKEN: ' + bill.syncToken);
      String expenseAccountRef = '';
      String customerAccName = '';
      String customerAccValue = '';
      bill.VendorRef = new VendorRef();
      if (qboDetailsList != null && qboDetailsList.size() > 0) {
        for (QBO_Details__c qboDetails : qboDetailsList) {
          if (
            qboDetails.Account__c ==
            orderObj.Shipping_Information__r.supplier__c
          ) {
            bill.VendorRef.name = qboDetails.Account__r.Name;
            bill.VendorRef.value = (String) qboDetails.QB_Id__c;
            System.debug(
              '--getVendorAccountExpenseId upadate-primary-' +
              qboDetails.Account__r.Primary_Category__c
            );
            expenseAccountRef = getVendorAccountExpenseId(
              (String) qboDetails.Account__r.Primary_Category__c
            );
            System.debug(
              '--getVendorAccountExpenseId-update---expenseAccountRef-' +
              expenseAccountRef
            );
          }
          if (qboDetails.Account__c == orderObj.Work_Order__r.AccountId) {
            customerAccName = qboDetails.Account__r.Name;
            customerAccValue = (String) qboDetails.QB_Id__c;
          }
        }
      }
      bill.DueDate = string.valueof(orderObj.Delivery_Date_Time__c);
      bill.Line = new List<Line>();
      List<OpportunityLineItem__c> oppLineItemRelatedToOrder = orderOpportunityLineItemMap.get(
        orderObj.Id
      );
      if (oppLineItemRelatedToOrder.size() > 0) {
        for (OpportunityLineItem__c sfLineItem : oppLineItemRelatedToOrder) {
          String prodAccName = '';
          String prodAccValue = '';
          if (qboDetailsList != null && qboDetailsList.size() > 0) {
            for (QBO_Details__c qboDetails : qboDetailsList) {
              if (qboDetails.Account__c == sfLineItem.Account__c) {
                prodAccName = qboDetails.Account__r.Name;
                prodAccValue = (String) qboDetails.QB_Id__c;
              }
            }
          }
          List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
          List<ExtraChargesEstimate__c> extraChargeList = extraChargesMap.get(
            sfLineItem.Id
          );
          List<PricingLineItem__c> pricing = pricingMap.get(sfLineItem.Id);
          if (pricing != null && pricing.size() > 0) {
            for (PricingLineItem__c rec : pricing) {
              if (rec.OpportunityLineItem__c == sfLineItem.id) {
                EstimateEditClass estBreakdownObj = new EstimateEditClass();
                Decimal estQty = (rec.Estimated_Quantity__c == null)
                  ? 0
                  : rec.Estimated_Quantity__c;
                estBreakdownObj.Quantity = estQty.setScale(2);
                Decimal netCost = (rec.Net_Cost__c == null)
                  ? 0
                  : rec.Net_Cost__c;
                estBreakdownObj.CostPrice = netCost.setScale(2);
                estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
                estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
                estBreakdownObj.description =
                  '\nDescription : ' +
                  (sfLineItem.Description__c != null
                    ? sfLineItem.Description__c
                    : '');
                estBreakdownObj.ObjectName = 'Pricing';
                estBreakdownObj.index = Integer.valueOf(rec.index__c);
                EstimateLineItemBreakdownList.add(estBreakdownObj);
              }
            }
          }
          if (extraChargeList != null && extraChargeList.size() > 0) {
            for (ExtraChargesEstimate__c rec : extraChargeList) {
              if (rec.OpportunityLineItem__c == sfLineItem.id) {
                EstimateEditClass estBreakdownObj = new EstimateEditClass();
                Decimal Qty = (rec.Quantity__c == null) ? 0 : rec.Quantity__c;
                estBreakdownObj.Quantity = Qty.setScale(2);
                Decimal netPrice = (rec.Net_Cost__c == null)
                  ? 0
                  : rec.Net_Cost__c;
                estBreakdownObj.CostPrice = netPrice.setScale(2);
                estBreakdownObj.ProductName =
                  sfLineItem.Name +
                  '\n' +
                  rec.Title__c;
                estBreakdownObj.ObjectName = 'ExtraCharges';
                estBreakdownObj.recordType = rec.Charge_Type__c;
                estBreakdownObj.index = Integer.valueOf(rec.index__c);
                EstimateLineItemBreakdownList.add(estBreakdownObj);
              }
            }
          }
          //extra Charges
          EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
            EstimateLineItemBreakdownList
          );
          for (EstimateEditClass breakdown : EstimateLineItemBreakdownList) {
            if (breakdown.ObjectName == 'ExtraCharges') {
              Line lineItem1 = new Line();
              Decimal lAmount =
                (breakdown.Quantity != null ? breakdown.Quantity : 0) *
                (breakdown.CostPrice != null ? breakdown.CostPrice : 0);
              lineItem1.Amount = lAmount.setScale(2);
              lineItem1.Description = breakdown.ProductName;
              lineItem1.DetailType = 'AccountBasedExpenseLineDetail';
              lineItem1.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetail();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef = new TaxCodeRef();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef.Value = 'TAX';
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef = new CustomerRef();
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.name = customerAccName;
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.value = customerAccValue;
              lineItem1.AccountBasedExpenseLineDetail.AccountRef = new AccountRef();
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.name = ''; //'ob Expenses:Job Materials:Decks and Patios';
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = expenseAccountRef !=
                null
                ? expenseAccountRef
                : '64';
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.name =   prodAccName;
              //lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = prodAccValue;
              lineItem1.AccountBasedExpenseLineDetail.BillableStatus = 'NotBillable';
              bill.Line.add(lineItem1);
            } else if (breakdown.ObjectName == 'Pricing') {
              Line lineItem1 = new Line();
              Decimal lAmount =
                (breakdown.Quantity != null ? breakdown.Quantity : 0) *
                (breakdown.CostPrice != null ? breakdown.CostPrice : 0);
              lineItem1.Amount = lAmount.setScale(2);
              lineItem1.Description =
                sfLineItem.Name +
                breakdown.Color +
                breakdown.Size +
                breakdown.description;
              lineItem1.DetailType = 'AccountBasedExpenseLineDetail';
              lineItem1.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetail();
              // lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef = new TaxCodeRef();
              //lineItem1.AccountBasedExpenseLineDetail.TaxCodeRef.Value = 'TAX';
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef = new CustomerRef();
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.name = customerAccName;
              lineItem1.AccountBasedExpenseLineDetail.CustomerRef.value = customerAccValue;
              lineItem1.AccountBasedExpenseLineDetail.AccountRef = new AccountRef();
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.name = ''; //'ob Expenses:Job Materials:Decks and Patios';
              lineItem1.AccountBasedExpenseLineDetail.AccountRef.value = expenseAccountRef !=
                null
                ? expenseAccountRef
                : '64';
              lineItem1.AccountBasedExpenseLineDetail.BillableStatus = 'NotBillable';
              bill.Line.add(lineItem1);
            }
          }
        }
      } else {
        System.debug('No Product Exist');
        return;
      }
      String json = JSON.serialize(bill, true);
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      request.setHeader(
        'Authorization',
        'Bearer ' + qboConfigs.get(orderObj.id).accessToken
      );
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(json);
      request.setMethod('POST');
      if (Test.isRunningTest()) {
        request.setEndPoint('http://test.com/test/sendInvoicce');
      } else {
        request.setEndPoint(
          qboConfigs.get(orderObj.id).qbApiEndPoint +
            '/v3/company/' +
            qboConfigs.get(orderObj.id).realMId +
            '/bill?minorversion=55'
        );
      }
      response = http.send(request);
      if (response.getStatusCode() == 200) {
        System.debug('Purchase Order has been updated');
      } else if (response.getStatusCode() == 401) {
        authenticationErrorEmail(
          response,
          'Purchase Order# ' + orderIds.ToString(),
          'Create Bill',
          accountNames.get(orderObj.id)
        );
      } else {
        serverErrorEmails(
          response,
          orderObj.Name,
          'Purchase Order',
          accountNames.get(orderObj.id),
          'Class QuickbookApiCrud , createBill',
          'Bill',
          orderObj.Id
        );
      }
    }
  }

  /**
   * @description to delete bill record in QBO once user delete purchase Order from Salesforce
   * @param poRecordToDeleteId PO Id to delete
   * @param qboBillId QBO Bill Id to delete
   * @param syncToken Bill sync token
   * @param poAccountMap QBO Configuration setting map
   */
  @future(callout=true)
  public static void deleteBillfromQBO(
    Id poRecordToDeleteId,
    String qboBillId,
    String syncToken,
    Map<Id, String> poAccountMap
  ) {
    try {
      List<QB_Credentials__c> QBOCredentials = getQBOCredentials(poAccountMap);
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = getAccountConfigurations(
        poAccountMap
      );
      Map<Id, QuicbooksConfiguration> qboConfigs = getQuicbooksConfigurations(
        QBOCredentials,
        accountConfiguration,
        poAccountMap
      );
      //json data prepartion for delete operation
      map<string, string> jsonBody = new Map<string, string>();
      jsonBody.put('SyncToken', syncToken);
      jsonBody.put('Id', qboBillId);
      String json = JSON.serialize(jsonBody);
      //http request to delete bill from QBO
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      if (
        qboConfigs != null &&
        qboConfigs.get(poRecordToDeleteId) != null &&
        qboConfigs.get(poRecordToDeleteId).accessToken != null
      ) {
        request.setHeader(
          'Authorization',
          'Bearer ' + qboConfigs.get(poRecordToDeleteId).accessToken
        );
      }
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(json);
      request.setMethod('POST');
      if (Test.isRunningTest()) {
        request.setEndPoint('http://test.com/test/deletePurchaseOrder');
      } else {
        request.setEndPoint(
          qboConfigs.get(poRecordToDeleteId).qbApiEndPoint +
            '/v3/company/' +
            qboConfigs.get(poRecordToDeleteId).realMId +
            '/bill?operation=delete&minorversion=65'
        );
      }
      response = http.send(request);
      if (response.getStatusCode() == 200) {
        System.debug('Bill has been Deleted');
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in deletion of Bill-->>>>>>' +
          Ex.getMessage() +
          '->>>>>' +
          Ex.getCause() +
          '--------->>>>>>>>' +
          Ex.getStackTraceString()
      );
    }
  }

  @future(callout=true)
  public static void updateInvoice(
    Set<Id> orderIds,
    Map<Id, String> accountNames
  ) {
    try {
      List<Order> ordersList = [
        SELECT
          Id,
          Name,
          QbId__c,
          OrderNumber,
          OpportunityId,
          AccountId,
          Invoice_Email__c,
          Order_Amount__c,
          Balance_Due__c,
          Balance_Due_Formula__c,
          Invoice_Date__c,
          Invoice_Number__c,
          Invoice_Due_Date__c,
          Invoice_Ship_Date__c,
          Invoice_Ship_Via__c,
          Quickbooks_Instance__c,
          Invoice_Terms__c,
          Created_From_QBO__c
        FROM Order
        WHERE Id = :orderIds
      ];

      if (ordersList != null || ordersList.size() > 0) {
        Set<String> accountNameIds = new Set<String>();
        for (Id key : accountNames.keySet()) {
          accountNameIds.add(accountNames.get(key));
        }
        List<QB_Credentials__c> QBOCredentials = [
          SELECT
            Id,
            Access_token__c,
            RealMId__c,
            Refresh_token__c,
            Synced_Account_Title__c
          FROM QB_Credentials__c
          WHERE Synced_Account_Title__c IN :accountNameIds
        ];

        List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
          SELECT
            Id,
            QBO_Custom_Field_1__c,
            QBO_Custom_Field_1_Id__c,
            QB_Access_token_End_Point__c,
            QB_API_End_Point__c,
            QB_Authorization_End_Point__c,
            QB_Authorization_Scope__c,
            QB_Client_Id__c,
            QB_Client_Secret__c,
            QB_ID__c,
            QB_Redirect_URI__c,
            QB_Timezone__c,
            Quickbooks_Account_Tittle__c,
            Service_Id_Breakdown__c,
            Service_Id_Brokerage__c,
            Service_Id_Duty__c,
            Service_Id_FixedCharges__c,
            Service_Id_InboundFreight__c,
            Service_Id_RunCharges__c,
            Service_Id_Decoration__c,
            Service_Id_Fulfillment__c
          FROM Quickbooks_Accounts_Configurations__c
          WHERE Quickbooks_Account_Tittle__c IN :accountNameIds
        ];

        Map<String, QB_Credentials__c> accToQBOCredential = new Map<String, QB_Credentials__c>();

        ////
        for (QB_Credentials__c qb : QBOCredentials) {
          if (qb.Synced_Account_Title__c == 'Team Phun') {
            accToQBOCredential.put('Team Phun', qb);
          } else if (qb.Synced_Account_Title__c == 'Team Phun') {
            accToQBOCredential.put('Team Phun', qb);
          }
        }
        /////

        Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
        for (QB_Credentials__c QBOCred : QBOCredentials) {
          for (
            Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
          ) {
            if (
              accConfig.Quickbooks_Account_Tittle__c ==
              QBOCred.Synced_Account_Title__c
            ) {
              QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
                QBOCred,
                accConfig
              );
              for (Id key : accountNames.keySet()) {
                if (accountNames.get(key) == QBOCred.Synced_Account_Title__c) {
                  qboConfigs.put(key, qboConfig);
                }
              }
            }
          }
        }
        List<OpportunityLineItem__c> oppoLineItemList = [
          SELECT
            Id,
            Name,
            Work_Order__c,
            Description__c,
            Opportunity__c,
            Estimate__c,
            Quantity_Estimate__c,
            Total__c,
            Total_QBO__c,
            Product__r.Name,
            Sorting_Date__c,
            qbo_product_service_id__c
          FROM OpportunityLineItem__c
          WHERE Work_Order__c = :orderIds
          ORDER BY Sorting_Date__c ASC
        ];
        List<Id> lineItemIds = new List<Id>();
        for (OpportunityLineItem__c oppLineItem : oppoLineItemList) {
          lineItemIds.add(oppLineItem.id);
        }
        List<ExtraChargesEstimate__c> extraCharges = [
          SELECT
            Id,
            Title__c,
            index__c,
            Quantity__c,
            Charge_Type__c,
            Margin__c,
            Retail_Price__c,
            Total__c,
            Display__c,
            Duty_Percentage__c,
            Is_Associated_With_Artwork__c,
            OpportunityLineItem__c,
            Default__c,
            Net_Cost__c
          FROM ExtraChargesEstimate__c
          WHERE OpportunityLineItem__c = :lineItemIds
          ORDER BY CreatedDate ASC
        ];
        List<PricingLineItem__c> pricingList = [
          SELECT
            Id,
            Quantity__c,
            index__c,
            OpportunityLineItem__c,
            Color__c,
            Size__c,
            Retail_Price__c,
            Total__c,
            Estimated_Quantity__c
          FROM PricingLineItem__c
          WHERE
            OpportunityLineItem__c IN :lineItemIds
            AND Display__c = TRUE
            AND Default__c = FALSE
          ORDER BY CreatedDate ASC
        ];
        Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
        Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
        for (OpportunityLineItem__c lineItem : oppoLineItemList) {
          List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
          List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
          for (PricingLineItem__c pricing : pricingList) {
            if (pricing.OpportunityLineItem__c == lineItem.Id) {
              pricings.add(pricing);
            }
          }
          if (pricings.size() > 0) {
            pricingMap.put(lineItem.Id, pricings);
          }
          for (ExtraChargesEstimate__c extraCharge : extraCharges) {
            if (extraCharge.OpportunityLineItem__c == lineItem.Id) {
              extraChargesList.add(extraCharge);
            }
          }
          if (extraChargesList.size() > 0) {
            extraChargesMap.put(lineItem.Id, extraChargesList);
          }
        }
        Map<Id, List<OpportunityLineItem__c>> orderOpportunityLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
        Map<String, String> orderIdsForSyncToken = new Map<String, String>();
        for (Order order : ordersList) {
          orderIdsForSyncToken.put(order.QbId__c, accountNames.get(order.id));
          List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
          for (OpportunityLineItem__c opplineItem : oppoLineItemList) {
            if (opplineItem.Work_Order__c == order.Id) {
              oppLineItemList.add(opplineItem);
            }
          }
          orderOpportunityLineItemMap.put(order.Id, oppLineItemList);
        }
        Map<String, String> orderSyncTokenMap = new Map<String, String>();

        orderSyncTokenMap = getSyncTokenMapForOrders(
          orderIdsForSyncToken,
          'Invoice',
          QBOCredentials,
          accountConfiguration
        );
        ///////////////
        Map<String, String> termRefs = new Map<String, String>();
        for (Sales_Term__c term : [
          SELECT Id, Id__c, Name, QBO_Account__c
          FROM Sales_Term__c
          WHERE QBO_Account__c IN :accountNames.values()
        ]) {
          termRefs.put(term.Name, term.Id__c);
        }
        Map<Id, String> customerRefMap = new Map<Id, Id>();
        List<QBO_Details__c> qboDetailsList = [
          SELECT
            Id,
            QB_Id__c,
            Account__c,
            Account__r.Name,
            Id_Type__c,
            Opportunity__c,
            QBO_Account__c,
            Salesforce_Record_Id__c
          FROM QBO_Details__c
          WHERE
            Account__c = :ordersList.get(0).AccountId
            AND id_Type__c = :'Account'
            AND QBO_Account__c IN :accountNameIds
        ];
        Map<Id, QBO_Details__c> qboDetailsMap = new Map<Id, QBO_Details__c>();
        for (QBO_Details__c qbDetail : qboDetailsList) {
          for (Id key : accountNames.keySet()) {
            if (qbDetail.QBO_Account__c == accountNames.get(key)) {
              qboDetailsMap.put(key, qbDetail);
            }
          }
        }
        for (Order orderObj : ordersList) {
          if (qboConfigs.get(orderObj.id) != null || Test.isRunningTest()) {
            ///////
            String txnId = orderObj.QbId__c;
            List<String> authorizationCredentials = new List<String>();

            authorizationCredentials.add(
              accToQBOCredential.get(orderObj.Quickbooks_Instance__c)
                .Access_token__c
            );
            authorizationCredentials.add(
              accToQBOCredential.get(orderObj.Quickbooks_Instance__c)
                .Refresh_token__c
            );
            authorizationCredentials.add(
              accToQBOCredential.get(orderObj.Quickbooks_Instance__c).realmid__c
            );

            String query = 'Select * from Invoice where Id = \'' + txnId + '\'';
            String invoices = QuickbookScheduler.QuickBookRecordGetter(
              query,
              authorizationCredentials,
              orderObj.Quickbooks_Instance__c
            );

            QuickbookApiCrud.InvoiceResponse results = (QuickbookApiCrud.InvoiceResponse) JSON.deserialize(
              invoices,
              QuickbookApiCrud.InvoiceResponse.class
            );
            List<QuickbookApiCrud.Invoice> invoice = results.QueryResponse.Invoice;
            List<QuickbookApiCrud.Line> line = invoice[0].Line;
            System.debug(line);

            ///////

            Invoice inv = new Invoice();
            inv.id = orderObj.QbId__c;
            inv.SyncToken = orderSyncTokenMap.get(orderObj.QbId__c);
            inv.CustomerRef = new CustomerRef();
            if (orderObj.Created_From_QBO__c == false) {
              inv.TotalAmt = orderObj.Order_Amount__c;
              inv.Balance = orderObj.Balance_Due_Formula__c;
            }
            inv.BillEmail = new billEmail();
            inv.BillEmail.Address = orderObj.Invoice_Email__c != null
              ? orderObj.Invoice_Email__c
              : null;
            inv.TxnDate = string.valueof(orderObj.Invoice_Date__c);
            inv.DueDate = string.valueof(orderObj.Invoice_Due_Date__c);
            inv.ShipDate = orderObj.Invoice_Ship_Date__c;
            inv.SalesTermRef = new SalesTermRef();
            inv.ShipMethodRef = new ShipMethodRef();
            inv.ShipMethodRef.value = orderObj.Invoice_Ship_Via__c;
            inv.SalesTermRef.value = termRefs.get(orderObj.Invoice_Terms__c) !=
              null
              ? termRefs.get(orderObj.Invoice_Terms__c)
              : '';
            inv.CustomField = new List<CustomField>();
            if (qboConfigs != null && qboConfigs.size() > 0)
              inv.CustomField.add(
                new CustomField(
                  qboConfigs.get(orderObj.id).qbCustomFieldId,
                  qboConfigs.get(orderObj.id).qbCustomField,
                  orderObj.OpportunityId
                )
              );

            inv.Line = new List<Line>();
            List<OpportunityLineItem__c> oppLineItemRelatedToOrderUnsorted = orderOpportunityLineItemMap.get(
              orderObj.Id
            );

            //New Sorting Logic Start
            List<OpportunityLineItem__c> oppLineItemRelatedToOrder = new List<OpportunityLineItem__c>();

            for (
              Integer i = 0; i < oppLineItemRelatedToOrderUnsorted.size(); i++
            ) {
              oppLineItemRelatedToOrder.add(
                oppLineItemRelatedToOrderUnsorted[i]
              );
              for (
                Integer j = oppLineItemRelatedToOrderUnsorted.size() - 1;
                j > i;
                j--
              ) {
                if (
                  oppLineItemRelatedToOrder[
                      oppLineItemRelatedToOrder.size() - 1
                    ]
                    .Product__r.Name ==
                  oppLineItemRelatedToOrderUnsorted[j].Product__r.Name
                ) {
                  oppLineItemRelatedToOrder.add(
                    oppLineItemRelatedToOrderUnsorted[j]
                  );
                  oppLineItemRelatedToOrderUnsorted.remove(j);
                }
              }
            }

            //New Sorting Logic End

            if (
              oppLineItemRelatedToOrder.size() > 0 &&
              orderObj.Created_From_QBO__c == false
            ) {
              for (
                OpportunityLineItem__c sfLineItem : oppLineItemRelatedToOrder
              ) {
                List<EstimateEditClass> EstimateLineItemBreakdownList = new List<EstimateEditClass>();
                List<ExtraChargesEstimate__c> extraChargeList = extraChargesMap.get(
                  sfLineItem.Id
                );
                List<PricingLineItem__c> pricing = pricingMap.get(
                  sfLineItem.Id
                );
                Decimal quantity = 0;
                Decimal total = 0;
                Decimal retailPrice = 0;
                Integer count = 1;
                if (pricing != null && pricing.size() > 0) {
                  for (PricingLineItem__c rec : pricing) {
                    if (rec.OpportunityLineItem__c == sfLineItem.id) {
                      EstimateEditClass estBreakdownObj = new EstimateEditClass();
                      Decimal estQty = (rec.Estimated_Quantity__c == null)
                        ? 0
                        : rec.Estimated_Quantity__c;
                      estBreakdownObj.Quantity = estQty.setScale(2);
                      Decimal rPrice = (rec.Retail_Price__c == null)
                        ? 0
                        : rec.Retail_Price__c;
                      estBreakdownObj.retailPrice = rPrice.setScale(2);
                      estBreakdownObj.Color = '\nColor : ' + rec.Color__c;
                      estBreakdownObj.Size = '\nSize : ' + rec.Size__c;
                      estBreakdownObj.ObjectName = 'Pricing';
                      estBreakdownObj.index = Integer.valueOf(rec.index__c);
                      EstimateLineItemBreakdownList.add(estBreakdownObj);
                    }
                  }
                }
                if (extraChargeList != null && extraChargeList.size() > 0) {
                  for (ExtraChargesEstimate__c rec : extraChargeList) {
                    if (rec.OpportunityLineItem__c == sfLineItem.id) {
                      EstimateEditClass estBreakdownObj = new EstimateEditClass();
                      Decimal Qty = (rec.Quantity__c == null)
                        ? 0
                        : rec.Quantity__c;
                      estBreakdownObj.Quantity = Qty.setScale(2);
                      Decimal rPrice = (rec.Retail_Price__c == null)
                        ? 0
                        : rec.Retail_Price__c;
                      estBreakdownObj.retailPrice = rPrice.setScale(2);
                      estBreakdownObj.ProductName =
                        sfLineItem.Name +
                        '\n' +
                        rec.Title__c;
                      estBreakdownObj.ObjectName = 'ExtraCharges';
                      estBreakdownObj.recordType = rec.Charge_Type__c;
                      estBreakdownObj.index = Integer.valueOf(rec.index__c);
                      EstimateLineItemBreakdownList.add(estBreakdownObj);
                    }
                  }
                }
                //extra Charges
                EstimateLineItemBreakdownList = EstimateOppLineItemController.sortList(
                  EstimateLineItemBreakdownList
                );
                for (
                  EstimateEditClass breakdown : EstimateLineItemBreakdownList
                ) {
                  if (breakdown.ObjectName == 'ExtraCharges') {
                    quantity = breakdown.Quantity;
                    quantity = quantity.setScale(2);
                    retailPrice = breakdown.retailPrice;
                    retailPrice = retailPrice.setScale(2);
                    Line lineItem1 = new Line();
                    lineItem1.Amount = quantity * retailPrice;
                    lineItem1.Description = breakdown.ProductName;
                    lineItem1.DetailType = 'SalesItemLineDetail';
                    lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                    lineItem1.SalesItemLineDetail.Qty = String.valueOf(
                      quantity
                    );
                    lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                      retailPrice
                    );
                    lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                    if (breakdown.recordType == 'AdditionalCost_FixedCharge') {
                      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                          orderObj.id
                        )
                        .decorationServiceId;
                    } else if (
                      breakdown.recordType == 'AdditionalCost_RunCharge'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                          orderObj.id
                        )
                        .decorationServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_Brokerage'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                          orderObj.id
                        )
                        .fulfillmentServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_Duty'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                          orderObj.id
                        )
                        .fulfillmentServiceId;
                    } else if (
                      breakdown.recordType == 'InternationalCost_InboundFreight'
                    ) {
                      lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                          orderObj.id
                        )
                        .fulfillmentServiceId;
                    }
                    inv.Line.add(lineItem1);
                  } else if (breakdown.ObjectName == 'Pricing') {
                    quantity = breakdown.Quantity;
                    quantity = quantity.setScale(2);
                    retailPrice = breakdown.retailPrice;
                    retailPrice = retailPrice.setScale(2);
                    Line lineItem1 = new Line();
                    //   lineItem1.Amount = total;
                    lineItem1.Amount = quantity * retailPrice;
                    lineItem1.Description =
                      sfLineItem.Name +
                      breakdown.Color +
                      breakdown.Size +
                      '\nDescription: ' +
                      (sfLineItem.Description__c == null
                        ? ''
                        : sfLineItem.Description__c);
                    lineItem1.DetailType = 'SalesItemLineDetail';
                    lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                    lineItem1.SalesItemLineDetail.Qty = String.valueOf(
                      quantity
                    );
                    lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(
                      retailPrice
                    );
                    lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                    System.debug(
                      '--QuickbookApiCrud--update invoice--qbo_product_service_id__c--' +
                      sfLineItem.qbo_product_service_id__c
                    );
                    String itemRef = String.valueOf(
                        sfLineItem.qbo_product_service_id__c
                      ) != null
                      ? String.valueOf(sfLineItem.qbo_product_service_id__c)
                      : qboConfigs.get(orderObj.id).breakdownServiceId;
                    //lineItem1.SalesItemLineDetail.ItemRef.value = quickbooksConfiguration.breakdownServiceId;
                    lineItem1.SalesItemLineDetail.ItemRef.value = itemRef;
                    System.debug(
                      '--QuickbookApiCrud--update invoice--itemRef--' + itemRef
                    );
                    inv.Line.add(lineItem1);
                  }
                }
              }
            } else {
              inv.line = line;
              /*
                            Integer quantity = 0;
                            Integer retailPrice = 0;
                            Line lineItem1 = new Line();
                            lineItem1.Amount = quantity*retailPrice;
                            lineItem1.Description = 'Temp line item in case of 0 products in Salesforce';
                            lineItem1.DetailType = 'SalesItemLineDetail';
                            lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
                            lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
                            lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(retailPrice);
                            lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
                            lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(orderObj.id).breakdownServiceId;
                            inv.Line.add(lineItem1);
                            */
            }
            inv.CustomerRef.name = qboDetailsMap.get(orderObj.id)
              .Account__r.Name;
            inv.CustomerRef.value = (String) qboDetailsMap.get(orderObj.id)
              .QB_Id__c;

            String json = JSON.serialize(inv, true);
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            request.setHeader(
              'Authorization',
              'Bearer ' + qboConfigs.get(orderObj.id).accessToken
            );
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(json);
            request.setMethod('POST');
            if (Test.isRunningTest()) {
              request.setEndPoint('http://test.com/test/sendInvoicce');
            } else {
              request.setEndPoint(
                qboConfigs.get(orderObj.id).qbApiEndPoint +
                  '/v3/company/' +
                  qboConfigs.get(orderObj.id).realMId +
                  '/invoice?minorversion=55&include=invoiceLink'
              );
            }
            response = http.send(request);
            if (response.getStatusCode() == 200) {
              System.debug('INVOICE UPDATED');
              OrderTriggerService.markInvoicesPaid(ordersList);
            } else if (response.getStatusCode() == 401) {
              authenticationErrorEmail(
                response,
                'Order# ' + orderIds,
                'Update Invoice',
                accountNames.get(orderObj.id)
              );
            } else {
              serverErrorEmails(
                response,
                orderObj.OrderNumber,
                'Order',
                accountNames.get(orderObj.id),
                'Class QuickbookApiCrud , UpdateInvoice',
                'Invoice',
                orderObj.Id
              );
            }
          } else {
            authenticationErrorEmail(
              orderIds.toString(),
              'Update Invoice',
              accountNames.get(orderObj.id)
            );
          }
        }
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in update Invoice-->>>>>>' +
          Ex.getMessage() +
          '->>>>>' +
          Ex.getCause() +
          '--------->>>>>>>>' +
          Ex.getStackTraceString()
      );
    }
  }

  public static Map<String, Id> getAccountQBDetailOIdMap(
    String account,
    String accountTitle
  ) {
    Map<String, Id> mapToReturn = new Map<String, Id>();

    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c = :account
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountTitle
    ];

    for (QBO_Details__c qboRecord : qboDetailsList) {
      mapToReturn.put(qboRecord.Account__c, qboRecord.QB_Id__c);
    }
    return mapToReturn;
  }
  public static Map<Id, Boolean> getQBODetailsExistsMap(
    Set<Id> estimateIds,
    String accountTitle
  ) {
    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Salesforce_Record_Id__c = :estimateIds
        AND id_Type__c = :'Estimate'
        AND QBO_Account__c = :accountTitle
    ];
    Map<Id, Boolean> mapToReturn = new Map<Id, Boolean>();

    for (QBO_Details__c qbo : qboDetailsList) {
      mapToReturn.put(qbo.Salesforce_Record_Id__c, true);
    }
    return mapToReturn;
  }
  public static QuicbooksConfiguration getQuicbooksConfigurationForInvoice(
    QB_Credentials__c qbCredentials,
    Quickbooks_Accounts_Configurations__c accountConfiguration
  ) {
    QuicbooksConfiguration config = new QuicbooksConfiguration();
    if (qbCredentials != null) {
      config.accessToken = qbCredentials.Access_token__c;
      config.realMId = qbCredentials.RealMId__c;
      config.refreshToken = qbCredentials.Refresh_token__c;
      config.syncedAccountTittle = qbCredentials.Synced_Account_Title__c;
      config.qbCredentialsId = qbCredentials.Id;
    }
    if (accountConfiguration != null) {
      config.breakdownServiceId = accountConfiguration.Service_Id_Breakdown__c;
      config.brokerageServiceId = accountConfiguration.Service_Id_Brokerage__c;
      config.dutyServiceId = accountConfiguration.Service_Id_Duty__c;
      config.fixedChargesServiceId = accountConfiguration.Service_Id_FixedCharges__c;
      config.inboundServiceId = accountConfiguration.Service_Id_InboundFreight__c;
      config.runChargeServiceId = accountConfiguration.Service_Id_RunCharges__c;
      config.decorationServiceId = accountConfiguration.Service_Id_Decoration__c;
      config.fulfillmentServiceId = accountConfiguration.Service_Id_Fulfillment__c;

      config.qbCustomField = accountConfiguration.QBO_Custom_Field_1__c;
      config.qbCustomFieldId = accountConfiguration.QBO_Custom_Field_1_Id__c;
      config.qbAccessTokeEndPoint = accountConfiguration.QB_Access_token_End_Point__c;
      config.qbApiEndPoint = accountConfiguration.QB_API_End_Point__c;
      config.qbAuthorizationEndPoint = accountConfiguration.QB_Authorization_End_Point__c;
      config.qbAuthorizationScope = accountConfiguration.QB_Authorization_Scope__c;
      config.qbClientId = accountConfiguration.QB_Client_Id__c;
      config.qbClientSecret = accountConfiguration.QB_Client_Secret__c;
      config.qbId = accountConfiguration.QB_ID__c;
      config.qbRedirectURI = accountConfiguration.QB_Redirect_URI__c;
      config.qbTimeZone = accountConfiguration.QB_Timezone__c;
      config.quickbooksAccountTittle = accountConfiguration.Quickbooks_Account_Tittle__c;
    }

    return config;
  }
  public static QuicbooksConfiguration getQuicbooksConfiguration(
    String accountName
  ) {
    List<QB_Credentials__c> qbCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c = :accountName
    ];

    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c,
        Service_Id_Decoration__c,
        Service_Id_Fulfillment__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c = :accountName
    ];
    QuicbooksConfiguration config = new QuicbooksConfiguration();
    if (qbCredentials != null && qbCredentials.size() > 0) {
      config.accessToken = qbCredentials[0].Access_token__c;
      config.realMId = qbCredentials[0].RealMId__c;
      config.refreshToken = qbCredentials[0].Refresh_token__c;
      config.syncedAccountTittle = qbCredentials[0].Synced_Account_Title__c;
      config.qbCredentialsId = qbCredentials[0].Id;
    }
    if (accountConfiguration != null && accountConfiguration.size() > 0) {
      config.breakdownServiceId = accountConfiguration[0]
        .Service_Id_Breakdown__c;
      config.brokerageServiceId = accountConfiguration[0]
        .Service_Id_Brokerage__c;
      config.dutyServiceId = accountConfiguration[0].Service_Id_Duty__c;
      config.fixedChargesServiceId = accountConfiguration[0]
        .Service_Id_FixedCharges__c;
      config.inboundServiceId = accountConfiguration[0]
        .Service_Id_InboundFreight__c;
      config.runChargeServiceId = accountConfiguration[0]
        .Service_Id_RunCharges__c;
      config.decorationServiceId = accountConfiguration[0]
        .Service_Id_Decoration__c;
      config.fulfillmentServiceId = accountConfiguration[0]
        .Service_Id_Fulfillment__c;

      config.qbCustomField = accountConfiguration[0].QBO_Custom_Field_1__c;
      config.qbCustomFieldId = accountConfiguration[0].QBO_Custom_Field_1_Id__c;
      config.qbAccessTokeEndPoint = accountConfiguration[0]
        .QB_Access_token_End_Point__c;
      config.qbApiEndPoint = accountConfiguration[0].QB_API_End_Point__c;
      config.qbAuthorizationEndPoint = accountConfiguration[0]
        .QB_Authorization_End_Point__c;
      config.qbAuthorizationScope = accountConfiguration[0]
        .QB_Authorization_Scope__c;
      config.qbClientId = accountConfiguration[0].QB_Client_Id__c;
      config.qbClientSecret = accountConfiguration[0].QB_Client_Secret__c;
      config.qbId = accountConfiguration[0].QB_ID__c;
      config.qbRedirectURI = accountConfiguration[0].QB_Redirect_URI__c;
      config.qbTimeZone = accountConfiguration[0].QB_Timezone__c;
      config.quickbooksAccountTittle = accountConfiguration[0]
        .Quickbooks_Account_Tittle__c;
    }

    return config;
  }

  public static Map<Id, QBO_Details__c> getAccountQBOIdMap(
    Set<Id> accountIds,
    String accountTitle
  ) {
    Map<Id, QBO_Details__c> mapToReturn = new Map<Id, QBO_Details__c>();
    List<Account> accountList = [
      SELECT Id
      FROM Account
      WHERE Id = :accountIds
    ];

    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Account__c = :accountIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountTitle
    ];
    for (Account acc : accountList) {
      for (QBO_Details__c qboRecord : qboDetailsList) {
        if (
          (qboRecord.Account__c == acc.Id) &&
          (qboRecord.Salesforce_Record_Id__c == acc.Id)
        ) {
          mapToReturn.put(acc.Id, qboRecord);
        }
      }
    }
    return mapToReturn;
  }

  @future(callout=true)
  public static void syncVendor(Set<Id> accIds, String accountTitle) {
    String accountDetails = '';
    String recordId = '';
    String recordName = '';
    try {
      List<QB_Credentials__c> qbcList = [
        SELECT
          Id,
          Access_token__c,
          Refresh_token__c,
          realmid__c,
          Synced_Account_Title__c
        FROM QB_Credentials__c
        WHERE Synced_Account_Title__c = :accountTitle
        ORDER BY LastModifiedDate DESC
      ];
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
        SELECT
          Id,
          QBO_Custom_Field_1__c,
          QBO_Custom_Field_1_Id__c,
          QB_Access_token_End_Point__c,
          QB_API_End_Point__c,
          QB_Authorization_End_Point__c,
          QB_Authorization_Scope__c,
          QB_Client_Id__c,
          QB_Client_Secret__c,
          QB_ID__c,
          QB_Redirect_URI__c,
          QB_Timezone__c,
          Quickbooks_Account_Tittle__c,
          Service_Id_Breakdown__c,
          Service_Id_Brokerage__c,
          Service_Id_Duty__c,
          Service_Id_FixedCharges__c,
          Service_Id_InboundFreight__c,
          Service_Id_RunCharges__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :accountTitle
      ];
      Map<Id, QBO_Details__c> accountQBOIdMap = getAccountQBOIdMap(
        accIds,
        accountTitle
      );

      if (qbcList.size() > 0) {
        List<QBO_Details__c> qboDetailsToUpdate = new List<QBO_Details__c>();
        List<Account> toUpdateAccounts = new List<Account>();
        List<Account> accList = Database.query(
          'SELECT ' +
            String.join(
              new List<String>(
                Schema.getGlobalDescribe()
                  .get('Account')
                  .getDescribe()
                  .fields.getMap()
                  .keySet()
              ),
              ','
            ) +
            ',Billing_Contact__r.FirstName, Billing_Contact__r.LastName, Billing_Contact__r.MobilePhone, Billing_Contact__r.Phone FROM Account where id in :accIDs'
        );
        List<String> customerIds = new List<String>();
        for (Account acc : accList) {
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
          }
          accountDetails += accountDetails + acc.Name + ' (' + acc.Id + ')  ,';
          customerIds.add(String.valueOf(qboDetails.QB_Id__c));
        }

        List<String> authorizationCredentials = new List<String>();
        authorizationCredentials.add(qbcList[0].Access_token__c);
        authorizationCredentials.add(qbcList[0].Refresh_token__c);
        authorizationCredentials.add(qbcList[0].realmid__c);
        Map<String, String> syncTokenMap = new Map<String, String>();
        syncTokenMap = getSyncToken(
          'Vendor',
          customerIds,
          authorizationCredentials,
          accountTitle
        );
        system.debug('syncTokenMap--->>>>' + syncTokenMap);
        /////
        /* String accNames = '';
                for(Account acc:accList)
                {
                accNames = accNames + '\''+acc.Name+'\'';
                if(acc.id != accList.get(accList.size()-1).id)
                accNames = ',';
                }
                System.debug('Names: '+accNames);

                String query = 'select Id from vendor Where DisplayName IN ('+accNames+')';
                System.debug('query: '+query);
                String users = QuickbookScheduler.QuickBookRecordGetter(query, authorizationCredentials,accountTitle);
                AccountResponse accountResponse = (AccountResponse)System.JSON.deserialize(users,AccountResponse.Class);
                Map<Id, Id> accQBOIds = new Map<Id,Id>();
                if(  accountResponse.QueryResponse != null && accountResponse.QueryResponse.vendor != null)
                {
                for(Account acc:accList)
                {
                for(VendorAccountResponse vendor: accountResponse.QueryResponse.vendor)
                {
                if(acc.Name == vendor.DisplayName)
                {
                accQBOIds.put(acc.id, vendor.Id);
                }
                }
                }
                }
                System.debug('accQBOIds: '+accQBOIds)*/
        ////////
        for (Account acc : accList) {
          recordId = acc.Id;
          recordName = acc.Name;
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
          }
          system.debug(qboDetails.QB_Id__c);
          system.debug(syncTokenMap.get(String.valueOf(qboDetails.QB_Id__c)));
          String json = getAccountJson(
            acc,
            'Vendor',
            qboDetails.QB_Id__c,
            syncTokenMap.get(String.valueOf(qboDetails.QB_Id__c)),
            accountTitle
          );
          HttpRequest request = new HttpRequest();
          HttpResponse response = new HttpResponse();
          Http http = new Http();
          request.setMethod('POST');
          if (Test.isRunningTest()) {
            request.setEndpoint('http://test.com/test/sendVendor');
          } else {
            request.setEndPoint(
              accountConfiguration[0].QB_API_End_Point__c +
                '/v3/company/' +
                qbcList[0].realmid__c +
                '/vendor'
            );
          }

          request.setHeader(
            'Authorization',
            'Bearer ' + qbcList[0].Access_token__c
          );
          request.setHeader('Accept', 'application/json');
          request.setHeader('Content-Type', 'application/json;charset=UTF-8');
          request.setBody(json);
          response = http.send(request);
          if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
              response.getBody()
            );
            if (qboDetails.QB_Id__c == null) {
              qboDetails.QB_Id__c = (String) ((Map<String, Object>) results.get(
                  'Vendor'
                ))
                .get('Id');
              system.debug(qboDetails.QB_Id__c);
              qboDetails.Name =
                'Account - ' +
                qboDetails.QB_Id__c +
                ' (' +
                accountTitle +
                ')';
              qboDetails.Account__c = acc.id;
              qboDetails.Id_Type__c = 'Account';
              qboDetails.Salesforce_Record_Id__c = acc.id;
              qboDetails.QBO_Account__c = accountTitle;
              toUpdateAccounts.add(acc);
              qboDetailsToUpdate.add(qboDetails);
            }
          } else if (response.getStatusCode() == 401) {
            authenticationErrorEmail(
              response,
              accountDetails,
              'Vendor Accounts',
              accountTitle
            );
          } else {
            DuplicateAccountResponse returnedResponse = isDuplicateAccountError(
              response,
              acc,
              accountTitle,
              authorizationCredentials,
              'Vendor'
            );
            if (
              returnedResponse != null &&
              returnedResponse.qboDetails != null
            ) {
              qboDetailsToUpdate.add(returnedResponse.qboDetails);
              if (!toUpdateAccounts.contains(acc))
                toUpdateAccounts.add(acc);
            } else if (
              returnedResponse != null &&
              returnedResponse.isDuplicateEntityExist != null &&
              returnedResponse.isDuplicateEntityExist == true
            ) {
              acc.Duplicate_Exists__c = true;
              toUpdateAccounts.add(acc);
            } else {
              serverErrorEmails(
                response,
                acc.Name,
                'Account',
                accountTitle,
                'Class QuickbookApiCrud , syncVendor ',
                'Account',
                acc.Id
              );
            }
          }
        }
        if (qboDetailsToUpdate.size() > 0) {
          upsert qboDetailsToUpdate;
        }
        if (toUpdateAccounts.size() > 0) {
          update toUpdateAccounts;
        }
      }
    } catch (Exception ex) {
      System.debug(ex);

      String subjectEmail =
        'IMPORTANT | QBO | Error while Syncing Vendor Account at "' +
        System.now() +
        '"';
      String body =
        'Exception <br/>' +
        '<br/><br/>' +
        '<h2>Message(s):</h2>' +
        '<ul>' +
        ' <li>' +
        accountTitle +
        '</li>' +
        ' <ul>' +
        '<li>' +
        ex.getStackTraceString() +
        ' on line number' +
        ex.getLineNumber() +
        '</li>' +
        '</ul>' +
        '</ul>' +
        ' <h2>Record(s):</h2>' +
        '<ul>' +
        '<li>' +
        '<a href ="' +
        Label.default_url +
        recordId +
        '">' +
        recordName +
        '</a>' +
        ' </li>' +
        '</ul>';

      sendEmail(subjectEmail, body);
    }
  }
  @future(callout=true)
  public static void syncCustomer(Set<Id> accIds, String accountTitle) {
    String accountDetails = '';
    String recordId = '';
    String recordName = '';
    try {
      List<QB_Credentials__c> qbcList = [
        SELECT
          Id,
          Access_token__c,
          Refresh_token__c,
          realmid__c,
          Synced_Account_Title__c
        FROM QB_Credentials__c
        WHERE Synced_Account_Title__c = :accountTitle
        ORDER BY LastModifiedDate DESC
      ];
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
        SELECT
          Id,
          QBO_Custom_Field_1__c,
          QBO_Custom_Field_1_Id__c,
          QB_Access_token_End_Point__c,
          QB_API_End_Point__c,
          QB_Authorization_End_Point__c,
          QB_Authorization_Scope__c,
          QB_Client_Id__c,
          QB_Client_Secret__c,
          QB_ID__c,
          QB_Redirect_URI__c,
          QB_Timezone__c,
          Quickbooks_Account_Tittle__c,
          Service_Id_Breakdown__c,
          Service_Id_Brokerage__c,
          Service_Id_Duty__c,
          Service_Id_FixedCharges__c,
          Service_Id_InboundFreight__c,
          Service_Id_RunCharges__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :accountTitle
      ];
      Map<Id, QBO_Details__c> accountQBOIdMap = getAccountQBOIdMap(
        accIds,
        accountTitle
      );

      if (qbcList.size() > 0) {
        List<Account> toUpdateAccounts = new List<Account>();
        List<QBO_Details__c> qboDetailsToUpdate = new List<QBO_Details__c>();
        List<Account> accList = Database.query(
          'SELECT ' +
            String.join(
              new List<String>(
                Schema.getGlobalDescribe()
                  .get('Account')
                  .getDescribe()
                  .fields.getMap()
                  .keySet()
              ),
              ','
            ) +
            '  FROM Account where id in :accIDs'
        );
        List<String> customerIds = new List<String>();
        for (Account acc : accList) {
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
          }
          accountDetails += accountDetails + acc.Name + ' (' + acc.Id + ')  ,';
          customerIds.add(String.valueOf(qboDetails.QB_Id__c));
        }
        List<String> authorizationCredentials = new List<String>();
        authorizationCredentials.add(qbcList[0].Access_token__c);
        authorizationCredentials.add(qbcList[0].Refresh_token__c);
        authorizationCredentials.add(qbcList[0].realmid__c);

        Map<String, String> syncTokenMap = getSyncToken(
          'Customer',
          customerIds,
          authorizationCredentials,
          accountTitle
        );
        for (Account acc : accList) {
          recordId = acc.Id;
          recordName = acc.Name;
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
          }
          String json = getAccountJson(
            acc,
            'Customer',
            qboDetails.QB_Id__c,
            syncTokenMap.get(String.valueOf(qboDetails.QB_Id__c)),
            accountTitle
          );
          //                    sendEmail('JSON',json);
          HttpRequest request = new HttpRequest();
          HttpResponse response = new HttpResponse();
          Http http = new Http();
          request.setMethod('POST');
          if (Test.isRunningTest()) {
            request.setEndpoint('http://test.com/test/sendCustomer');
          } else {
            request.setEndPoint(
              accountConfiguration[0].QB_API_End_Point__c +
                '/v3/company/' +
                qbcList[0].realmid__c +
                '/customer'
            );
          }

          request.setHeader(
            'Authorization',
            'Bearer ' + qbcList[0].Access_token__c
          );
          request.setHeader('Accept', 'application/json');
          request.setHeader('Content-Type', 'application/json;charset=UTF-8');
          request.setBody(json);
          response = http.send(request);
          if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
              response.getBody()
            );
            if (qboDetails.QB_Id__c == null) {
              qboDetails.QB_Id__c = (String) ((Map<String, Object>) results.get(
                  'Customer'
                ))
                .get('Id');
              qboDetails.Name =
                'Account - ' +
                qboDetails.QB_Id__c +
                ' (' +
                accountTitle +
                ')';
              qboDetails.Account__c = acc.id;
              qboDetails.Id_Type__c = 'Account';
              qboDetails.Salesforce_Record_Id__c = acc.id;
              qboDetails.QBO_Account__c = accountTitle;
              toUpdateAccounts.add(acc);
              qboDetailsToUpdate.add(qboDetails);
            }
          } else if (response.getStatusCode() == 401) {
            authenticationErrorEmail(
              response,
              accountDetails,
              'Accounts',
              accountTitle
            );
          } else {
            DuplicateAccountResponse returnedResponse = QuickbookApiCrud.isDuplicateAccountError(
              response,
              acc,
              accountTitle,
              authorizationCredentials,
              'Customer'
            );

            if (
              returnedResponse != null &&
              returnedResponse.qboDetails != null
            ) {
              qboDetailsToUpdate.add(returnedResponse.qboDetails);
            } else if (
              returnedResponse != null &&
              returnedResponse.isDuplicateEntityExist != null &&
              returnedResponse.isDuplicateEntityExist == true
            ) {
              acc.Duplicate_Exists__c = true;
              toUpdateAccounts.add(acc);
            } else {
              serverErrorEmails(
                response,
                acc.Name,
                'Account',
                accountTitle,
                'Class QuickbookApiCrud , syncCustomer ',
                'Account',
                acc.Id
              );
            }
          }
        }
        if (toUpdateAccounts.size() > 0) {
          update toUpdateAccounts;
          upsert qboDetailsToUpdate;
        }
      }
    } catch (Exception ex) {
      String subjectEmail =
        'IMPORTANT | QBO (' +
        accountTitle +
        ') | Error while Syncing Account at "' +
        System.now() +
        '"';
      String body =
        'Exception <br/>' +
        '<br/><br/>' +
        '<h2>Message(s):</h2>' +
        '<ul>' +
        ' <li>' +
        accountTitle +
        '</li>' +
        ' <ul>' +
        '<li>' +
        ex.getStackTraceString() +
        ' on line number' +
        ex.getLineNumber() +
        '</li>' +
        '</ul>' +
        '</ul>' +
        ' <h2>Record(s):</h2>' +
        '<ul>' +
        '<li>' +
        '<a href ="' +
        Label.default_url +
        recordId +
        '">' +
        recordName +
        '</a>' +
        ' </li>' +
        '</ul>';

      sendEmail(subjectEmail, body);
    }
  }
  public static DuplicateAccountResponse isDuplicateAccountError(
    HttpResponse response,
    Account acc,
    String accountTitle,
    List<String> authorizationCredentials,
    String accountType
  ) {
    DuplicateAccountResponse responseToReturn = new DuplicateAccountResponse();
    if (
      response.getStatusCode() == 400 &&
      response.getBody().contains('Duplicate Name Exists Error')
    ) {
      String query = '';
      String QBId = '';
      if (accountType == 'Customer') {
        query =
          'select Id from Customer Where DisplayName = \'' +
          acc.Name +
          '\'';
      } else {
        query =
          'select Id from vendor Where DisplayName = \'' +
          acc.Name +
          '\'';
      }

      String users = QuickbookScheduler.QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      system.debug('Users returned From QBO in ApiCrud --->>>>>>' + users);
      AccountResponse accountResponse = (AccountResponse) System.JSON.deserialize(
        users,
        AccountResponse.class
      );
      system.debug('Json after parsing into class-------->>' + accountResponse);

      if (
        accountType == 'Customer' &&
        accountResponse != null &&
        accountResponse.QueryResponse != null &&
        accountResponse.QueryResponse.customer != null
      ) {
        system.debug('Account Type======>>>>>>>' + accountType);
        system.debug(
          'returned customer Id ---------->>>>>>>>' +
          accountResponse.QueryResponse.customer[0].Id
        );
        QBId = accountResponse.QueryResponse.customer[0].Id;
      } else if (
        accountResponse.QueryResponse != null &&
        accountResponse.QueryResponse.vendor != null
      ) {
        system.debug('Account Type======>>>>>>>' + accountType);
        system.debug(
          'returned Vendor Id ---------->>>>>>>>' +
          accountResponse.QueryResponse.vendor[0].Id
        );
        QBId = accountResponse.QueryResponse.vendor[0].Id;
      }

      if (QBId != null && QBId != '') {
        QBO_Details__c qboDetails = new QBO_Details__c();
        qboDetails.QB_Id__c = QBId;
        qboDetails.Name =
          'Account - ' +
          qboDetails.QB_Id__c +
          ' (' +
          accountTitle +
          ')';
        qboDetails.Account__c = acc.id;
        qboDetails.Id_Type__c = 'Account';
        qboDetails.Salesforce_Record_Id__c = acc.id;
        qboDetails.QBO_Account__c = accountTitle;
        responseToReturn.qboDetails = qboDetails;
      } else {
        responseToReturn.isDuplicateEntityExist = true;
        String subjectEmail =
          '( 400 ) IMPORTANT | QBO(' +
          accountTitle +
          ') | Error in Syncing at "' +
          System.now() +
          '"';
        String body =
          'Response <br/>' +
          ' Another entity with same name already exists in QBO. Kindly update account name and try again' +
          ' Error On ' +
          'Account title' +
          ' <br/> ' +
          accountTitle +
          '(' +
          acc.Id +
          ')' +
          '<br/><br/>' +
          '<h2>Message(s):</h2>' +
          '<ul>' +
          ' <li>' +
          accountTitle +
          '</li>' +
          ' <ul>' +
          '<li>Error occurred while syncing of account.Another entity with same name already exists in QBO</li>' +
          '</ul>' +
          '</ul>' +
          ' <h2>Record(s):</h2>' +
          '<ul>' +
          '<li>' +
          '<a href ="' +
          Label.default_url +
          acc.Id +
          '">' +
          acc.Name +
          '</a>' +
          ' </li>' +
          '</ul>';
        sendEmail(subjectEmail, body);
      }
      return responseToReturn;
    }
    return responseToReturn;
  }
  public static void authenticationErrorEmail(
    HttpResponse response,
    String recordDetails,
    String objectName,
    String instanceName
  ) {
    if (recordDetails.length() > 0) {
      recordDetails = recordDetails.removeEnd(',');
    }
    String subjectEmail =
      '( ' +
      response.getStatusCode() +
      ' ) IMPORTANT | QBO (' +
      instanceName +
      ') | Authentication failed at "' +
      System.now() +
      '"';
    String body =
      '<h2>Authorization Failed.</h2><br/>' +
      '<br/><br/>Click to authenticate <a href="' +
      Label.default_url +
      'lightning/n/Quickbook_Authentication">Authenticate Now.</a>' +
      '<br/><br/>Error On ' +
      objectName +
      ' <br/> ' +
      recordDetails;
    sendEmail(subjectEmail, body);
    sendEmailAuthenticationClient(subjectEmail, body);
  }

  public static void authenticationErrorEmail(
    String recordDetails,
    String objectName,
    String instanceName
  ) {
    if (recordDetails.length() > 0) {
      recordDetails = recordDetails.removeEnd(',');
    }
    String subjectEmail =
      'IMPORTANT | QBO (' +
      instanceName +
      ')  Authentication Required ';

    String body =
      '<h2>Authentication Required </h2><br/>' +
      '<br/><br/>Click to authenticate <a href="' +
      Label.default_url +
      'lightning/n/Quickbook_Authentication">Authenticate Now.</a>' +
      '<br/><br/>Error On ' +
      objectName +
      ' <br/> ' +
      recordDetails;
    sendEmail(subjectEmail, body);
    sendEmailAuthenticationClient(subjectEmail, body);
  }
  public static void customErrorEmail(
    String message,
    Id recordId,
    String recordName,
    String functionName
  ) {
    String subjectEmail = 'IMPORTANT | SYNCING | ERROR ';
    String body =
      '<br/>' +
      message +
      '<br/><br/>' +
      '<h2>Message(s):</h2>' +
      '<ul>' +
      ' <li>' +
      recordName +
      '</li>' +
      ' <ul>' +
      '<li>' +
      message +
      'Error is in' +
      functionName +
      '</li>' +
      '</ul>' +
      '</ul>' +
      ' <h2>Record(s):</h2>' +
      '<ul>' +
      '<li>' +
      '<a href ="' +
      Label.default_url +
      recordId +
      '">' +
      recordName +
      '</a>' +
      ' </li>' +
      '</ul>';
    sendEmail(subjectEmail, body);
  }

  public static void serverErrorEmails(
    HttpResponse response,
    String recordName,
    String objectName,
    string accountTitle,
    String functionName,
    String syncType,
    Id recordId
  ) {
    String subjectEmail =
      '( ' +
      response.getStatusCode() +
      ' ) IMPORTANT | QBO(' +
      accountTitle +
      ') | Error in Syncing at "' +
      System.now() +
      '"';

    String syncingIssueMessage = '';
    if (syncType == 'Estimate') {
      syncingIssueMessage =
        'An issue is occured during processing Estimate(s) in ' +
        functionName +
        ' function';
    } else if (syncType == 'Invoice') {
      syncingIssueMessage =
        'An issue is occured during processing Invoice(s) in ' +
        functionName +
        ' function';
    } else if (syncType == 'Account') {
      syncingIssueMessage =
        'An issue is occured during processing Account(s) in ' +
        functionName +
        ' function';
    }
    String body =
      'Response <br/>' +
      'Error in syncing. ' +
      '' +
      'QBO Instance ' +
      ' <br/> ' +
      accountTitle +
      '(' +
      recordName +
      ')' +
      '<br/><br/>' +
      '<h2>Message(s):</h2>' +
      '<ul>' +
      ' <li>' +
      recordName +
      '</li>' +
      ' <ul>' +
      '<li>' +
      response.getBody() +
      '</li>' +
      '</ul>' +
      '</ul>' +
      ' <h2>Record(s):</h2>' +
      '<ul>' +
      '<li>' +
      '<a href ="' +
      Label.default_url +
      recordId +
      '">' +
      recordName +
      '</a>' +
      ' </li>' +
      '</ul>';

    sendEmail(subjectEmail, body);
  }

  public static void sendEmailAuthenticationClient(
    string subject,
    string body
  ) {
    string emails = Label.QBO_Authentication_Error_Emails;
    subject += ' Client Send';
    List<String> allEmails = emails.split(';');
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = allEmails;
    message.optOutPolicy = 'FILTER';
    message.subject = subject;
    message.setHtmlBody(body);
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    if (results[0].success) {
      System.debug('The email was sent successfully to : ' + emails);
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
  public static void sendEmail(string subject, string body) {
    string emails = Label.QB_Syncing_Error_Emails;
    System.debug(emails);
    // String allEmails[]=  emails.split(',');
    List<String> allEmails = emails.split(',');
    //List<String> allEmails = emails.split(';');
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = allEmails;
    message.optOutPolicy = 'FILTER';
    message.subject = subject;
    message.setHtmlBody(body);
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    if (results[0].success) {
      System.debug('The email was sent successfully to ' + emails);
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
  public static Map<String, String> getSyncToken(
    String objectType,
    List<String> customerIds,
    List<String> authenticationTokens,
    String accountTitle
  ) {
    Map<String, String> qbSyncTokenMap = new Map<String, String>();
    String query =
      'select id, syncToken from ' +
      objectType +
      ' where id in(\'';
    query = query + String.join(customerIds, '\',\'') + '\')';
    if (Test.isRunningTest()) {
      qbSyncTokenMap.put('1', '12');
      return qbSyncTokenMap;
    }
    String qbResponse = QuickbookScheduler.QuickBookRecordGetter(
      query,
      authenticationTokens,
      accountTitle
    );
    if (qbResponse != null) {
      Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
        qbResponse
      );
      List<Object> responseArray = (List<Object>) ((Map<String, Object>) results.get(
          'QueryResponse'
        ))
        .get(objectType);
      for (Object res : responseArray) {
        Map<String, Object> token = (Map<String, Object>) res;
        qbSyncTokenMap.put(
          String.valueof(token.get('Id')),
          String.valueof(token.get('SyncToken'))
        );
      }
    }
    return qbSyncTokenMap;
  }
  public void execute(QueueableContext ctx) {
    System.debug('In the execute');
    QuickbookApiCrud.syncVendor(this.mapQBInstanceVendorAccountId, this.key);
  }

  @future(callout=true)
  public static void createPFAEventBillingInvoiceInQBO(
    Set<Id> eventBillingRecIds,
    Map<Id, String> eventIdQBOInstanceMap
  ) {
    try {
      List<PFA_Event_Billing__c> pfaEventBillingList = [
        SELECT
          Id,
          Name,
          Account__c,
          PFA_Event__c,
          PFA_Campaign__c,
          QBO_Invoice_Number__c,
          Bill_Date__c,
          QBO_Invoice_Detail__c,
          QBO_Invoice_Id__c,
          Bill_Due_Date__c,
          Payment_Link__c,
          Total_Amount__c,
          Quickbooks_Instance__c
        FROM PFA_Event_Billing__c
        WHERE Id IN :eventBillingRecIds
      ];

      System.Debug('pfaEventBillingList ==> ' + pfaEventBillingList);

      Map<Id, QuicbooksConfiguration> qboConfigs = getPFAQBOCredentials(
        eventIdQBOInstanceMap
      );
      System.debug('qboConfigs ==> ' + qboConfigs);

      List<QBO_Details__c> qboDetailsList = [
        SELECT
          Id,
          QB_Id__c,
          Account__c,
          Account__r.Name,
          Id_Type__c,
          Opportunity__c,
          QBO_Account__c,
          Salesforce_Record_Id__c
        FROM QBO_Details__c
        WHERE
          Account__c = :pfaEventBillingList.get(0).Account__c
          AND Id_Type__c = :'Account'
          AND QBO_Account__c = :eventIdQBOInstanceMap.Values()
      ];

      System.Debug('qboDetailsList ==> ' + qboDetailsList);

      for (PFA_Event_Billing__c eventBillingRec : pfaEventBillingList) {
        System.Debug('In pfaEventBillingList Loop');

        Invoice inv = new Invoice();
        inv.CustomerRef = new CustomerRef();
        if (qboDetailsList != null && qboDetailsList.size() > 0) {
          inv.CustomerRef.name = qboDetailsList.get(0).Account__r.Name;
          inv.CustomerRef.value = (String) qboDetailsList.get(0).QB_Id__c;
        }
        inv.TotalAmt = eventBillingRec.Total_Amount__c;
        //inv.Balance = eventBillingRec.Balance_Due__c;
        //inv.BillEmail = new billEmail();
        //inv.BillEmail.Address = eventBillingRec.Invoice_Email__c != null ? eventBillingRec.Invoice_Email__c : null;
        //inv.TxnDate = string.valueof(eventBillingRec.Invoice_Date__c);
        inv.DueDate = string.valueof(eventBillingRec.Bill_Due_Date__c);
        //inv.ShipDate = eventBillingRec.Invoice_Ship_Date__c;
        //inv.SalesTermRef = new SalesTermRef();
        //inv.SalesTermRef.value = termRefs.get(eventBillingRec.Invoice_Terms__c) != null ? termRefs.get(eventBillingRec.Invoice_Terms__c): '';
        //inv.CustomField = new List<CustomField>();
        //if(qboConfigs!=null && qboConfigs.get(eventBillingRec.id)!=null)
        //    inv.CustomField.add(new CustomField(qboConfigs.get(eventBillingRec.id).qbCustomFieldId,qboConfigs.get(eventBillingRec.id).qbCustomField,eventBillingRec.OpportunityId));

        inv.Line = new List<Line>();

        //Integer quantity = 0;
        //Integer retailPrice = 0;
        Line lineItem1 = new Line();
        lineItem1.Amount = eventBillingRec.Total_Amount__c;
        lineItem1.Description = 'PFA Event Billing Invoice';
        lineItem1.DetailType = 'SalesItemLineDetail';
        lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
        //lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
        //lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(retailPrice);
        lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
        lineItem1.SalesItemLineDetail.ItemRef.name =
          eventBillingRec.Name + 'Bill';
        lineItem1.SalesItemLineDetail.ItemRef.value = null; //String.valueOf(eventBillingRec.Total_Amount__c);
        inv.Line.add(lineItem1);

        String json = JSON.serialize(inv, true);

        System.Debug('JSON ==> ' + json);

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        System.debug(
          'qboConfigs.get(eventBillingRec.id).accessToken ==> ' +
          qboConfigs.get(eventBillingRec.id).accessToken
        );
        request.setHeader(
          'Authorization',
          'Bearer ' + qboConfigs.get(eventBillingRec.id).accessToken
        );
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(json);
        request.setMethod('POST');
        if (Test.isRunningTest()) {
          request.setEndPoint('http://test.com/test/sendInvoicce');
        } else {
          request.setEndPoint(
            qboConfigs.get(eventBillingRec.id).qbApiEndPoint +
              '/v3/company/' +
              qboConfigs.get(eventBillingRec.id).realMId +
              '/invoice?minorversion=40&include=invoiceLink'
          );
        }
        response = http.send(request);
        Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
          response.getBody()
        );
        System.Debug(
          'response.getStatusCode() ==> ' + response.getStatusCode()
        );
        System.Debug('results ==> ' + results);
        if (response.getStatusCode() == 200) {
          //Map<String,Object> results = (Map<String,Object>)System.JSON.deserializeUntyped(response.getBody());
          results = (Map<String, Object>) System.JSON.deserializeUntyped(
            response.getBody()
          );
          System.Debug('results ==> ' + results);
          eventBillingRec.QBO_Invoice_Id__c = (String) ((Map<String, Object>) results.get(
              'Invoice'
            ))
            .get('Id');
          eventBillingRec.QBO_Invoice_Detail__c =
            eventIdQBOInstanceMap.get(eventBillingRec.id) +
            '(' +
            ((Map<String, Object>) results.get('Invoice')).get('DocNumber') +
            ')';
          eventBillingRec.QBO_Invoice_Number__c = (String) ((Map<String, Object>) results.get(
              'Invoice'
            ))
            .get('DocNumber'); // DocNumber as a Sync Token
          eventBillingRec.Payment_Link__c = (String) ((Map<String, Object>) results.get(
              'Invoice'
            ))
            .get('InvoiceLink');
        }
        // else if(response.getStatusCode() == 401){
        //     authenticationErrorEmail(response,'Order# '+orderIds.ToString(),'Create Invoice',eventIdQBOInstanceMap.get(eventBillingRec.id));
        // } else {

        //     serverErrorEmails(response,eventBillingRec.Name,'Order',eventIdQBOInstanceMap.get(eventBillingRec.id),'Class QuickbookApiCrud , createInvoice','Invoice',eventBillingRec.Id);
        // }
      }
      //OrderTriggerService.markInvoicesPaid(pfaEventBillingList);
      update pfaEventBillingList;
    } catch (Exception Ex) {
      System.debug(
        'Exception in Create Invoice-->>>>>>' +
          Ex.getMessage() +
          '->>>>>' +
          Ex.getCause() +
          '--------->>>>>>>>' +
          Ex.getStackTraceString()
      );
    }
  }

  @future(callout=true)
  public static void deletePFAEventBillingInvoiceInQBO(
    Id eventBillingRecId,
    String qboInvoiceId,
    String qboInvoiceDocNumber,
    Map<Id, String> eventIdQBOInstanceMap
  ) {
    try {
      System.Debug('In Delete Method ==> ');
      Map<Id, QuicbooksConfiguration> qboConfigs = getPFAQBOCredentials(
        eventIdQBOInstanceMap
      );
      //json data prepartion for delete operation
      map<string, string> jsonBody = new Map<string, string>();
      jsonBody.put('SyncToken', qboInvoiceDocNumber);
      jsonBody.put('Id', qboInvoiceId);
      String json = JSON.serialize(jsonBody);
      //http request to delete bill from QBO
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      if (
        qboConfigs != null &&
        qboConfigs.get(eventBillingRecId) != null &&
        qboConfigs.get(eventBillingRecId).accessToken != null
      ) {
        request.setHeader(
          'Authorization',
          'Bearer ' + qboConfigs.get(eventBillingRecId).accessToken
        );
      }
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(json);
      request.setMethod('POST');
      if (Test.isRunningTest()) {
        request.setEndPoint('http://test.com/test/deletePurchaseOrder');
      } else {
        request.setEndPoint(
          qboConfigs.get(eventBillingRecId).qbApiEndPoint +
            '/v3/company/' +
            qboConfigs.get(eventBillingRecId).realMId +
            '/invoice?operation=delete&minorversion=69'
        );
      }
      response = http.send(request);
      System.Debug('response.getStatusCode() ==> ' + response.getStatusCode());

      Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
        response.getBody()
      );
      System.Debug('response results ==> ' + results);

      if (response.getStatusCode() == 200) {
        System.debug('Bill has been Deleted');
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in deletion of Bill-->>>>>>' +
          Ex.getMessage() +
          '->>>>>' +
          Ex.getCause() +
          '--------->>>>>>>>' +
          Ex.getStackTraceString()
      );
    }
  }

  public static Map<Id, QuicbooksConfiguration> getPFAQBOCredentials(
    Map<Id, String> eventIdQBOInstanceMap
  ) {
    List<QB_Credentials__c> QBOCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c IN :eventIdQBOInstanceMap.Values()
    ];
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c,
        Service_Id_Breakdown__c,
        Service_Id_Brokerage__c,
        Service_Id_Duty__c,
        Service_Id_FixedCharges__c,
        Service_Id_InboundFreight__c,
        Service_Id_RunCharges__c,
        Service_Id_Decoration__c,
        Service_Id_Fulfillment__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c IN :eventIdQBOInstanceMap.Values()
    ];
    Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
    for (QB_Credentials__c QBOCred : QBOCredentials) {
      if (QBOCred.Access_token__c != null && QBOCred.Refresh_token__c != null) {
        for (
          Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
        ) {
          if (
            accConfig.Quickbooks_Account_Tittle__c ==
            QBOCred.Synced_Account_Title__c
          ) {
            QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
              QBOCred,
              accConfig
            );
            for (Id key : eventIdQBOInstanceMap.keySet()) {
              if (
                eventIdQBOInstanceMap.get(key) ==
                QBOCred.Synced_Account_Title__c
              ) {
                qboConfigs.put(key, qboConfig);
              }
            }
          }
        }
      }
    }
    return qboConfigs;
  }

  // public static Map<Id, QuicbooksConfiguration> getPFAQBOCredentials(Map<Id, String> eventIdQBOInstanceMap) {
  //     Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();

  //     Map<String, QB_Credentials__c> titleToCredentialMap = new Map<String, QB_Credentials__c>();
  //     Map<String, Quickbooks_Accounts_Configurations__c> titleToConfigMap = new Map<String, Quickbooks_Accounts_Configurations__c>();

  //     for (QB_Credentials__c QBOCred : [SELECT Id, Access_token__c, RealMId__c, Refresh_token__c, Synced_Account_Title__c
  //                                       FROM QB_Credentials__c
  //                                       WHERE Synced_Account_Title__c IN :eventIdQBOInstanceMap.Values() AND
  //                                       Access_token__c != null AND Refresh_token__c != null]) {
  //         titleToCredentialMap.put(QBOCred.Synced_Account_Title__c, QBOCred);
  //     }

  //     for (Quickbooks_Accounts_Configurations__c accConfig : [SELECT Id, QBO_Custom_Field_1__c, QBO_Custom_Field_1_Id__c,
  //                                             QB_Access_token_End_Point__c, QB_API_End_Point__c, QB_Authorization_End_Point__c,
  //                                             QB_Authorization_Scope__c, QB_Client_Id__c, QB_Client_Secret__c, QB_ID__c,
  //                                             QB_Redirect_URI__c, QB_Timezone__c, Quickbooks_Account_Tittle__c,
  //                                             Service_Id_Breakdown__c, Service_Id_Brokerage__c, Service_Id_Duty__c,
  //                                             Service_Id_FixedCharges__c, Service_Id_InboundFreight__c,
  //                                             Service_Id_RunCharges__c, Service_Id_Decoration__c, Service_Id_Fulfillment__c
  //                                             FROM Quickbooks_Accounts_Configurations__c
  //                                             WHERE Quickbooks_Account_Tittle__c IN :eventIdQBOInstanceMap.Values()]) {
  //         titleToConfigMap.put(accConfig.Quickbooks_Account_Tittle__c, accConfig);
  //     }

  //     for (Id key : eventIdQBOInstanceMap.keySet()) {
  //         String title = eventIdQBOInstanceMap.get(key);
  //         QB_Credentials__c QBOCred = titleToCredentialMap.get(title);
  //         Quickbooks_Accounts_Configurations__c accConfig = titleToConfigMap.get(title);

  //         if (QBOCred != null && accConfig != null) {
  //             QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(QBOCred, accConfig);
  //             qboConfigs.put(key, qboConfig);
  //         }
  //     }

  //     return qboConfigs;
  // }

  @future(callout=true)
  public static void updatePFAEventBillingInvoiceInQBO(
    Set<Id> eventBillingRecIds,
    Map<Id, String> eventIdQBOInstanceMap
  ) {
    try {
      List<PFA_Event_Billing__c> pfaEventBillingList = [
        SELECT
          Id,
          Name,
          Account__c,
          PFA_Event__c,
          PFA_Campaign__c,
          QBO_Invoice_Number__c,
          Bill_Date__c,
          QBO_Invoice_Detail__c,
          QBO_Invoice_Id__c,
          Bill_Due_Date__c,
          Payment_Link__c,
          Total_Amount__c,
          Quickbooks_Instance__c
        FROM PFA_Event_Billing__c
        WHERE Id IN :eventBillingRecIds
      ];

      System.Debug('pfaEventBillingList ==> ' + pfaEventBillingList);

      if (pfaEventBillingList != null || pfaEventBillingList.size() > 0) {
        //Map<Id,QuicbooksConfiguration> qboConfigs = getPFAQBOCredentials(eventIdQBOInstanceMap);
        //System.debug('qboConfigs ==> ' + qboConfigs);

        //-------------------------------------------------------
        List<QB_Credentials__c> QBOCredentials = [
          SELECT
            Id,
            Access_token__c,
            RealMId__c,
            Refresh_token__c,
            Synced_Account_Title__c
          FROM QB_Credentials__c
          WHERE Synced_Account_Title__c IN :eventIdQBOInstanceMap.Values()
        ];

        List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
          SELECT
            Id,
            QBO_Custom_Field_1__c,
            QBO_Custom_Field_1_Id__c,
            QB_Access_token_End_Point__c,
            QB_API_End_Point__c,
            QB_Authorization_End_Point__c,
            QB_Authorization_Scope__c,
            QB_Client_Id__c,
            QB_Client_Secret__c,
            QB_ID__c,
            QB_Redirect_URI__c,
            QB_Timezone__c,
            Quickbooks_Account_Tittle__c,
            Service_Id_Breakdown__c,
            Service_Id_Brokerage__c,
            Service_Id_Duty__c,
            Service_Id_FixedCharges__c,
            Service_Id_InboundFreight__c,
            Service_Id_RunCharges__c,
            Service_Id_Decoration__c,
            Service_Id_Fulfillment__c
          FROM Quickbooks_Accounts_Configurations__c
          WHERE Quickbooks_Account_Tittle__c IN :eventIdQBOInstanceMap.Values()
        ];

        Map<String, QB_Credentials__c> accToQBOCredential = new Map<String, QB_Credentials__c>();

        ////
        for (QB_Credentials__c qb : QBOCredentials) {
          if (
            qb.Synced_Account_Title__c == 'Team Phun' &&
            qb.Access_token__c != null &&
            qb.Refresh_token__c != null
          ) {
            accToQBOCredential.put('Team Phun', qb);
          } else if (
            qb.Synced_Account_Title__c == 'Team Phun' &&
            qb.Access_token__c != null &&
            qb.Refresh_token__c != null
          ) {
            accToQBOCredential.put('Team Phun', qb);
          }
        }
        /////

        Map<Id, QuicbooksConfiguration> qboConfigs = new Map<Id, QuicbooksConfiguration>();
        for (QB_Credentials__c QBOCred : QBOCredentials) {
          if (
            QBOCred.Access_token__c != null &&
            QBOCred.Refresh_token__c != null
          ) {
            for (
              Quickbooks_Accounts_Configurations__c accConfig : accountConfiguration
            ) {
              if (
                accConfig.Quickbooks_Account_Tittle__c ==
                QBOCred.Synced_Account_Title__c
              ) {
                QuicbooksConfiguration qboConfig = getQuicbooksConfigurationForInvoice(
                  QBOCred,
                  accConfig
                );
                for (Id key : eventIdQBOInstanceMap.keySet()) {
                  if (
                    eventIdQBOInstanceMap.get(key) ==
                    QBOCred.Synced_Account_Title__c
                  ) {
                    qboConfigs.put(key, qboConfig);
                  }
                }
              }
            }
          }
        }

        //--------------------------------------------------------

        Map<String, String> eventBillingIdsForSyncToken = new Map<String, String>();

        for (PFA_Event_Billing__c eventBillingRec : pfaEventBillingList) {
          eventBillingIdsForSyncToken.put(
            eventBillingRec.QBO_Invoice_Id__c,
            eventIdQBOInstanceMap.get(eventBillingRec.id)
          );
        }
        Map<String, String> orderSyncTokenMap = new Map<String, String>();
        orderSyncTokenMap = getSyncTokenMapForOrders(
          eventBillingIdsForSyncToken,
          'Invoice',
          QBOCredentials,
          accountConfiguration
        );

        List<QBO_Details__c> qboDetailsList = [
          SELECT
            Id,
            QB_Id__c,
            Account__c,
            Account__r.Name,
            Id_Type__c,
            Opportunity__c,
            QBO_Account__c,
            Salesforce_Record_Id__c
          FROM QBO_Details__c
          WHERE
            Account__c = :pfaEventBillingList.get(0).Account__c
            AND id_Type__c = :'Account'
            AND QBO_Account__c IN :eventIdQBOInstanceMap.Values()
        ];

        Map<Id, QBO_Details__c> qboDetailsMap = new Map<Id, QBO_Details__c>();
        for (QBO_Details__c qbDetail : qboDetailsList) {
          for (Id key : eventIdQBOInstanceMap.keySet()) {
            if (qbDetail.QBO_Account__c == eventIdQBOInstanceMap.get(key)) {
              qboDetailsMap.put(key, qbDetail);
            }
          }
        }

        for (PFA_Event_Billing__c eventBillingRec : pfaEventBillingList) {
          if (
            qboConfigs.get(eventBillingRec.id) != null || Test.isRunningTest()
          ) {
            System.Debug('In pfaEventBillingList Loop');
            String txnId = eventBillingRec.QBO_Invoice_Id__c;
            List<String> authorizationCredentials = new List<String>();

            authorizationCredentials.add(
              accToQBOCredential.get(eventBillingRec.Quickbooks_Instance__c)
                .Access_token__c
            );
            authorizationCredentials.add(
              accToQBOCredential.get(eventBillingRec.Quickbooks_Instance__c)
                .Refresh_token__c
            );
            authorizationCredentials.add(
              accToQBOCredential.get(eventBillingRec.Quickbooks_Instance__c)
                .realmid__c
            );

            String query = 'Select * from Invoice where Id = \'' + txnId + '\'';
            String invoices = QuickbookScheduler.QuickBookRecordGetter(
              query,
              authorizationCredentials,
              eventBillingRec.Quickbooks_Instance__c
            );

            System.debug('invoices ==> ' + invoices);

            QuickbookApiCrud.InvoiceResponse results = (QuickbookApiCrud.InvoiceResponse) JSON.deserialize(
              invoices,
              QuickbookApiCrud.InvoiceResponse.class
            );
            List<QuickbookApiCrud.Invoice> invoice = results.QueryResponse.Invoice;
            List<QuickbookApiCrud.Line> line = invoice[0].Line;
            System.debug(line);

            Invoice inv = new Invoice();

            inv.id = eventBillingRec.QBO_Invoice_Id__c;
            inv.SyncToken = orderSyncTokenMap.get(
              eventBillingRec.QBO_Invoice_Id__c
            );

            inv.CustomerRef = new CustomerRef();
            inv.CustomerRef.name = qboDetailsMap.get(eventBillingRec.id)
              .Account__r.Name;
            inv.CustomerRef.value = (String) qboDetailsMap.get(
                eventBillingRec.id
              )
              .QB_Id__c;
            // if(qboDetailsList!=null && qboDetailsList.size()>0)
            // {
            //     inv.CustomerRef.name = qboDetailsList.get(0).Account__r.Name;
            //     inv.CustomerRef.value = (String)qboDetailsList.get(0).QB_Id__c;
            // }
            inv.TotalAmt = eventBillingRec.Total_Amount__c;
            //inv.Balance = eventBillingRec.Balance_Due__c;
            //inv.BillEmail = new billEmail();
            //inv.BillEmail.Address = eventBillingRec.Invoice_Email__c != null ? eventBillingRec.Invoice_Email__c : null;
            //inv.TxnDate = string.valueof(eventBillingRec.Invoice_Date__c);
            inv.DueDate = string.valueof(eventBillingRec.Bill_Due_Date__c);
            //inv.ShipDate = eventBillingRec.Invoice_Ship_Date__c;
            //inv.SalesTermRef = new SalesTermRef();
            //inv.SalesTermRef.value = termRefs.get(eventBillingRec.Invoice_Terms__c) != null ? termRefs.get(eventBillingRec.Invoice_Terms__c): '';
            //inv.CustomField = new List<CustomField>();
            //if(qboConfigs!=null && qboConfigs.get(eventBillingRec.id)!=null)
            //    inv.CustomField.add(new CustomField(qboConfigs.get(eventBillingRec.id).qbCustomFieldId,qboConfigs.get(eventBillingRec.id).qbCustomField,eventBillingRec.OpportunityId));

            inv.Line = new List<Line>();

            //Integer quantity = 0;
            //Integer retailPrice = 0;
            Line lineItem1 = new Line();
            lineItem1.Amount = eventBillingRec.Total_Amount__c;
            lineItem1.Description = 'PFA Event Billing Invoice';
            lineItem1.DetailType = 'SalesItemLineDetail';
            lineItem1.SalesItemLineDetail = new SalesItemLineDetail();
            //lineItem1.SalesItemLineDetail.Qty = String.valueOf(quantity);
            //lineItem1.SalesItemLineDetail.UnitPrice = String.valueOf(retailPrice);
            lineItem1.SalesItemLineDetail.ItemRef = new ItemRef();
            lineItem1.SalesItemLineDetail.ItemRef.value = qboConfigs.get(
                eventBillingRec.id
              )
              .breakdownServiceId;
            inv.Line.add(lineItem1);

            String json = JSON.serialize(inv, true);

            System.Debug('JSON ==> ' + json);

            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            System.debug(
              'qboConfigs.get(eventBillingRec.id).accessToken ==> ' +
              qboConfigs.get(eventBillingRec.id).accessToken
            );
            request.setHeader(
              'Authorization',
              'Bearer ' + qboConfigs.get(eventBillingRec.id).accessToken
            );
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(json);
            request.setMethod('POST');
            if (Test.isRunningTest()) {
              request.setEndPoint('http://test.com/test/sendInvoicce');
            } else {
              request.setEndPoint(
                qboConfigs.get(eventBillingRec.id).qbApiEndPoint +
                  '/v3/company/' +
                  qboConfigs.get(eventBillingRec.id).realMId +
                  '/invoice?minorversion=55&include=invoiceLink'
              );
            }
            response = http.send(request);
            System.Debug(
              'response.getStatusCode() ==> ' + response.getStatusCode()
            );

            Map<String, Object> results2 = (Map<String, Object>) System.JSON.deserializeUntyped(
              response.getBody()
            );
            System.Debug('response results2 ==> ' + results2);

            if (response.getStatusCode() == 200) {
              System.debug('INVOICE UPDATED');
            }
            // else if(response.getStatusCode() == 401){
            //     authenticationErrorEmail(response,'Order# '+orderIds.ToString(),'Create Invoice',eventIdQBOInstanceMap.get(eventBillingRec.id));
            // } else {

            //     serverErrorEmails(response,eventBillingRec.Name,'Order',eventIdQBOInstanceMap.get(eventBillingRec.id),'Class QuickbookApiCrud , createInvoice','Invoice',eventBillingRec.Id);
            // }
          }
        }
        //OrderTriggerService.markInvoicesPaid(pfaEventBillingList);
        // update pfaEventBillingList;
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in Create Invoice-->>>>>>' +
          Ex.getMessage() +
          '->>>>>' +
          Ex.getCause() +
          '--------->>>>>>>>' +
          Ex.getStackTraceString()
      );
    }
  }
}
