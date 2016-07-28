@cwfsanity
Feature: Renewal/Resubmission Process by Duplicating the Requests
  
  As a credit request user
  I should be able to the requests and easily resubmit his credit request to approval.
  The previous and new requests are linked. The following actions are allowed in this menu

  Background: 
    Given I am logged in as "Bob.FrontOfficer"

  Scenario: duplicating the existing approved request with simple copy option
    Given a request with "Approved"
    When duplicating it by Simple Copy
    And I change the duplicate request name as "Selenium - Default request"
    And I Save As Draft
    Then request should be saved with status "Not submitted"

  Scenario Outline: request duplication by various options
    Given a request with status <currentStatus>
    When I <duplicate> with an <Option>
    And I change the <information> by <value>
    And I Save As Draft
    Then request type should be defaulted with <type>
    Then The status should be "Not submitted"
    And request should be linked with parent request

    Examples: 
      | currentStatus | duplicate               | Option              | information | value  | type                      |
      | "Approved"    | "Renewal/Annual Review" | "With modification" | "Amount"    | "100M" | "Renewal / annual review" |
      | "Approved"    | "Amendment/Waiver"      | "with modification" | "LGD"       | "40"   | "Amendment / Waiver"      |
      | "Approved"    | "Resubmission"          | ""                  | ""          | ""     | ""                        |
      | "Approved"    | "Temporary Extension"   | ""                  | "LGD"       | "40"   | "Temporary extension"     |
      | "Approved"    | "Interim Request"       | ""                  | "Amount"    | "600M" | "Interim request"         |
      | "Approved"    | "Reallocation"          | ""                  | "LGD"       | "40"   | ""                        |

  Scenario Outline: request duplication - without modification
    Given a request with "Approved"
    When I <duplicate> it with "No modification"
    Then all existing authorizations should be deleted
    And read only dummy authorization should get attached
    When I kick off the request
    Then The status should be "In progress"
    And request should be linked with parent request

    Examples: 
      | duplicate               |
      | "Renewal/Annual Review" |
      | "Amendment/Waiver"      |

