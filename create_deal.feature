@clo
Feature: Deal Creation & Push

    Background:
        Given I am logged on the platform as a closer "PRE-CLOSING"
        When I create opportunity
            | confidentiality level | expected closing date | description               | name              | client    | Currency | deal amount    |
            | Confidential          | 2016-02-03            | This i s a selenium test  | e2e-closing-deal  | RENAULT   | EUR      | 500000         |
        And with deal team
            | Last Name | First Name | role        |
            | Kim       | Eric       | Deal Leader |
        And with deal details
            | business line leader  | sg role        |
            | MARK/FIC              | PARTICIPANT    |
        And with booking entity
            | name                   |
            | SOCIETE GENERALE/PARIS |
        And create deal
            | Syndication Type                | Financing purpose   | Counterpart   | Currency |
            | Syndicated Credit - Participant | Capital Raising     | DORNA SPORTS  | USD      |
        And create light facility without pricing
            | facility name | facility amount   |
            | Tranche A     | 50000             |
        And with mandated status

    Scenario: Push Contract
        Given the deal is in closing scope

        When with Agreement Date to yesterday
        And with Maximum number of Loans "2"
        And with Classification "Capital Financing"
        And with Mandatory MIS Codes
        And with Syndication MIS Codes
        And with Optional MIS Code "17-05-2016"
        And with Tracking Number
        And with Department "EU-MARK-CBA"
        And with Portfolio "CA100 | PORT.CREDITS ACHETEURS LOAN IQ"
        And with Alternate ID
        And with Agent "256"
        And with Deal manager "GAERTNER | LAURENCE | A130476"
        And with Closer team "TEAMCLOA"
        And with Deal Alias
        And push contract to Loan IQ

        Then the push should be successful
