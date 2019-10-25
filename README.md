### Project Name
Event Management


### Project Team
* Team Leader(s): Deirdre Callahan, Sean Conner
* GitHub Scribe(s): Sean Conner
* List of all Contributors:
Deirdre Callahan
Sean Conner
Melanie Tolomeo
Duncan McGovern
Thad Dahlberg
Donna Whitig
Alison Zwecker
Alline Avance
Esteban Dozsa
Sara Monostra
Justin Gilmore
Art Odoqui (Salesforce.org)


### Project Vision (Your first task as a team)
We aim to build best-fit Event Management architecture and features within the NPSP framework.

Nonprofits have myriad needs related to Event Management, and continue to reinvent the wheel locally when creating their architecture, often needing to make revisions or complex work-arounds in order to connect to leading event management platforms that connect to Salesforce or which they aim to extract data from.

Our product is intended for nonprofit organizations with one-time or templated/recurring events with complexity that includes:
* Event Seating/Table Seating considerations and capacity per seat type/seat inventory
* Event role tracking for individuals that are not in the "audience" of the event
...but which does not include (per se) the following items, though customers may build this over/into the schema:
* Attendee/Ticket Levels
* Attendee/Ticket Benefits and/or Premiums
* Ticket Packages/Discounts
* All architecture relating/related to financial transactions (Oppty/Payment/etc)
* Waitlisting and releasing attendees from a waitlist
* Expenses/expense tracking and net fundraising over cost
* Key Performance Indicators (KPI) reporting
* Location/venue detail and metrics tracking
* Event inventory (promo materials, premiums, supplies) tracking and shipping
* Onsite experience apps ("Day of" apps connectivity and interrelatedness)
* Check-in (active or passive) applications for updating/creating participant/attendee records
* Einstein-friendly metrics for recommending events to (community) users
* Use cases centered on Customer or Partner Community Users accessing event listings and managing/updating registrations
* Task management for event management
* Outbound communications to participants records

While our current goals include just gelling on a best-fit schema and common fields, our future goals include: 
* revision of these objects and architecture to accomodate more common data points or "add-in" objects than anticipated
* data sets to help users leverage NPSP Data Import Batch architecture/features for loading data into the schema
* UI elements and automation to help end users engage with these objects who are NOT using connected platforms or are using a mixture of connected platform and localized entry

### Project Resources
* Group Chat room for project (active during sprints/meetings): https://kellpartners.quip.com/Puh2Ai2akiYx
* Entity Relationship Diagrams (ERD): https://www.lucidchart.com/invitations/accept/22d990f7-58d2-4d90-9de7-d8291c186983
* Quip Documents folder (may require sign-in): https://kellpartners.quip.com/folder/event-management
* Proposed field list for core schema: https://kellpartners.quip.com/lSo5AhuzudDu

### Project Team Accomplishments during Philadelphia 2019 Sprint (Oct 17-18)
* Do we use Campaigns/Members or a Custom Object for the events themselves (See [Documentation/Decisions/DECISION1](https://github.com/SFDO-Sprint-2019-Philadelphia/EventManagement/blob/master/Documentation/Decisions/DECISION1%20-%20Campaigns%20or%20Custom))
* What is the appropriate relationship of participants in events to events and amongst themselves (See [Documentation/Decisions/DECISION2](https://github.com/SFDO-Sprint-2019-Philadelphia/EventManagement/blob/master/Documentation/Decisions/DECISION2%20-%20Participant%20Architecture))

### Future Contributions (Items we did not complete during the Sprint, but are roadmapping)
* Build suggested architecture as a deployment-ready package (including making field-level decisions about what is needed in the architecture)
* Create data set to help users leverage NPSP Data Import Batch features to perform ETL operations related to this architecture
* Create basic UI improvements and automations for common actions users will make related to events:
** UI Improvement/Action 1 TBD
** UI Improvement/Action 2 TBD
** UI Improvement/Action 3 TBD
