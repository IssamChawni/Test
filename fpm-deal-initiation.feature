@fpl-lso
Feature: fpl-lso deal intialisation

  Background: 
    Given I am logged in as "Raj.FrontOfficer-MultiGroup"

  
  Scenario: deal initiation from fpl platform
    Given I am in fplportal page
    And the deal is being initiated with the below information
      | confidentiality level | Deal Name    | Description                         | Client        | SG Role Category | Deal Amount | Currency | Expected Closing Date |
      | Confidential          | Eligible Opp | Create an Opportunity For E2E tests | AIR CANADA 	 | Financing        | 10M         | USD      | 6M                    |
    And deal team and contacts are listed below with respective roles
      | Pierre PALMIERI   | Deal Leader   |
      | Andrew JOHNMAN    | Deal Member   |
      | Marina MULCAIR    | Other contact |
      | GLFI/ABP/CMBS/AME |               |
      | CORI/CLT/COR/AME  |               |
    When I create the deal
    Then I am able to start the structuring process for that deal

 
  Scenario: Syndicated Deal Structuring from the financing platform
    Given the deal is initiated in fpl
    And the deal is being structured with mandatory information
      | Syndication Type                              | Financing Purpose     | SG Roles | Business Line Leader |
      | Syndicated Credit - Arranger or mandated bank | Acquisition Financing | ARRANGER | GLFI/ABP/CMB         |
    When deal is saved
    Then I should get a notification saying "The deal was successfully saved."

 
  Scenario: Term Loan Facility creation
    Given the deal is structured
    And the below facility is being added to the deal
      | Facility Name      | Product Type | Product      | Structure | Liquidity Model | Description                     | Facility Amount | Currency | Final Take | Repayment Date | Forced Liquidity | Spread Field | paid by       |
      | Facility Term Loan | Loans        | Cash Advance | Term Loan | Aircraft        | Create a Facility For E2E tests | 3M              | USD      |         10 | 5Y             |               50 |          250 | AIRBUS FRANCE |
    When I price with facility
    And save the facility
    Then deal and facility should be saved with notification message "The deal was successfully saved."
