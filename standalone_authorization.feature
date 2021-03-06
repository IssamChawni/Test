@cwfsanity
Feature: standalone authorization
  In order to create a unstructured standalone credit request 
  As a credit workflow front officer having final approver, Intermediary Approver  or the non approver roles
  I should be able to create and search the unstructured standalone manual and non manual authorizations of deal or annual lines type

  Background: 
    Given I am logged in as "Bob.FrontOfficer"

  Scenario: Manual standalone authorization creation with mandatory information
    Given I am in authorization page
    And create authorization with given mandatory information
      | authorization name       | type | category | booking entity         | derogative limit | rct code | business line risk sharing | share | lgd validation | lgd | rating validation | trc                     | amount | initiator |
      | Selenium - Default Autho | New  | Deal     | ALD AUTOLEASING D GMBH | No               | ASD5562  | CORI/CBA                   | 100   | Yes            | 35  | No                | 00030 - Settlement risk | 10m    | 1         |
    And I enter tenor as 5 years
    And I enter expected start date and authorization approval validity as a 15 days from today
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".

  Scenario: Non-manual standalone authorization creation with mandatory information
    Given I am in authorization page
    And create non-manual authorization with mandatory information
    When I save authorization
    Then status should be "Not submitted".

  Scenario: Adding Finance buckets in non-manual authorization
    Given An non-manual authorization with mandatory information
    And I select typology risk credit as "00030 - Settlement risk"
    And bucket duration of 5
    And I add breakdown car values for 5 durations
      | Bucket displayed as Duration | Breakdown CAR Nominal expressed in original currency |
      | 1                            | 1,500,000                                            |
      | 2                            | 1,500,000                                            |
      | 3                            | 1,500,000                                            |
      | 4                            | 1,500,000                                            |
      | 5                            | 1,500,000                                            |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Adding Guarantees And indirect risk in non-manual authorization
    Given An non-manual authorization with mandatory information
    And I add guarantees and indirect risk with below values
      | Type           | percentage of authorization | lgd | bdr id |
      | Bank Guarantor | 60                          | 50  | 22     |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Add Net Amount details in standalone authorization without exclude from Auhosheet impact
    Given An non-manual authorization with mandatory information
    And I add net amount "9.5m" and save it
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Default annual line authorization update
    Given I am in Authorization page having all default values for annual line autho
    And Select administrative/validity date as fixed
    And enter administrative date as 2 year from today
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Standalone Authorization without LGD
    Given I am in Authorization page having partial default values with No LGD validation
    And I set LGD Validation as "No"
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Add Net Amount details in standalone authorization without exclude from Auhosheet impact
    Given An non-manual authorization with mandatory information
    And I add net amount "9.5m" by excluding from authorization sheet
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created.The Authorization is currently excluded from the Global Authorization Report except from Excluded tab".
    And status should be "Not submitted".

  Scenario: Standalone Market authorization creation with Multiple Business Line Risk Sharing
    Given I am in Authorization page having partial mandaroty values
    And the business line risk sharing participants are added as below
      | Business Line Name | Sharing |
      | DSFS/ALD           | 50      |
      | DSFS/SGEF          | 30      |
      | IBFS France        | 20      |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Create a standalone authorization with multiple borrowers
    Given An non-manual authorization with mandatory information
    And I add all Legal Entities as multiple borrowers
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Add Market buckets with CAR values in Authorization having Market TRCs
    Given An non-manual authorization with mandatory information
    And I choose TRC as "00020 - Delivery risk"
    And an authorization with duration 5 years
    And I add below market buckets with CAR/Nominal bucket details till maturity
      | [0D-3D]   | [3D-1M]   | [1M-3M] | [3M-6M] | [6M-12M] | [1Y-2Y] | [2Y-3Y] | [3Y-5Y] |
      | 1,000,000 | 1,000,000 | 900,000 | 850,000 | 800,000  | 850,000 | 750,000 | 700,000 |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Adding Market buckets with CAR or cVaR in Authorization having Market TRCs
    Given An non-manual authorization with mandatory information
    And Authorization maturity duration is 5 years
    And I choose TRC as "00100 - Replacement risk"
    And I add below market buckets with CAR/cVar details till maturity
      | [0D-3D]             | [3D-1M]         | [1M-3M]         | [3M-6M]         | [6M-12M]        | [1Y-2Y]         | [2Y-3Y]         | [3Y-5Y]         |
      | 1,000,000/1,000,000 | 950,000/950,000 | 900,000/900,000 | 850,000/850,000 | 800,000/800,000 | 850,000/850,000 | 750,000/750,000 | 700,000/700,000 |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Add Market buckets with CAR values in Authorization having Market TRCs
    Given An non-manual authorization with mandatory information
    And Authorization maturity duration is 5 years
    And I choose TRC as "00020 - Delivery risk"
    And I add below market buckets with CAR/Nominal bucket details till maturity
      | [0D-3D]   | [3D-1M] | [1M-3M] | [3M-6M] | [6M-12M] | [1Y-2Y] | [2Y-3Y] | [3Y-5Y] |
      | 1,000,000 | 950,000 | 900,000 | 850,000 | 800,000  | 850,000 | 750,000 | 700,000 |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  @wip
  Scenario: Add Net Buckets in authorization having Finance TRCs
    Given An non-manual authorization with mandatory information
    And Authorization maturity duration is 5 years
    And I choose TRC as "00030 - Settlement risk"
    And I add net amount "9.5m"
    And I add below market Net buckets with CAR bucket details till maturity
      | [0D-3D] | [3D-1M] | [1M-3M] | [3M-6M] | [6M-12M] | [1Y-2Y] | [2Y-3Y] | [3Y-5Y] |
      | 950,000 | 950,000 | 900,000 | 850,000 | 800,000  | 850,000 | 750,000 | 700,000 |
    When I save the authosheet data
    And I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  Scenario: Adding Market buckets in for Finance TRcs
    Given An non-manual authorization with mandatory information
    And I select typology risk credit as "00040 - Guaranty"
    And I add below market buckets with CAR bucket details till maturity
      | [0D-3D] | [3D-1M] | [1M-3M] | [3M-6M] | [6M-12M] | [1Y-2Y] | [2Y-3Y] | [3Y-5Y] |
      | 950,000 | 950,000 | 900,000 | 850,000 | 800,000  | 850,000 | 750,000 | 700,000 |
    When I save authorization
    Then authorization is saved successfully with message "The Authorization" <<Autho ID>> "has been successfully created".
    And status should be "Not submitted".

  # Authorization search scenarios
  Scenario: Search manual authorization by group name
    Given I am in authorization search page
    And I check manual authorization option
    When I perform the search by "SBI HOLDINGS INC" group
    Then All authorizations of "SBI HOLDINGS INC" group should be listed

  Scenario: Search and Modification of existing Manual Authorization
    Given I am in authorization search result page and search "SBI HOLDINGS INC"
    When I change the below information in the first authorization and save
      | lgd | amount     |
      | 50  | 10,000,000 |
    Then Autho should be Saved and its status should be "Approved".

  Scenario: Search non-manual authorization by group name
    Given I am in authorization search page
    And I check Draft authorization
    When I perform the search by "SBI HOLDINGS INC" group
    Then All authorizations of "SBI HOLDINGS INC" group should be listed

  Scenario: post approval abandon of manual authorization
    Given a manual authorization with mandatory information
    And status should be "Approved".
    When I search and open the approved manual authorization
    And I do post approval abandon
    Then authorization should be abandoned successfully with message "The Authorization" <<Autho ID>> "has been successfully abandoned post approval".
    And The status should be "Abandon post approval".
