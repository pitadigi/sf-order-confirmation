@isTest
class pdOrderConfirmation_test {
    @TestSetup
    static void setup(){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'システム管理者' LIMIT 1];

        // ユーザーを作成する
        User user = new User();
        user.CompanyName = 'ぴたデジ株式会社';
        user.PostalCode = '020-0611';
        user.State = '岩手県';
        user.City = '滝沢市';
        user.Street = '巣子152-409\r\n滝沢市第2イノベーションセンター';
        user.Phone = '019-618-0161';
        user.LastName = '俣江';
        user.FirstName = '幸治';
        user.Email = 'kmatae@pitadigi.jp';
        user.Alias = 'kmatae';
        user.IsActive = true;
        user.Username = 'kmatae@pitadigi.jp.test';
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.LocaleSidKey = 'ja_JP';
        user.LanguageLocaleKey = 'ja';
        user.profileId = prof.Id;
        insert user;

        // 取引先を作成する
        Account account = new Account();
        account.Name = 'お客様';
        account.FullName__c = 'お客様株式会社';
        account.BillingPostalCode = '020-0000';
        account.BillingState = '岩手県';
        account.BillingCity = '滝沢市';
        account.BillingStreet = 'ああああ111-111\r\n○○';
        insert account;

        // 取引先責任者を作成する
        Contact contact = new Contact();
        contact.FirstName = 'あああ';
        contact.LastName = 'いいい';
        contact.AccountId = account.Id;
        insert contact;

        // 商品を作成する
        Product2 p = new Product2();
        p.Name = '商品';
        insert p;

        // 標準価格表のIDを取得する
        Id pricebook2Id = Test.getStandardPricebookId();

        // 商品品目を作成する
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = pricebook2Id;
        pbe.Product2Id  = p.Id;
        pbe.UnitPrice  = 200000;
        pbe.IsActive = true;
        pbe.UseStandardPrice = false;
        insert pbe;

        // 商談を作成する
        Opportunity opp = new Opportunity();
        opp.Name = '商談';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.newInstance(2019, 12, 27);
        opp.AccountId = account.Id;
        opp.Pricebook2Id = pricebook2Id;
        insert opp;

        OpportunityLineItem ol = new OpportunityLineItem();
        ol.OpportunityId = opp.Id;
        ol.PricebookEntryId = pbe.Id;
        ol.Quantity = 1;
        ol.TotalPrice = 200000;
        insert ol;

        // 注文情報を作成する
        Order order = new Order();
        order.EffectiveDate = Date.newInstance(2019, 12, 1);
        order.Tax__c = 20000;
        order.OpportunityId = opp.Id;
        order.CustomerAuthorizedById = contact.Id;
        order.Pricebook2Id = pricebook2Id;
        order.Name = '注文';
        order.TaxType__c = '税込';
        order.AccountId = account.Id;
        order.Status = 'Draft';
        order.OrderComfirmationIssueDate__c = Date.newInstance(2019, 12, 1);
        insert order;

        // 注文明細を作成する
        OrderItem item = new OrderItem();
        item.Description = '導入支援サービス';
        item.UnitPrice = 200000;
        item.Quantity = 1;
        item.Unit__c = '式';
        item.OrderId = order.Id;
        item.PricebookEntryId = pbe.Id;
        item.Product2Id = p.Id;
        insert item;

        order.Status = 'Activated';
        update order;
    }

    @isTest
    static void doPrint_test() {
        Id orderId = [SELECT Id FROM Order WHERE EffectiveDate=:Date.newInstance(2019, 12, 1)].Id;

        PageReference pageRef = Page.pdOrderConfirmation;
        pageRef.getParameters().put('id', orderId);
        Test.setCurrentPage(pageRef);

        User user = [SELECT Id FROM User WHERE Alias='kmatae'];
        System.RunAs(user) {
            pdOrderConfirmation q = new pdOrderConfirmation();

            q.doPrint();
        }
    }
}
