## Overview

The BridgedResourceHelper is a utility for calling bridged resources from within a bundle.

**Current Limitations**
* Must have one or more "Shared Resources" forms that define the bridged resources to expose
* The "Shared Resources" form must have dummy fields for each of the bridged resource
* Custom sorting is not implemented (the results can be sorted manually as a workaround)
* Pagination is not implemented (the results can be "truncated" as a workaround for reasonable sized
  lists of results.

## Files

[bundle/BridgedResourceHelper.md](BridgedResourceHelper.md)  
README file containing information on configuring and using the bridged resource helper.

[bundle/BridgedResourceHelper.jspf](BridgedResourceHelper.jspf)  
Helper file containing definitions for the BridgedResourceHelper.  More information can be found in
the [BridgedResourceHelper Summary](#bridgedresourcehelper-summary) section.

## Configuration

* Copy the files listed above into your bundle
* Initialize the BridgedResourceHelper in your bundle/initialization.jspf file

### Initialize the BridgedResourceHelper

**bundle/initialization.jspf**
```jsp
<%@include file="BridgedResourceHelper.jspf" %>
<%
    // Add setup attributes
    setupHelper.addSetupAttribute(
            "Shared Bridged Resource Form Slug", 
            "The slug of the form that is used to define shared bridged resources.", 
            false);
    // If the request is scoped to a specific Kapp (space display pages are not)
    if (kapp != null && kapp.hasAttribute("Shared Bridged Resource Form Slug")) {
        // Initialize the LockableSubmissionHelper
        request.setAttribute("BridgedResourceHelper", 
            new BridgedResourceHelper(
                request, 
                bundle.getKappLocation(), 
                kapp.getAttributeValue("Shared Bridged Resource Form Slug")));
    }
%>
```

## Example Usage

**Server Side (JSP) Retrieve**
```jsp
<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <c:set var="params" value="${BridgedResourceHelper.map()}"/>
    <c:set target="${params}" property="Email" value="EMAIL"/>
    <c:set var="record" value="${BridgedResourceHelper.retrieve('User By Email', params)}"/>
    <div>
        ${text.escape(record.get('Full Name'))}
    </div>
</bundle:layout>
```

**Server Side (JSP) Search**
```jsp
<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <c:set var="params" value="${BridgedResourceHelper.map()}"/>
    <c:set target="${params}" property="Department" value="${DEPARTMENT}"/>
    <c:set var="records" value="${BridgedResourceHelper.search('Users By Department', params)}"/>
    <ul>
        <c:forEach var="record" items="${records}">
            <li>${text.escape(record.get('Full Name'))}</li>
        </c:forEach>
    </ul>
</bundle:layout>
```

**Client Side (Javascript) Retrieve / Search**  
This example does not use the BridgedResourceHelper class but is a common pattern to use when 
calling bridged resources from the client.

```javascript
// Define the URL to the bridged resource
var url = bundle.kappLocation()+"/"+"FORM_SLUG"+"/bridgedResources/"+"RESOURCE_NAME";
// Prepare the bridged resource parameters
var params = {
    "values[Last Name]": "Smith",
    "values[Company]": "Acme"
};
// Execute the AJAX request
$.ajax({
    method: "get",
    dataType: 'json',
    url: url,
    data: params,
    success: function(data, textStatus, jqXHR){
        // The data variable will be formatted differently depending on whether the bridged resource
        // corresponds to a "Single" or "Multiple" type qualification.

        // Example "Single" type qualification result data:
        // {
        //     record: {
        //         attributes: {
        //             "Address": "123 Fake St, Springfield, MN, 55555",
        //             "Display Name": "John Smith",
        //             "Email": "john.smith@acme.com"
        //         }
        //     }
        // }

        // Example "Multiple" type qualification result data:
        // {
        //     records: {
        //         metadata: {
        //             count: 20
        //             pageNumber: 1
        //             pageSize: 0
        //         },
        //         fields: [ "Address", "Display Name", "Email"],
        //         records: [ 
        //             ["123 Fake St, Springfield, MN, 55555", "John Smith", "john.smith@acme.com"]
        //         ]
        //     }
        // }

        // The string lists returned by a "Multiple" type qualification can easily be converted into
        // maps using the following code snippit:
        //     var records = _.map(data.records.records, function(record){
        //        return _.object(data.records.fields, record);
        //     });
        // Which result in a "records" variable that looks something like:
        //     [
        //         {
        //             "Address": "123 Fake St, Springfield, MN, 55555",
        //             "Display Name": "John Smith",
        //             "Email": "john.smith@acme.com"
        //         }
        //     ]
    },
    error: function(jqXHR, textStatus, errorThrown){
        // Process error
    }
});
```

---

#### BridgedResourceHelper Summary

`BridgedResourceHelper(HttpServletRequest request, String kappLocation, String formSlug)`

`Count count(String name)`  
`Count count(String name, Map<String,String> values)`

`Record retrieve(String name)`  
`Record retrieve(String name, Map<String,String> values)`

`RecordList search(String name)`  
`RecordList search(String name, Integer limit)`  
`RecordList search(String name, Integer limit, Integer offset)`  
`RecordList search(String name, Map<String,String> values)`  
`RecordList search(String name, Map<String,String> values, Integer limit)`  
`RecordList search(String name, Map<String,String> values, Integer limit, Integer offset)`

---

#### Count Summary

`public Integer value()`

---

#### Record Summary

`public List<String> attributeNames()`  
`public Map<String,String> attributes()`  
`public String get(String attributeName)`  

---

#### RecordList Summary

`public Record first()`  
`public Record get(int index)`  
`public Record last()`  
