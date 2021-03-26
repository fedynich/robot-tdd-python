*** Settings ***
Documentation                   Verification of Change Password Functionality
Library                         Selenium2Library

Test Setup                      Open test browser
Test Template                   Submit Changed Password
Suite Teardown                  Close all test browsers

*** Variables ***
${URL}                          {placeholder}
${BROWSER}                      chrome

${VALID_OLD_PASSWORD}           Earth15
${VALID_NEW_PASSWORD}           Earth16
${VALID_CONFIRM_PASSWORD}       Earth16
${XSS}                          1'"()%26%25<acx><ScRiPt%20>ohKJ(9820)</ScRiPt>

${PASS_CHANGED_MESSAGE}         xpath=//div[@class='ok' and contains(text(), 'changed')]
${FAIL_LENGTH_MESSAGE}          xpath=//div[@class='err' and contains(text(), '4-8 characters')]
${FAIL_INVALID_OLD_MESSAGE}     xpath=//div[@class='err' and contains(text(), 'incorrect current password')]
${FAIL_MATCH_MESSAGE}           xpath=//div[@class='err' and contains(text(), 'does not match')]
${FAIL_SAME_MESSAGE}            xpath=//div[@class='err' and contains(text(), 'cannot be the same')]
${FAIL_BLANK_CURRECT_MESSAGE}   xpath=//div[@class='err' and contains(text(), 'Enter current password')]
${FAIL_BLANK_NEW_MESSAGE}       xpath=//div[@class='err' and contains(text(), 'Enter new password')]
${FAIL_BLANK_CONFIRM_MESSAGE}   xpath=//div[@class='err' and contains(text(), 'Enter confirm password')]

#--- this message does not exists, but it is expected by requirements  --
${FAIL_NUMBER_CAPITAL_MESSAGE}  xpath=//div[@class='err' and contains(text(), 'at least one number and capital letter')]

${FAIL_NUMBER_MESSAGE}          xpath=//div[@class='err' and contains(text(), 'at least one number')]
${FAIL_CAPITAL_MESSAGE}         xpath=//div[@class='err' and contains(text(), 'at least one capital letter')]
${FAIL_SPACES_BETWEEN_MESSAGE}  xpath=//div[@class='err' and contains(text(), 'cannot contain spaces')]
${FAIL_LENGTH_MESSAGE}          xpath=//div[@class='err' and contains(text(), '4-8 characters')]
${FAIL_ACCESS_DENIED_MESSAGE}   xpath=//div[@class='err' and contains(text(), 'Access Denied')]


*** Test Cases ***                                      OLD_PASSWORD            NEW_PASSWORD            CONFIRM_PASSWORD            MESSAGE_RESULT
Valid All the Fields                                    ${VALID_OLD_PASSWORD}   ${VALID_NEW_PASSWORD}   ${VALID_CONFIRM_PASSWORD}   ${PASS_CHANGED_MESSAGE}
Invalid Old, Valid New password                         Earth14                 ${VALID_NEW_PASSWORD}   ${VALID_CONFIRM_PASSWORD}   ${FAIL_INVALID_OLD_MESSAGE}
New and Confirm Fields don't match                      ${VALID_OLD_PASSWORD}   ${VALID_NEW_PASSWORD}   Earth17                     ${FAIL_MATCH_MESSAGE}
New and Old passwords cannot be the same                ${VALID_OLD_PASSWORD}   ${VALID_OLD_PASSWORD}   ${VALID_OLD_PASSWORD}       ${FAIL_SAME_MESSAGE}

Blank All the Fields                                    ${EMPTY}                ${EMPTY}                ${EMPTY}                    ${FAIL_BLANK_CURRECT_MESSAGE}
Blank Old Password Field                                ${EMPTY}                ${VALID_NEW_PASSWORD}   ${VALID_CONFIRM_PASSWORD}   ${FAIL_BLANK_CURRECT_MESSAGE}
Blank New Password Field                                ${VALID_OLD_PASSWORD}   ${EMPTY}                ${VALID_CONFIRM_PASSWORD}   ${FAIL_BLANK_NEW_MESSAGE}
Blank Confirm Password Field                            ${VALID_OLD_PASSWORD}   ${VALID_NEW_PASSWORD}   ${EMPTY}                    ${FAIL_BLANK_CONFIRM_MESSAGE}
Blank New and Confirm Password Fields                   ${VALID_OLD_PASSWORD}   ${EMPTY}                ${EMPTY}                    ${FAIL_BLANK_NEW_MESSAGE}

#--- Expect to Fail:should be both Capital and Number message ---
Password has least One Number and One Capital Letter    ${VALID_OLD_PASSWORD}   earth                   earth                       ${FAIL_NUMBER_CAPITAL_MESSAGE}
Password has least One Capital Letter                   ${VALID_OLD_PASSWORD}   earth17                 earth17                     ${FAIL_CAPITAL_MESSAGE}
Password has least One Number                           ${VALID_OLD_PASSWORD}   earth                   earth                       ${FAIL_NUMBER_MESSAGE}

#--- Expect to Fail:
Only Spaces in Blank New and Confinm Fields             ${VALID_OLD_PASSWORD}   ${SPACE}                ${SPACE}                    ${FAIL_BLANK_NEW_MESSAGE}

#--- Expect to Fail --
Password contains Spaces                                ${VALID_OLD_PASSWORD}   Word1${SPACE}word2      Word1${SPACE}word2          ${FAIL_SPACES_BETWEEN_MESSAGE}

MAX Limit for Password - 8 characters                   ${VALID_OLD_PASSWORD}   Earth16!                Earth16!                    ${PASS_CHANGED_MESSAGE}
MIN Limit for Password - 4 characters                   ${VALID_OLD_PASSWORD}   Pas1                    Pas1                        ${PASS_CHANGED_MESSAGE}
#--- Expect to Fail ---
MAX Limit for Password - 9 characters                   ${VALID_OLD_PASSWORD}   Earth167!               Earth167!                   ${FAIL_LENGTH_MESSAGE}
MIN Limit for Password - 3 characters                   ${VALID_OLD_PASSWORD}   Pa1                     Pa1                         ${FAIL_LENGTH_MESSAGE}

#--- Expect to Fail --
Password XSS Protected                                  ${VALID_OLD_PASSWORD}   ${XSS}                  ${XSS}                      ${FAIL_ACCESS_DENIED_MESSAGE}

#--- Expect to Fail: because of capital russian Ц
Password supports UNICODE                               ${VALID_OLD_PASSWORD}   उനЬa#ɊЦ1               उനЬa#ɊЦ1                    ${PASS_CHANGED_MESSAGE}


*** Keywords ***
Open test browser
    Open browser                    ${URL}                  ${BROWSER}

#Finish
Open Change Password Page
    Go To                           ${URL}                  ${BROWSER}
    Maximize Browser Window

Submit Changed Password
    [Arguments]                     ${OLD_PASSWORD}         ${NEW_PASSWORD}     ${CONFIRM_PASSWORD}     ${MESSAGE_RESULT}
    Input Old Password              ${OLD_PASSWORD}
    Input New Password              ${NEW_PASSWORD}
    Input Confirm Password          ${CONFIRM_PASSWORD}
    Submit Credentials
    Message Displayed               ${MESSAGE_RESULT}

Input Old Password
    [Arguments]                     ${old_password}
    Input Text                      xpath=//input[@name='cur_password']       ${old_password}

Input New Password
    [Arguments]                     ${new_password}
    Input Text                      xpath=//input[@name='new_password']       ${new_password}

Input Confirm Password
    [Arguments]                     ${confirm_password}
    Input Text                      xpath=//input[@name='confirm_password']   ${confirm_password}

Submit Credentials
    Click Button                    xpath=//input[@name='submit']

Message Displayed
    [Arguments]                     ${message}
    Page Should Contain Element     ${message}

Close all test browsers
    Close all browsers

