package com.financingplatform.e2etests.cwf.stepdefs;

import static com.financingplatform.e2etests.cwf.pages.CWFPages.*;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.financingplatform.e2etests.common.page.LoginPage;
import com.financingplatform.e2etests.cwf.model.ActivityReport;
import com.financingplatform.e2etests.cwf.model.Authorization;
import com.financingplatform.e2etests.cwf.model.AuthorizationFactory;
import com.financingplatform.e2etests.cwf.model.AuthorizationForAuthoSheet;
import com.financingplatform.e2etests.cwf.model.BusinessLine;
import com.financingplatform.e2etests.cwf.model.FinanceBuckets;
import com.financingplatform.e2etests.cwf.model.GuaranteesIndirectRisk;
import com.financingplatform.e2etests.cwf.model.RequestFactory;
import com.financingplatform.e2etests.cwf.model.World;
import com.financingplatform.e2etests.util.UrlVault;

import cucumber.api.DataTable;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

public class CWFModulesStepDefinition {

    private final World world;

    public CWFModulesStepDefinition(World world) {
        this.world = world;
    }

    // Scenario: Manual standalone authorization creation

    @Given("^I am logged in as \"([^\"]*)\"$")
    public void i_am_logged_in_as(String logInUser) throws Throwable {
        String url = UrlVault.getUrl(UrlVault.PORTAL);
        LoginPage loginPage = new LoginPage();
        loginPage.loginUserAs(logInUser, url);
    }

    @Given("^I am in authorization page$")
    public void i_am_in_authorization_page() {
        goToAuthorizationPage(true);
    }

    @Given("^create authorization with given mandatory information$")
    public void create_authorization_with_given_mandatory_information(
            List<Authorization> authorizations) throws Throwable {
        goToAuthorizationPage().andCreateAuthoWithMandatoryInformation(
                authorizations.get(0));
    }

    @Given("^I enter expected start date and authorization approval validity as a (\\d+) days from today$")
    public void i_enter_expected_start_date_and_authorization_approval_validity_as_days_from_today(
            int duration) throws Throwable {
        goToAuthorizationPage()
                .setAuthorizationExpectedStartAndApprovalValidityDate(duration);
    }

    @Given("^I enter tenor as (\\d+) years$")
    public void tenor_is_Years(String tenor) throws Throwable {
        goToAuthorizationPage().setDuration(tenor);
    }

    @When("^I save authorization$")
    public void i_save_it() throws Throwable {
        goToAuthorizationPage().saveAuthorization();
    }

    @Then("^authorization is saved successfully with message \"([^\"]*)\" <<Autho ID>> \"([^\"]*)\"\\.$")
    public void authorization_is_saved_successfully_with_message_Autho_ID(
            String messageFirstPart, String messageSecondPart) throws Throwable {
        goToAuthorizationPage().authoIsSavedSuccessfully(messageFirstPart,
                messageSecondPart);
    }

    // Scenario: Non-manual standalone authorization creation with mandatory
    // information

    @Given("^create non-manual authorization with mandatory information$")
    public void a_authorization_with_mandatory_information() throws Throwable {
        goToAuthorizationPage(true).createNonManualAutho()
                .withMandatoryInformation();
    }

    @Then("^status should be \"([^\"]*)\"\\.$")
    public void status_should_be(String status) throws Throwable {
        goToAuthorizationPage().statusIsXXX(status);
    }

    // Scenario: Adding Finance buckets in non-manual authorization

    @Given("^An non-manual authorization with mandatory information$")
    public void an_authorization_with_mandatory_information() {
        goToAuthorizationPage(true).createNonManualAutho()
                .withMandatoryInformation();
    }

    @When("^I select typology risk credit as \"([^\"]*)\"$")
    public void i_select_typology_risk_credit_as(String trc) throws Throwable {
        goToAuthorizationPage().setTRCDetails(trc);
    }

    @When("^bucket duration of (\\d+)$")
    public void bucket_duration_of(int bucketDuration) throws Throwable {
        goToAuthorizationPage().setDurationForBuckets(bucketDuration);
    }

    @When("^I add breakdown car values for (\\d+) durations$")
    public void i_should_be_able_add_Breakdown_CAR_values_for_durations(
            int duration, List<FinanceBuckets> financeBuckets) throws Throwable {
        goToAuthorizationPage().setBucketsForFinanceTrc(duration,
                financeBuckets);
    }

    // Scenario: Add Net Amount details in standalone authorization without
    // exclude from Auhosheet impact

    @Given("^I add net amount \"([^\"]*)\" and save it$")
    public void i_add_net_amount_and_save(String netAmount) throws Throwable {
        goToAuthorizationPage().addNetAmountDetails().addNetAmountAndSave(
                netAmount);
    }

    // Scenario: Adding Guarantees And indirect risk in non-manual authorization


    @Given("^I add guarantees and indirect risk with below values$")
    public void i_added_Guarantees_and_indirect_risk_with_below_values(
            List<GuaranteesIndirectRisk> guranteesIndirectRisks) {
        goToAuthorizationPage().addGuaranteesAndIndirectRisk(
                guranteesIndirectRisks);
    }

    // ------ Add Market buckets with CAR values in Authorization having Market
    // TRCs

    @Given("^I add net amount \"([^\"]*)\"$")
    public void i_add_net_amount(String netAmount) throws Throwable {
        goToAuthorizationPage().addNetAmountDetails().addNetAmount(
                netAmount);
    }

    @Given("^an authorization with duration (\\d+) years$")
    public void an_authorization_with_Duration_years(String duration)
            throws Throwable {
        goToAuthorizationPage().setDuration(duration);
    }

    @When("^I choose TRC as \"([^\"]*)\"$")
    public void i_choose_TRC_as(String trc) throws Throwable {
        goToAuthorizationPage().setTRCDetails(trc);
    }

    @Then("^I add below market buckets with CAR/Nominal bucket details till maturity$")
    public void i_should_be_able_to_add_below_market_buckets_with_cVar_details_till_maturity(
            DataTable marketBuckets) throws Throwable {
        goToAuthorizationPage().fillMarketTrcBuckets(marketBuckets);
    }

    // Scenario: Adding Market buckets with CAR/cVaR in Authorization having
    // Market TRCs

    @Given("^Authorization maturity duration is (\\d+) years$")
    public void authorization_maturity_Duration_is_years(String duration)
            throws Throwable {
        goToAuthorizationPage().setDuration(duration);
    }

    @Then("I add below market buckets with CAR/cVar details till maturity$")
    public void i_should_be_able_to_add_below_market_buckets_with_CAR_cVar_details_till_maturity(
            DataTable buckets) throws Throwable {
        goToAuthorizationPage().fillMarketTrcBuckets(buckets);
    }

    // Scenario: Default annual line authorization creation

    @Given("^I am in Authorization page having all default values for annual line autho$")
    public void i_am_in_Authorization_page_having_all_default_values_for_annual_line_autho()
            throws Throwable {
        goToAuthorizationPage(true)
                .createNewAuthorizationWithDefaultValuesForAnnualLine(
                        createDefaultAnnualLineAuthoFromFactory()).setDuration(
                        "5");
    }

    @Given("^Select administrative/validity date as fixed$")
    public void select_administrative_validity_date_as_Fixed() throws Throwable {
        goToAuthorizationPage().setFixedAuthorization();
    }

    @Given("^enter administrative date as (\\d+) year from today$")
    public void enter_Administrative_Date_as_Year_from_today(int year)
            throws Throwable {
        int days = Math.multiplyExact(year, 365);
        goToAuthorizationPage().fillAdministrativeDate(days);
    }

    private List<Authorization> createDefaultAnnualLineAuthoFromFactory() {
        Authorization authorization = AuthorizationFactory
                .getAuthorizationForAnnualLine();
        List<Authorization> authorizations = new ArrayList<Authorization>();
        authorizations.add(authorization);
        return authorizations;
    }

    // Scenario: Standalone Authorization without LGD

    @Given("^I am in Authorization page having partial default values with No LGD validation$")
    public void i_am_in_Authorization_page_having_partial_default_values_with_No_LGD_validation()
            throws Throwable {
        goToAuthorizationPage(true).createAuthorizationWithNoValidation();
    }

    @Given("^I set LGD Validation as \"([^\"]*)\"$")
    public void i_set_LGD_Validation_as(String lgd) throws Throwable {
        goToAuthorizationPage().setLgdValidation(lgd);
    }

    // Scenario: Add Net Amount details in standalone authorization without
    // exclude from Auhosheet impact

    @When("^I add net amount \"([^\"]*)\" by excluding from authorization sheet$")
    public void i_add_net_amount_by_excluding_from_authorization_sheet(
            String newAmount) throws Throwable {
        goToAuthorizationPage().checkExcludeAuthorization(newAmount);
    }

    // Scenario: Standalone Market authorization creation with Multiple Business
    // Line Risk Sharing

    @Given("^I am in Authorization page having partial mandaroty values$")
    public void i_am_in_Authorization_page_having_partial_default_values() {
        goToAuthorizationPage(true)
                .createPartialDefaultAuthoWithDurationFiveYears();
    }

    @Given("^the business line risk sharing participants are added as below$")
    public void the_business_line_risk_sharing_participants_are_added_as_below(
            List<BusinessLine> businessLines) throws Throwable {
        goToAuthorizationPage().addBusinessLinesAndShare(businessLines);
    }

    // Scenario: Create a standalone authorization with multiple borrowers

    @Given("^I add all Legal Entities as multiple borrowers$")
    public void i_add_all_Legal_Entities_as_multiple_borrowers()
            throws Throwable {
        goToAuthorizationPage().addBorrowerAuthorizationCounterparty();
    }

    @When("^I save the authosheet data$")
    public void i_save_the_authosheet_data() throws Throwable {
        goToAuthorizationPage().saveAuthorizationSheetData();
    }

    // ***** CWF Request Management***********************************//

    // Scenario: Standalone credit workflow request with default mandatory
    // fields

    @Given("^I am in New Request page$")
    public void i_am_in_request_management_page() throws Throwable {
        goToRequestManagementPage().newRequest();
    }

    @Given("^request is being created with default mandatory information$")
    public void request_is_being_created_with_default_mandatory_information() {

        goToNewRequestPage().fillMandatoryValueForRequestCreation(
                RequestFactory.getRequestnWithDefaultData());
    }

    @Given("^create two authorizations of market TRCs$")
    public void create_two_authorizations_of_market_TRCs() throws Throwable {
        goToNewRequestPage().createAndAttachAuthoInRequest();
    }

    @When("^I Save As Draft$")
    public void i_Save_As_Draft() throws Throwable {
        goToNewRequestPage().saveAsDraft();
    }

    @Then("^request should be saved with status \"([^\"]*)\"$")
    public void request_should_be_saved_with_status(String status)
            throws Throwable {
        goToNewRequestPage().checkStatusOfRequest(status);
    }

    @Then("^it should appear in \"([^\"]*)\"$")
    public void it_should_appear_in(String tabName) throws Throwable {
        String reqId = goToNewRequestPage().copyRequestId();
        goToToDoListPage().newToDoList().goToSpecificTab(tabName).assertRequestIdInToDoList(tabName, reqId);
    }

    // Scenario: Standalone credit workflow request with default mandatory
    // fields and Detach the Authorization
    @Given("^a request is being created with default mandatory information$")
    public void a_request_is_being_created_with_default_mandatory_information()
            throws Throwable {
        goToRequestManagementPage().newRequest();
        goToNewRequestPage().fillMandatoryValueForRequestCreation(
                RequestFactory.getRequestnWithDefaultData());
    }

    @When("^I kick off the request$")
    public void i_kick_off_the_request() throws Throwable {
        goToNewRequestPage().kickOffRequest();
    }

    @When("^I select the authorization and click detach$")
    public void i_select_the_authorization_and_click_detach() throws Throwable {
        goToNewRequestPage().clickAuthorizationAndDetach();
    }

    @When("^I select the authorization and click copy$")
    public void i_select_the_authorization_and_click_copy() throws Throwable {
        goToNewRequestPage().selectAuthorizationAndCopy();
    }

    // ------ Search manual authorization by group name

    @Given("^I am in authorization search page$")
    public void i_am_in_authorization_search_page() throws Throwable {
        goToAuthorizationSearchPage(true);
    }

    @Given("^I check manual authorization option$")
    public void i_check_manual_authorization_option() throws Throwable {
        goToAuthorizationSearchPage().setManualAuthorization();
    }

    @When("^I perform the search by \"([^\"]*)\" group$")
    public void i_perform_the_search_by_group(String groupName)
            throws Throwable {
        goToAuthorizationSearchPage().searchAuthoByGroupName(groupName);
    }

    @Then("^All authorizations of \"([^\"]*)\" group should be listed$")
    public void all_authorizations_of_group_should_be_listed(String groupName)
            throws Throwable {
        goToAuthorizationSearchPage().isGroup(groupName);
    }

    // ------ Search and Modification of existing Manual Authorization

    @Given("^I am in authorization search result page and search \"([^\"]*)\"$")
    public void i_am_in_authorization_search_result_page(String groupName)
            throws Throwable {
        goToAuthorizationSearchPage(true).setManualAuthorization().searchResult(groupName, "Selenium");
    }

    @When("^I change the below information in the first authorization and save$")
    public void i_change_the_below_information_in_the_first_authorization(
            List<Authorization> authorizations) throws Throwable {
        Authorization authorization = AuthorizationFactory
                .getAuthorizationWithDefaultData();
        for (int i = 0; i < authorizations.size(); i++) {
            authorization.setAmount(authorizations.get(i).getAmount());
            authorization.setLgd((authorizations.get(i).getLgd()));
        }
        goToAuthorizationSearchPage()
                .selectAuthorizationToModify(authorization);
    }

    @Then("^Autho should be Saved and its status should be \"([^\"]*)\"\\.$")
    public void autho_should_be_Saved_and_its_status_should_be(String status)
            throws Throwable {
        goToAuthorizationSearchPage().checkManualAuthorizationStatus(status);
    }

    @When("^I Save the Authorization$")
    public void i_Save_the_Authorization() throws Throwable {
        goToAuthorizationPage().saveAuthorization();
    }

    // ------ Search non-manual authorization by group name

    @When("^I check Draft authorization$")
    public void i_check_Draft_authorization() throws Throwable {
        goToAuthorizationSearchPage().selectDraftAuthorization();
    }

    // ------ Add Net Buckets in authorization having Finance TRcs

    @Then("^I add below market Net buckets with CAR bucket details till maturity$")
    public void i_should_be_able_to_add_below_market_Net_buckets_with_CAR_bucket_details_till_maturity(
            DataTable marketBuckets) throws Throwable {
        goToAuthorizationPage().addMarketNetAmountBuckets(marketBuckets);
    }

    @Given("^Duration is (\\d+) Years$")
    public void duration_is_Years(String duration) throws Throwable {
        goToAuthorizationPage().setDuration(duration);
    }

    // ---------Define workflow participants for the request

    @Given("^the below team were invited as a \"([^\"]*)\" in the work flow$")
    public void the_below_team_were_invited_as_a_in_the_work_flow(
            String invitedAs, List<String> teams) throws Throwable {
        goToNewRequestPage().searchTeamsAndAddToTheWorkflow(invitedAs, teams);
    }

    @Given("^the below CCG teams were \"([^\"]*)\"$")
    public void the_below_CCG_teams_were(String invitedAs, List<String> teams)
            throws Throwable {
        goToNewRequestPage().searchTeamsAndAddToTheWorkflow(invitedAs, teams);

    }

    @When("^I validate the workflow and save the request$")
    public void i_validate_the_workflow_and_save_the_request() throws Throwable {
        goToNewRequestPage().saveAsDraft();
    }

    // -----------Define workflow participants for Insider request

    @When("^I mark the request as a Insider$")
    public void i_mark_the_request_as_a_Insider() throws Throwable {
        goToNewRequestPage().markRequestAsInsider();
    }

    @When("^The below users are invited as \"([^\"]*)\" in the work flow$")
    public void the_below_users_are_invited_as_in_the_work_flow_richard_bernal(
            String invitedAs, List<String> addressees) throws Throwable {
        goToNewRequestPage().searchAddresseeAndAddToTheWorkflow(invitedAs,
                addressees);
    }

    @Then("^\"([^\"]*)\" and \"([^\"]*)\" options should not be available$")
    public void and_options_should_not_be_available(String arg1, String arg2)
            throws Throwable {
        assertThat(
                goToNewRequestPage()
                        .isCheckRemainingLinesAndSearchAuthoOptionVisible())
                .isFalse();
    }

    @Then("^Request should be marked as \"([^\"]*)\"$")
    public void request_should_be_marked_as(String requestType)
            throws Throwable {
        goToNewRequestPage().isRequestInsider(requestType);
    }

    // ----------------Tree request creation

    @When("^I mark the request as a Tree$")
    public void i_mark_the_request_as_a_Tree() throws Throwable {
        goToNewRequestPage().markRequestAsTree();
    }

    @Then("^\"([^\"]*)\" option should not be available$")
    public void options_should_not_be_available(String arg1) throws Throwable {
        assertThat(goToNewRequestPage().isSearchAuthoOptionVisible()).isFalse();
    }

    // ****************************************Activity Report**********//

    @Given("^I am in create activity page$")
    public void i_am_in_create_activity_page() throws Throwable {
        goToActivityReportPage(true);
    }

    @Given("^activity is being created with below mandatory information$")
    public void activity_is_being_created_with_below_mandatory_information(
            List<ActivityReport> activityreports) throws Throwable {
        goToActivityReportPage().createNewActivityReportWithDefaultValues(
                activityreports.get(0));

    }

    @When("^I Save the activity$")
    public void i_Save_the_activity() throws Throwable {
        goToActivityReportPage().save();

    }

    @Then("^Activity should be saved with message \"([^\"]*)\"$")
    public void activity_should_be_saved_with_message(String message)
            throws Throwable {
        goToActivityReportPage().activityReportShouldSaveByMessage(message);
    }

    @When("^I copy the reference Id and search for the Id in activity report search Page$")
    public void i_copy_the_reference_Id_and_search_for_the_Id_in_activity_report_search_Page()
            throws Throwable {
        String referenceId = goToActivityReportPage().getActivityReferenceId();
        goToActivitySearchPage().searchActivityReportWithReferenceId(
                referenceId);
        world.setReferenceId(referenceId);

    }

    @Then("^I should be able to see the corresponding request$")
    public void i_should_be_able_to_see_the_corresponding_request()
            throws Throwable {
        assertThat(
                goToActivitySearchPage().isActivityReportFound(
                        world.getReferenceId())).isTrue();
    }

    // manual activity request search from the activity report module

    @Given("^an activity created manually$")
    public void an_activity_created_manually() throws Throwable {
        goToActivityReportPage().redirectToActivityReport().save();
    }

    @Given("^I am in activity search page$")
    public void i_am_in_activity_search_page() throws Throwable {
        String message = "Activity with reference ID XXXX_XX_XXXXXX has been saved/updated successfully";
        goToActivityReportPage().activityReportShouldSaveByMessage(message);

    }

    @When("^I do search by reference id$")
    public void i_do_search_by_reference_id() throws Throwable {
        String referenceId = goToActivityReportPage().getActivityReferenceId();
        goToActivitySearchPage().searchActivityReportWithReferenceId(
                referenceId);
        world.setReferenceId(referenceId);
    }

    @Then("^I should be able to see created activity request$")
    public void i_should_be_able_to_see_created_activity_request()
            throws Throwable {
        assertThat(
                goToActivitySearchPage().isActivityReportFound(
                        world.getReferenceId())).isTrue();
    }

    // Excluding the request from activity report

    @Given("^I am in activity searchpage$")
    public void i_am_in_activity_searchpage() throws Throwable {
        goToActivitySearchPage();
    }

    @When("^I do filter by source \"([^\"]*)\"$")
    public void i_do_filter_by_source(String source) throws Throwable {
        goToActivitySearchPage().filterBySource(source);
    }

    @When("^I Exclude the first request from activity report$")
    public void i_Exclude_the_first_request_from_activity_report()
            throws Throwable {
        goToActivitySearchPage().excludeFirstRequest();
    }

    @Then("^request should be marked as Excluded and appear in red colur$")
    public void request_should_be_marked_as_Excluded_and_appear_in_red_colur()
            throws Throwable {
        assertThat(goToActivitySearchPage().isActivityExcluded()).isTrue();
    }

    @Given("^a request is created and kick off request$")
    public void a_request_is_created_and_kick_off_request() throws Throwable {
        goToActivityReportPage().redirectToActivityReport().save();
        String referenceId = goToActivityReportPage().getActivityReferenceId();
        world.setReferenceId(referenceId);
    }

    @When("^I do a activity search by request id in the activity report$")
    public void i_do_a_activity_search_by_request_id_in_the_activity_report()
            throws Throwable {
        goToActivitySearchPage().searchActivityReportWithReferenceId(
                world.getReferenceId());
    }

    @Then("^I should be able to see it in List")
    public void i_should_be_able_to_see_it_in_List() throws Throwable {
        assertThat(
                goToActivitySearchPage().isActivityReportFound(
                        world.getReferenceId())).isTrue();
    }

    @Given("^I am in Generate Report page$")
    public void i_am_in_Generate_Report_page() throws Throwable {
        goToGenerateReportPage();

    }

    @When("^Generate the report$")
    public void generate_the_report() throws Throwable {
        goToGenerateReportPage().generateActivityReport();
    }

    @Then("^Excel report should be generated$")
    public void excel_report_should_be_generated() throws Throwable {
        // Outside of application. No check
    }

    //*******************Credit Approval Process**************************
    @Given("^a request with \"([^\"]*)\"$")
    public void a_request_with(String requestStatus) throws Throwable {
        goToRequestSearchPage(true).getRequestForApproval("Selenium - Default request", requestStatus);
    }

    @When("^I give my \"([^\"]*)\" with \"([^\"]*)\"$")
    public void i_give_my_with(String responseType, String comment)
            throws Throwable {
        goToRequestSearchPage().giveResponseTypeWithComment(responseType,
                comment);
    }

    @When("^I submit \"([^\"]*)\" for \"([^\"]*)\"$")
    public void i_submit_for(String response, String responseType) throws Throwable {
        goToRequestSearchPage().submitResponse(response, responseType);
    }

    @Then("^The status should be \"([^\"]*)\"$")
    public void the_status_should_be(String newStatusOfRequest)
            throws Throwable {
        goToRequestSearchPage().validateNewRequestStatus(newStatusOfRequest);
    }

    @Then("^the \"([^\"]*)\" should be \"([^\"]*)\"$")
    public void the_should_be(String latestResponseType, String finalResponse)
            throws Throwable {
        goToRequestSearchPage().validateLatestResponseTypeAndFinalResponse(
            latestResponseType, finalResponse);
    }

    // ********************Add Documents***********************

    @When("^I add test document to the request$")
    public void i_add_test_document_to_the_request() throws Throwable {
        goToNewRequestPage().createTestFile().addDocument();
    }

    @Then("^the test document should be attached to the request with restricted access No$")
    public void the_test_document_should_be_attached_to_the_request_with_restricted_access_No()
            throws Throwable {
        goToNewRequestPage().selectCategory().addAll();
    }

    @Given("^a request is being created with below name$")
    public void a_request_is_being_created_with_below_name(List<String> requestName) throws Throwable {
        goToRequestManagementPage().newRequest().createComplexRequestWithMandatoryInfo(requestName.get(0));
    }

    @Given("^create and attach the below market authorizations$")
    public void create_and_attach_the_below_market_authorizations(List<AuthorizationForAuthoSheet> authorizationList) throws Throwable {
        authorizationList.stream().forEach(authorization -> {
            goToNewRequestPage().goToAuthorizationPageFromRequestPage().fillAuthoInfoFromAuthorizationDetails(authorization, false, true).saveAuthorization();
        });
    }

    @Given("^create a ceiling \"([^\"]*)\"  of \"([^\"]*)\" ceiling amount by attaching the above authorizations with comments \"([^\"]*)\"$")
    public void create_a_ceiling_of_ceiling_amount_by_attaching_the_above_authorizations_with_comments(String ceilingName, String ceilingAmount, String comments) throws Throwable {
        goToNewRequestPage().goToCeilingPageFromRequestPage().fillCeilingName(ceilingName).fillCeilingAmount(ceilingAmount).fillComments(comments).save();
    }

    @Given("^create and attach the below finance authorizations and add Breakdown CAR values for (\\d+) durations$")
    public void create_and_attach_the_below_finance_authorizations_and_add_Breakdown_CAR_values_for_durations(int duration, List<AuthorizationForAuthoSheet> authorizationList) throws Throwable {
        authorizationList.stream().forEach(authorization -> {
            goToNewRequestPage().goToAuthorizationPageFromRequestPage().fillAuthoInfoFromAuthorizationDetails(authorization, false, true)
            .saveAuthorization();
        });
    }

    @Given("^invite the below users in the work flow$")
    public void invite_the_below_users_in_the_work_flow(Map<String, String> usersDetails) throws Throwable {
        goToWorkFlowPage().inviteUsers(usersDetails);
    }

    @Given("^invite one \"([^\"]*)\" team as \"([^\"]*)\"$")
    public void invite_one_team_as(String profileName, String inviteAs) throws Throwable {
        goToWorkFlowPage().selectProfileAndInviteTeam(profileName, inviteAs);
    }

    //**************Add Notes/Documents*********************

    @Given("^I am in add notes/documents page$")
    public void i_am_in_add_notes_documents_page() throws Throwable {
        goToRequestSearchPage().addNotesOrDocuments();
    }

    @When("^I add the test document to the request$")
    public void i_add_the_test_document_to_the_request() throws Throwable {
        goToNewRequestPage().createTestFile().addDocument().selectCategory()
        .addAll();
    }

    @When("^add my comment as a note \"([^\"]*)\"$")
    public void add_my_comment_as_a_note(String comment) throws Throwable {
        goToRequestSearchPage().comments(comment);
    }

    @Then("^the document should be attached$")
    public void the_document_should_be_attached() throws Throwable {
        goToRequestSearchPage().verifyDocumentAttachment();
    }

    @When("^I submit my response$")
    public void i_submit_my_response() throws Throwable {
        goToRequestSearchPage().submitResponseForNotEligibleLGDAndCreditResponse();
    }

    @Then("^the latest response type should be \"([^\"]*)\"$")
    public void the_latest_response_type_should_be(String latestResposeType) throws Throwable {
        goToRequestSearchPage().latestResponse(latestResposeType);
    }

    @When("^I Add Test Document to the request$")
    public void i_Add_Test_Document_to_the_request() throws Throwable {
        goToNewRequestPage().createTestFile().addDocument().selectCategory().addAll();
    }

    @Then("^document should be attached$")
    public void document_should_be_attached() throws Throwable {
        goToRequestSearchPage().verifyDocumentAttachment();
    }

    //******************CWF Approval information needed request and response*********************//

    @When("^I save workflow$")
    public void i_save_workflow(){
        goToWorkFlowPage().saveWorkflow();
    }

    @When("^I give \"([^\"]*)\" with team \"([^\"]*)\"$")
    public void i_give_with_team(String responseType, String team) throws Throwable {
        goToRequestSearchPage().giveResponseWithTeam(responseType,team);
    }

    @When("^I give my response as \"([^\"]*)\" from \"([^\"]*)\" team with \"([^\"]*)\" as comment$")
    public void i_give_my_response_as_from_team_with_as_comment(String response, String team, String comment) throws Throwable {
       goToRequestSearchPage().giveResponseTypeAndSelectTeamWithComment(response,team,comment);
    }

    @Then("^the latest response should be \"([^\"]*)\"$")
    public void the_latest_response_should_be(String latestResposeType) throws Throwable {
        goToRequestSearchPage().latestResponse(latestResposeType);
    }

    //***************************Adding Market buckets in for Finance TRcs*********************//

    @Given("^I add below market buckets with CAR bucket details till maturity$")
    public void i_add_below_market_buckets_with_CAR_bucket_details_till_maturity(DataTable marketBuckets) {
        goToAuthorizationPage().fillMarketTrcBucketsWithCarBucketDetails(marketBuckets);
    }

    //******************************post approval abandon of manual authorization**********************//

    @Given("^a manual authorization with mandatory information$")
    public void a_manual_authorization_with_mandatory_information() throws Throwable {
        goToAuthorizationPage(true).createManualAutho()
        .withMandatoryInformation().copyAuthoId();
        goToAuthorizationPage().saveAuthorization();
    }

    @When("^I search and open the approved manual authorization$")
    public void i_search_and_open_the_approved_manual_authorization() throws Throwable {
        goToAuthorizationSearchPage(true);
        goToAuthorizationSearchPage().searchAndOpenAutho();
    }

    @When("^I do post approval abandon$")
    public void i_do_post_approval_abandon() throws Throwable {
        goToAuthorizationViewPage().abandonPostApproval();
    }

    @Then("^authorization should be abandoned successfully with message \"([^\"]*)\" <<Autho ID>> \"([^\"]*)\"\\.$")
    public void authorization_should_be_abandoned_successfully_with_message_Autho_ID(String messageFirstPart, String messageSecondPart) throws Throwable {
        goToAuthorizationViewPage().validateAuthoAbandonedSuccessfully(messageFirstPart,
                messageSecondPart);
    }

    @Then("^The status should be \"([^\"]*)\"\\.$")
    public void The_status_should_be(String status) throws Throwable {
        goToAuthorizationViewPage().statusIsXXX(status);
    }


}
