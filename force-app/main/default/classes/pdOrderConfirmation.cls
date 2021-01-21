public with sharing class pdOrderConfirmation {
    public pdOrderConfirmation() {
        // 注文IDを取得する
        orderId = ApexPages.currentPage().getParameters().get('id');
    }

    /**
    * 注文ID
    */
    private Id orderId;

    /**
     * 注文タイトル
     */
    public String title { get; set; }

    /**
    * 取引先名
    */
    public String accountName { get; set; }

    /**
    * 取引先住所
    */
    public String accountPostalCode { get; set; }
    public String accountAddress1 { get; set; }
    public String accountAddress2 { get; set; }

    /**
    * 取引先担当者
    */
    public String contactName { get; set; }

    /**
    * 注文番号
    */
    public String orderNumber { get; set; }

    /**
    * 注文日
    */
    public Date orderDate { get; set; }

    /**
    * 会社名
    */
    public String companyName { get; set; }

    /**
    * 会社住所
    */
    public String companyPostalCode { get; set; }
    public String companyAddress1 { get; set; }
    public String companyAddress2 { get; set; }

    /**
    * 会社電話番号
    */
    public String companyPhone { get; set; }

    /**
    * 会社担当者
    */
    public String employeeName { get; set; }

    /**
    * 会社担当者メールアドレス
    */
    public String mailAddress { get; set; }

    /**
    * 注文明細
    */
    public List<OrderItem> orderDetail { get; set; }

    /**
    * 小計
    */
    public Decimal subTotal { get; set; }

    /**
    * 消費税
    */
    public Decimal tax { get; set; }

    /**
    * 合計
    */
    public Decimal total { get; set; }

    /**
    * 備考
    */
    public String memo { get; set; }

    /**
     * 税込表示
     */
    public Boolean isTaxIncluded { get; set; }
    /**
     * 税抜表示
     */
    public Boolean isTaxNotIncluded { get; set; }

    /**
     * 発行日
     */
    public Date issueDate { get; set; }

    /**
    * 注文を印刷するために必要なデータを取得する
    */
    public void doPrint() {
        // 現在のユーザ情報を取得する
        User user = [SELECT Id,CompanyName,PostalCode,State,City,Street,Phone,LastName,FirstName,Email
            FROM User
            WHERE Id=:UserInfo.getUserId()];

        // 会社情報を設定する
        // 会社名
        companyName = user.CompanyName;
        // 会社住所
        companyPostalCode = user.PostalCode;
        companyAddress1 = user.State + user.City;
        if (user.Street != null) {
            String[] companyStreet = user.Street.split('\r\n');
            if (companyStreet.size() >= 1) {
                companyAddress1 += companyStreet[0];
            }
            if (companyStreet.size() >= 2) {
                companyAddress2 = companyStreet[1];
            }
        }
        // 会社電話番号
        companyPhone = user.Phone;
        // 社員名
        employeeName = user.LastName + ' ' + user.FirstName;
        // メールアドレス
        mailAddress = user.Email;

        // 注文情報を取得する
        Order order = [SELECT Id,Name,
            Account.FullName__c,Account.BillingPostalCode,Account.BillingState,Account.BillingCity,Account.BillingStreet,
            CustomerAuthorizedBy.FirstName, CustomerAuthorizedBy.LastName,TaxType__c,OrderComfirmationIssueDate__c,
            OrderNumber, EffectiveDate, TotalAmount, Tax__c, GrandTotal__c, Memo__c
            FROM Order
            WHERE Id=:orderId];
        // 取引先名
        accountName = order.Account.FullName__c;
        // 取引先郵便番号
        accountPostalCode = order.Account.BillingPostalCode;
        // 取引先住所
        accountAddress1 = order.Account.BillingState + order.Account.BillingCity;
        if (order.Account.BillingStreet != null) {
            String[] accountStreet = order.Account.BillingStreet.split('\r\n');
            if (accountStreet.size() >= 1) {
                accountAddress1 += accountStreet[0];
            }
            if (accountStreet.size() >= 2) {
                accountAddress2 = accountStreet[1];
            }
        }
        // 注文タイトル
        title = order.OrderNumber + order.Name;
        // 取引先担当者名
        contactName = order.CustomerAuthorizedBy.LastName + ' ' + order.CustomerAuthorizedBy.FirstName;
        // 注文番号
        orderNumber = order.OrderNumber;
        // 注文日
        orderDate = order.EffectiveDate;
        // 小計
        subTotal = order.TotalAmount;
        // 消費税
        tax = order.Tax__c;
        // 合計
        total = order.GrandTotal__c;
        // 発行日
        issueDate = order.OrderComfirmationIssueDate__c;
        // 備考
        if (order.Memo__c != null) {
            memo = order.Memo__c.replace('\r\n', '<br />');
        }
        // 消費税表示
        isTaxIncluded = (order.taxType__c == '税込');
        isTaxNotIncluded = (order.taxType__c == '税抜');

        // 注文明細情報を取得する
        orderDetail = [SELECT Id,Description,UnitPrice,Quantity,Unit__c,TotalPrice
            FROM OrderItem
            WHERE OrderId=:orderId
            ORDER BY SortOrder__c];

        // 注文明細が8行未満なら8行になるまで空明細を追加する
        if (orderDetail == null) {
            orderDetail = new List<OrderItem>();
        }
        for (Integer i=orderDetail.size() ; i<8 ; i++) {
            OrderItem item = new OrderItem();
            orderDetail.add(item);
        }
    }
}
