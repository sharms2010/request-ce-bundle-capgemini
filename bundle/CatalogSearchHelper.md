## Overview

The CatalogSearchHelper is a utility for retrieving forms based on a query string. 
It searches a form's name, "Keyword" attribute values, description, attribute values of any attributes defined through the "Search Attribute", and category names. 
The CatalogSearchHelper also offers pagination, as well as weighted searching.

## Files

[bundle/CatalogSeachHelper.md](CatalogSeachHelper.md)  
README file containing information on configuring and using the catalog search helper.

[bundle/CatalogSeachHelper.jspf](CatalogSeachHelper.jspf)  
Helper file containing definitions for the CatalogSeachHelper.  More information can be found in
the [CatalogSeachHelper Summary](#catalogseachhelper-summary) section.

[partials/search.json.jsp](search.json.jsp)  
Partial that accepts the parameters 'q', 'pageSize', and 'offset', and returns a JSON list of Forms that match the query 'q'.

[pages/search.jsp](search.jsp)  
Page that accepts the parameters 'q', 'pageSize', and 'offset', and displays the list of Forms that match the query 'q'.

## Configuration

* Copy the files listed above into your bundle
* Initialize the CatalogSearchHelper in your bundle/initialization.jspf file
* You may need to modify the search function to search the components that your KAPP requires, as different KAPPs may have different requirements. 
* You may also need to modify the WeightedForm class if your KAPP does not search forms. 
* DO NOT modify the WeightHelper if you are aggregating multiple searches on a page. The WeightHelper needs to use the same algorithm in order to offer a consistent sort/merge order when aggregating results from multiple search helpers.

### Initialize the CatalogSeachHelper

**bundle/initialization.jspf**
```jsp
<%-- CatalogSearchHelper --%>
<%@include file="CatalogSearchHelper.jspf"%>
<%
    request.setAttribute("CatalogSearchHelper", new CatalogSearchHelper());
    //Add setup attributes
    setupHelper
        .addSetupAttribute("Search Attribute", 
            "Specify which form attributes should be searchable. " 
                + "Keyword attribute is always searchable and does not need to be specified as a Search Attribute. [Allows Multiple]", 
            false)
        .addSetupAttribute("Include in Global Search", 
            "Set if the Kapp should use and participate in global search.", 
            false); 
%>
```

## Example Usage

**JSP Search using URL Parameters**
```jsp
<c:set var="results" value="${CatalogSearchHelper.search(kapp.forms, param['q']}"/>
```
```jsp
<c:set var="results" value="${CatalogSearchHelper.search(kapp.forms, param['q'], param['pageSize'], param['offset'])}"/>
```

**JS Search via Ajax**
```javascript
$.ajax({
    url: bundle.kappLocation() + "?partial=search.json",
    data: {
        q: "search query",
        pageSize: 20, // Optional
        offset: 0 // Optional
    },
    type: "GET",
    dataType: "json",
    success: function(data, textStatus, jqXHR){
        // data will be an array of objects
        // [
        //     {
        //         title: "Form Name",
        //         description: "Form Description",
        //         icon: "Form Icon",
        //         url: "Form URL",
        //         weight: "Result Weight",
        //         kappSlug: "KAPP Slug",
        //         kappName: "KAPP Name",
        //     }, ...
        // ]
    }
});
```

---

#### CatalogSeachHelper Summary
Returns the forms that match the query.

`CatalogSeachHelper()`

`static List<WeightedForm> search(List<Form> forms, String query)`  
`static List<WeightedForm> search(List<Form> forms, String query, int pageSize, int offset)`  

---

#### WeightedForm Summary
Wrapper for Form object that adds a weight. Implements comparable to naturally sort by weight, then Form name, and finally Form slug.

`WeightedForm(Form form, double weight)`

`Form getForm()`  
`double getWeight()`  
`int compareTo(WeightedForm that)`  

---

#### WeightHelper Summary
Calculates a weight given a list of query terms to search for, and one or more lists of Strings to search in. 

`static double weigh(List<String> terms, List<String>... searchable)`  
