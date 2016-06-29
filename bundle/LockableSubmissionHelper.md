## Overview

The LockableSubmissionHelper is a utility for retrieving and managing "lockable" submissions.  
Submission locking is used to ensure that Submissions to which multiple people have access to (such 
as Approvals, Fulfillments, or Tickets) can only be worked on by one user at a time.

### Required Fields

In order to implement this functionality, it is assumed that lockable submission forms have a 
set of "system fields" (fields that do not display in the page content, often implemented as fields 
on a page that is after the confirmation page) that are used to manage visibility and lock state.
These fields are:

* `Assigned Group`
* `Assigned Individual`
* `Locked By`
* `Locked Until`

Setting the `Assigned Group` and `Assigned Individual` field values is outside the scope of this 
document, but these will often be initialized when Kinetic Task first creates the 
Approval/Fulfillment/Ticket submission or changed by updating the submission itself.

Setting the `Locked By` and `Locked Until` fields is automatically managed once locking is 
configured (discussed in further detail in the 
[bundle.ext.locking.observe Summary](#bundleextlockingobserve-summary) section).

## Files

[bundle/LockableSubmissionHelper.md](LockableSubmissionHelper.md)  
README file containing information on configuring and using the lockable submission helper.

[bundle/LockableSubmissionHelper.jspf](LockableSubmissionHelper.jspf)  
Helper file containing definitions for the LockableSubmissionHelper and LockableSubmission 
classes.  More information can be found in the 
[BridgedResourceHelper Summary](#bridgedresourcehelper-summary) and
[LockableSubmission Summary](#lockablesubmission-summary) sections. 

[js/locking.js](../js/locking.js)  
JavaScript file containing the code for the client side locking logic.

[partials/lock.jsp](../partials/lock.jsp)  
The callback page that is called by the client side locking logic when a lockable submission is 
opened.  This page attempts to update the lock on a submission and renders a message describing the
results of the call.  The contents can be modified to change the displayed messages or formatting.


## Configuration

* Copy the files listed above into your bundle
* Apply `Submission Modification` security policies to the lockable submission forms
* Include `js/locking.js` in the rendered page head content
* Initialize the LockableSubmissionHelper in your `bundle/initialization.jspf` file
* Initialize the client side locking logic by extending the `bundle.config.ready` event callback

### Apply Submission Modification security policies
In order to guarantee that submissions can only be modified by the individual with the lock, a
Submission Security Policy Definition can be created and applied to the form.  Below is an example
Security Policy Definition that would be applied to the `Submission Modification` security policy
for any form that leverages locking.

**Name:** Lock Holder  
**Type:** Submission  
**Message:** `The submission is locked by ${values('Locked By')}.`  
**Rule:**
```
identity('authenticated') 
&& (
  values('Locked By') == identity('username')
  || Date.parse(values('Locked Until')) < Date.now()
)
```


### Include locking.js in the rendered page head content
**layouts/layout.jsp**  
```jsp
<bundle:scriptpack>
    ...
    <bundle:script src="${bundle.location}/js/locking.js" />
    ...
</bundle:scriptpack>
```

### Initialize the LockableSubmissionHelper

By default the LockableSubmissionHelper will search for all submissions of the specified type that 
have the current user as the `Assigned Individual` or that have one of the current users groups as 
the `Assigned Group`.  

If group management is being done via User attributes, than the LockableSubmissionHelper needs to be
initialized with what the name of the group attribute is.

Additionally, if assignment delegation is being managed by attributes, the LockableSubmissionHelper
can be initialized with the name of the delegation attribute.  If this is set, the search query will
search for all submissions that have the current user as the `Assigned Individual`, that have anyone 
specified in the current user's list of delegation attributes as the `Assigned Individual`, or that 
have one of the current user's groups as the `Assigned Group`.

**bundle/initialization.jspf** *default*  
```jsp
<%
    request.setAttribute("LockableSubmissionHelper", new LockableSubmissionHelper(request));
%>
```

**bundle/initialization.jspf** *basic*  
```jsp
<%
    request.setAttribute("LockableSubmissionHelper", 
        new LockableSubmissionHelper(request)
            .setDelegationAttribute("Delegations")
            .setGroupAttribute("Groups"));
%>
```

**bundle/initialization.jspf** *dynamic*  
```jsp
<%@include file="LockableSubmissionHelper.jspf"%>
<%
    // Add setup attributes
    setupHelper
        .addSetupAttribute(
            "Lockable Submission Delegation Attribute", 
            "This should be set to the name of the User attribute definition that corresponds to "+
                "assignment delegation, or left blank if delegation is not being used.", 
            false)
        .addSetupAttribute(
            "Lockable Submission Group Attribute", 
            "This should be set to the name of the User attribute definition that corresponds to "+
                "groups, or left blank if groups are not being managed by User attributes.", 
            false);
    // If the request is scoped to a specific Kapp (space display pages are not)
    if (kapp != null) {
        // Initialize the LockableSubmissionHelper
        LockableSubmissionHelper lockableSubmissionHelper = new LockableSubmissionHelper(request);
        if (kapp.hasAttribute("Lockable Submission Delegation Attribute")) {
            lockableSubmissionHelper.setDelegationAttribute(
                kapp.getAttributeValue("Lockable Submission Delegation Attribute"));
        }
        if (kapp.hasAttribute("Lockable Submission Group Attribute")) {
            lockableSubmissionHelper.setDelegationAttribute(
                kapp.getAttributeValue("Lockable Submission Group Attribute"));
        }
        request.setAttribute("LockableSubmissionHelper", lockableSubmissionHelper);
    }
%>
```

### Initialize the client side locking logic
More information about what options are available to the `bundle.ext.locking.observe` call can be
found in the [bundle.ext.locking.observe Summary](#bundleextlockingobserve-summary) section.

**form.jsp**  
```jsp
<bundle:layout page="layouts/form.jsp">
    <bundle:variable name="head">
        ...
        <%-- If the form has a "Locked By" field and is not being displayed in review mode. --%>
        <c:if test="${form.getField('Locked By') != null && param.review == null}">
            <script>
                // Set the bundle ready callback function (this is called automatically by the 
                // application after the kinetic form has been initialized/activated)
                bundle.config.ready = function(kineticForm) {
                    // Prepare locking
                    bundle.ext.locking.observe(kineticForm, {
                        lockDuration: 60,
                        timeoutInterval: 45
                    });
                };
            </script>
        </c:if>
    </bundle:variable>
```


## Example Usage
```jsp
<c:forEach var="lockable" items="${LockableSubmissionHelper.search('Approval')}">
    <c:set var="submission" value="${lockable.submission}"/>
    <tr>
        <td>
            <c:if test="${lockable.isLocked()}">
                <i class="fa fa-lock" 
                   data-toggle="tooltip" 
                   data-placement="top" 
                   title="${text.escape(lockable.getLockedBy())}"></i>
            </c:if>
        </td>
        <td>
            <a href="${bundle.spaceLocation}/submissions/${submission.id}" 
               target="_blank">${text.escape(submission.label)}</a>
        </td>
        <td>${submission.createdAt}</td>
        <td>
            <c:forEach var="group" items="${lockable.assignedGroups}" varStatus="status">
                ${text.escape(group)}${not status.last ? ", " : "" }
            </c:forEach>
        </td>
        <td>
            <c:forEach var="individual" items="${lockable.assignedIndividuals}" varStatus="status">
                ${text.escape(individual)}${not status.last ? ", " : "" }
            </c:forEach>
        </td>
    </tr>
</c:forEach>
```

---

### bundle.ext.locking.observe Summary
Calls to `bundle.ext.locking.observe` initializes a "heartbeat" poller, which updates the 
`Locked By` submission value to be the current user and the `Locked Until` submission value to be
`lockDuration` seconds from now.  The code then waits `lockInterval` seconds before repeating the 
process.

```javascript
// Configuration Options
var config = {
    element: null, // Defaults to an empty div prepended to the kinetic form contents
    lockDuration: 60,
    lockInterval: 45,
    onBefore: function() {
        // Called before each locking "heartbeat" AJAX call
    },
    onFailure: function(request) {
        // Called when the locking "heartbeat" AJAX call fails
    },
    onSuccess: function(content) {
        // Called when the locking "heartbeat" AJAX call return successfully.  If this is not set,
        // the default behavior is to set the HTML content of the config.element (or an empty div
        // prepended to the kinetic form if config.element is not set).  If the config.onSuccess
        // callback is configured, the display of the response content will be delegated to it.
    }
};
// Initialize the "heartbeat" AJAX calls
bundle.ext.locking.observe(kineticForm, config);
```

---

#### BridgedResourceHelper Summary

`LockableSubmissionHelper(HttpServletRequest request)`  

`LockableSubmissionHelper setDelegationAttribute(String attributeName)`  
`LockableSubmissionHelper setGroupAttribute(String attributeName)`  

`LockableSubmission lock(String id, String until) throws Exception`  
`LockableSubmission retrieve(String id)`  
`List<LockableSubmission> search(String type)`  

---

#### LockableSubmission Summary

`LockableSubmission(Submission submission)`

`List<String> getAssignedGroups()`  
`List<String> getAssignedIndividuals()`  
`String getLockedBy()`  
`Date getLockedUntil()`  
`Submission getSubmission()`  
`boolean isExpired()`  
`boolean isLocked()`  
