public class EventController {

    public List<Campaign> campaigns;
    public Campaign campaign;
    public Contact contact;
    public Boolean error {get; set;}
    public String errorMessage {get; set;}
    public String waiver {get; set;}
    public boolean campAvailable {get; set;}
    public Integer guests {get; set;}
    // date and time fields splited
    public String eventDate {set; get;}
    public String startTime {set; get;}
    public String endTime {set; get;}
    
    private void init(){
        error = false;
        waiver = 'false';
        //iT(); not needed
        initCalendar();
        campAvailable = false;
        guests = 1;
    }
    public Contact getContact(){
        if (null == contact){
            contact = new Contact();
        }
        return contact;
    }
    
    public List<SelectOption> getWaiverOptions(){
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new Selectoption('true', 'I agree'));
        opts.add(new SelectOption('false','I disagree'));
        return opts;
    }
    
    public Campaign getCampaign(){
        if (null == campaign) {
            String id = ApexPages.currentPage().getParameters().get('campaignId');
            List<Campaign> temp = [SELECT Id, Name, Seats_Available__c ,County__c, Event_Date_Time__c, Event_End_Time__c, Description, /*RecordType.Name,*/ Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, Description_Long__c, Event_Location__c
                        FROM Campaign WHERE Id = :id];
            if (temp.size() < 1) return null;
            campaign = temp.get(0);
            campAvailable = false;
            if (campaign.Event_Date_Time__c > Date.today() && (campaign.Slots_Remaining__c > 0) && (campaign.Seats_Available__c > 0)){
                campAvailable = true;
            }
            // date and time:
            eventDate = '';
            startTime = '';
            endTime   = '';
            if (campaign.Event_Date_Time__c != null){
                String[] dTime = campaign.Event_Date_Time__c.format().split(' ');
                eventDate = dTime[0];
                for (Integer i = 1; i < dTime.size(); i++)
                    startTime += dTime[i]+' ';
            }
            if (campaign.Event_End_Time__c != null){
                String[] dTime = campaign.Event_End_Time__c.format().split(' ');
                for (Integer i = 1; i < dTime.size(); i++)
                    endTime += dTime[i]+' ';
            }
        }
        return campaign;
    }
    
    public EventController() {
        init();
    }
    
    public PageReference signUp() {
        String campaignId = ApexPages.currentPage().getParameters().get('campaignId');
        if (null == campaignId){
            error = true;
            errorMessage = 'No campaigId';
            return ApexPages.currentPage();
        }
        // clear previous contact info
        contact = new Contact();
        //
        PageReference pageRef = new PageReference('/apex/EventSignUpForm?campaignId='+getCampaign().Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference submitSignUp(){
        error = false;
        campaign = [SELECT Id, Name, Event_Date_Time__c, Description, /*RecordType.name,*/ Event_Cost__c, Seats_Available__c, Slots_Remaining__c, Waiver_Required__c, Description_Long__c, Event_Location__c
                    FROM Campaign WHERE Id = :campaign.Id];
        // free slots?
        if (campaign.Slots_Remaining__c < 1 || campaign.Seats_Available__c < guests){
            error = true;
            errorMessage = 'Not enought space. Available seats: '+campaign.Seats_Available__c;
            return ApexPages.currentPage();
        }
        // if waiver required
        if (campaign.Waiver_Required__c && !(waiver == 'true')){
            error = true;
            errorMessage = 'You have to agree';
            return ApexPages.currentPage();
        }
        // if contact already inserted
        if (null != contact.Id){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'An error occured. Please try again:'));
            return new PageReference('/apex/EventSignUpForm?campaignId='+campaign.Id);
        }
        // check if already signed up, based on email:
        List<CampaignMember> c = [SELECT Contact.Email FROM CampaignMember WHERE CampaignId = :campaign.Id 
            AND (Contact.Email = :contact.Email)];
        if (c.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Person with this email is already signed up.'));
            return ApexPages.currentPage();
        }
        if (guests < 1){
            error = true;
            errorMessage = 'Total attendees cannot be less than 1.';
            return ApexPages.currentPage();
        }
        // if event requires pament, proceed
        PageReference pageRef;
        // save and ok
        saveContact();
        String msg = 'You have been signed up.';
        pageRef = new PageReference('/apex/EventCalendarView?success='+msg);
        pageRef.setRedirect(true);
        campaign = null;
        return pageRef;
    }
    
    private void saveContact(){
        // search for contact with same email adress
        List<Contact> oldContact = [SELECT Id, /*npo02__Household__c,*/ FirstName, Phone, /*Emergency_Contact__c, Emergency_Contact_Phone__c,*/ MailingStreet, MailingCity, 
                MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE 
                (Contact.Email = :contact.Email) LIMIT 1];
        if (oldContact.size() > 0){
            System.debug('Existing contact, updating');
            // if contact with given email already found, update its details to given (?) 
            // update only missing info:
            contact.Id = oldContact[0].Id;
            if (oldContact[0].Phone == null){
                oldContact[0].Phone = contact.Phone;
            }
            if (oldContact[0].FirstName == null){
                oldContact[0].FirstName = contact.FirstName;
            }
            if (oldContact[0].MailingStreet == null && oldContact[0].MailingCity == null && oldContact[0].MailingState == null && oldContact[0].MailingPostalCode == null && oldContact[0].MailingCountry == null){
                oldContact[0].MailingStreet = contact.MailingStreet;
                oldContact[0].MailingCity = contact.MailingCity;
                oldContact[0].MailingState = contact.MailingState;
                oldContact[0].MailingPostalCode = contact.MailingPostalCode;
                oldContact[0].MailingCountry = contact.MailingCountry;
            }
            update oldContact[0];
        } else {
            insert contact;
        }
        // asociate contact with campaign:
        CampaignMember member = new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = contact.Id,
            Agreed_to_Waiver__c = (waiver == 'true')?true:false,
            Status = 'Responded "Yes"',
            Number_of_Guests__c = guests-1
        );
        insert member;
    }
    
    @isTest
    public static void testSignUp(){
        // create campaign
        Campaign cam = new Campaign(
            Name = 'test campaign',
            Display_on_Website__c = true,
            Waiver_Required__c = true,
            Capacity__c = 1,
            Event_Date_Time__c = Datetime.now(),
            Event_Duration__c = 10
        );
        insert cam;
        // prepare page
        PageReference pageRef = Page.EventDetail;
        pageRef.getParameters().put('campaignId', cam.Id);
        Test.setCurrentPage(pageRef);
        // 
        EventController con = new EventController(); 
        String nextPage = con.signUp().getUrl();
        System.assertEquals('/apex/EventSignUpForm?campaignId='+cam.Id, nextPage);
        // test signup
        pageRef = Page.EventSignUpForm;
        pageRef.getParameters().put('campaignId', cam.Id);
        Test.setCurrentPage(pageRef);
        // fill in form
        Account a = new Account(Name='Test Account');
        insert a;
        con.contact = new Contact(
        	AccountId = a.Id,
            FirstName = 'fn',
            LastName = 'ln',
            Email = 'e@m.l',
            Phone = '123'
        );
        con.getWaiverOptions();
        con.waiver = 'true';
        nextPage = con.submitSignUp().getUrl();
        System.assertEquals('/apex/EventCalendarView?success='+'You+have+been+signed+up.', nextPage);
        
        Contact c = con.getContact();
        String message = con.errorMessage;
        // thats it
    }
    
    /*************************************************************
    *                 calendar view
    */
    
    public Month month {get; private set;}
    public Map<Date, List<Campaign>> events {get; private set;}
    public Map<Id, Boolean> eventsSignedUp {get; set;} // campaign.Id, boolean
    public List<SelectOption> fOps {get; set;}
    public String[] selectedTypes {get; set;}
    
    /*
    *    Init types for calendar filter, not needed any more
    * */
    
    public void initCalendar() {
        Date d = system.today(); // default to today
        setMonth(d);
        // if
        if (ApexPages.currentPage().getParameters().get('success') != null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ApexPages.currentPage().getParameters().get('success')));
    }
    
    public void next() {
        addMonth(1);
    }
    
    public void prev() {
        addMonth(-1);
    }
    
    private void addMonth(Integer val) {
        Date d = month.getFirstDate();
        d = d.addMonths(val);
        setMonth(d);
    }
    
    public List<Month.Week> getWeeks() {
        system.assert(month!=null,'month is null');
        return month.getWeeks();
    }
    
    private void setMonth(Date d) {
        month = new Month(d);
        initEvents(month.getValidDateRange()); // gather events that fall in this month
    }
    
    private void initEvents(Date[] da) {
        events = new Map<Date, List<Campaign>>();
        eventsSignedUp = new Map<Id, boolean>();
        for (Date day = da[0]; day < da[1]; day = day.addDays(1)) {
            events.put(day, new List<Campaign>());
        }
        List<Campaign> evs = [
            SELECT Id,
                   Name,
                   Event_Date_Time__c,
                   Event_End_Time__c,
                   Slots_remaining__c
                   /*RecordType.Name*/
            FROM Campaign
            WHERE Event_Date_Time__c >= :da[0] AND Event_Date_Time__c <= :da[1] AND Display_on_Website__c = TRUE
            ORDER BY Event_Date_Time__c ASC
        ];
        System.debug('Campaign Events: ' + evs.size());
        System.debug(evs);
        System.debug('SELECT Id, Name, Event_Date_Time__c, Event_End_Time__c, Slots_remaining__c, /*RecordType.Name*/'+
            'FROM Campaign WHERE Event_Date_Time__c >= '+da[0]+' AND Event_Date_Time__c <= '+da[1]+' AND Display_on_Website__c = TRUE'+
            'ORDER BY Event_Date_Time__c ASC');

        for (Campaign e : evs) {
            Date d = e.Event_Date_Time__c.Date();
            if (d < e.Event_Date_Time__c.Date()){
                events.get(e.Event_Date_Time__c.Date()).add(e);
                continue;
            }
            while (d <= e.Event_End_Time__c.Date()){
                events.get(d).add(e);
                d = d.addDays(1);
            }
            eventsSignedUp.put(e.Id, false);
        }
        
    }
        
    @isTest
    public static void testCalendarView(){
        // create campaign
        Campaign cam = new Campaign(
            Name = 'test campaign',
            Display_on_Website__c = true,
            Waiver_Required__c = true,
            Capacity__c = 1
        );
        insert cam;
        // prepare page
        PageReference pageRef = Page.EventCalendarView;
        Test.setCurrentPage(pageRef);
        // 
        EventController con = new EventController(); 
        // change moths few times
        con.prev();
        con.next();
        
        List<SelectOption> fops = con.fops;
        List<String> selectedTypes = con.selectedTypes;
        con.getWeeks();
        // thats it
    }
    
    /******************************************* IATS payment ***********************************
    public String url {get {return 'https://www.iatspayments.com/NetGate/ProcessLink.asmx';} private set;}
    public String encoding {get {return 'utf-8';} private set;}
    public String userId {get {return Label.IATS_login;} private set;}
    public String password {get {return Label.IATS_password;} private set;}
    public String p_creditCardNumber {get; set;}
    public String p_creditCardExpiry {get; set;}
    public String p_cvv2 {get; set;}
    public String p_mop {get; set;}
    
    public String p_firstName {get; set;}
    public String p_lastName {get; set;}
    public String p_address {get; set;}
    public String p_city {get; set;}
    public String p_state {get; set;}
    public String p_zipCode {get; set;}
    public String p_total {get; set;}
    public String p_comment {get; set;}
    
    public String response {get; set;}
    
    public PageReference proceedPayment(){
        // validate data format
        p_creditCardNumber.replace(' ', '');
        String responseBody = startSession();
        String status;
        String detail;
        String result;
        XmlStreamReader reader = new XmlStreamReader(responseBody);
        while (reader.hasNext()) {
          if (reader.getEventType() == XmlTag.START_ELEMENT) {
            if ('STATUS' == reader.getLocalName()){
                status = parseNodeContents(reader);
                continue;
            }
            if ('ERRORS' == reader.getLocalName()){
                detail = parseNodeContents(reader);
            }
            if ('AUTHORIZATIONRESULT' == reader.getLocalName()){
                result = parseNodeContents(reader);
            }
          }
          reader.next();
        }
        if (result.startsWith(' OK:')){
            // payment proceeded successfuly - save contact
            saveContact();
            // create some payment confirmation - email?
            
            // create transaction/opportunity record            <-------------------
            
            String msg = 'Transaction proceeded, you have been signed up.';
            PageReference pageRef = new PageReference('/apex/EventCalendarView?success='+msg);
            pageRef.setRedirect(true);
            campaign = null;
            return pageRef;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Transaction not proceeded. Please review informations below and try again. ('+result+')'));
            return ApexPages.currentPage();
        }
    }
    
    public String startSession() {      
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(encoding, '1.0');
        w.writeStartElement('soap', 'Envelope', '');
        w.writeAttribute('xmlns', '', 'xsi', 'http://www.w3.org/2001/XMLSchema-instance');
        w.writeAttribute('xmlns', '', 'xsd', 'http://www.w3.org/2001/XMLSchema');
        w.writeAttribute('xmlns', '', 'soap', 'http://schemas.xmlsoap.org/soap/envelope/');    
        w.writeStartElement('soap', 'Body', '');
        w.writeStartElement(null, 'ProcessCreditCardV1', null);
        w.writeAttribute(null, null, 'xmlns', 'https://www.iatspayments.com/NetGate/');
        w.writeStartElement(null, 'agentCode', null);  w.writeCharacters(Label.IATS_login); w.writeEndElement();
        w.writeStartElement(null, 'password', null);  w.writeCharacters(Label.IATS_password); w.writeEndElement();
        //w.writeStartElement(null, 'customerIPAddress', null);  w.writeCharacters(''); w.writeEndElement();
        //w.writeStartElement(null, 'invoiceNum', null);  w.writeCharacters(''); w.writeEndElement();
        w.writeStartElement(null, 'creditCardNum', null);  w.writeCharacters(p_creditCardNumber); w.writeEndElement();
        w.writeStartElement(null, 'creditCardExpiry', null);  w.writeCharacters(p_creditCardExpiry); w.writeEndElement();
        w.writeStartElement(null, 'cvv2', null);  w.writeCharacters(p_cvv2); w.writeEndElement();
        w.writeStartElement(null, 'mop', null);  w.writeCharacters(p_mop); w.writeEndElement();
        w.writeStartElement(null, 'firstName', null);  w.writeCharacters(p_firstName); w.writeEndElement();
        w.writeStartElement(null, 'lastName', null);  w.writeCharacters(p_lastName); w.writeEndElement();
        w.writeStartElement(null, 'address', null);  w.writeCharacters(p_address); w.writeEndElement();
        w.writeStartElement(null, 'city', null);  w.writeCharacters(p_city); w.writeEndElement();
        w.writeStartElement(null, 'state', null);  w.writeCharacters(p_state); w.writeEndElement();
        w.writeStartElement(null, 'zipCode', null);  w.writeCharacters(p_zipCode); w.writeEndElement();
        w.writeStartElement(null, 'total', null);  w.writeCharacters(p_total); w.writeEndElement();
        w.writeStartElement(null, 'comment', null);  w.writeCharacters('GTRLC - '+campaign.Name); w.writeEndElement();
        w.writeEndElement(); // ProcessCreditCardCodeV1
        w.writeEndElement(); // Body
        w.writeEndDocument(); // Envelope
        String xmlRequest = w.getXmlString();
        
        return processRequest(xmlRequest, null);
    }
    
    public String processRequest(String xmlRequest, Integer timeout) {   
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-Type', 'text/xml;Charset=UTF-8');
        req.setHeader('Content-Length', xmlRequest.length().format());
        req.setBody(xmlRequest);
        
        HttpResponse res;
        //System.debug('REQUEST: ' + req.getBody());
        Http http = new Http();
        if (timeout != null) req.setTimeout(timeout);
        res = http.send(req);
        //System.debug('RESPONSE: ' + res.getBody());
        return res.getBody();
    }
    
    public String parseNodeContents(XmlStreamReader reader) {
        String text = '';
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT)
                break;
            else if (reader.getEventType() == XmlTag.CHARACTERS) {
                text += reader.getText();
            }
            reader.next();
        }
        return text;
    }*/
}