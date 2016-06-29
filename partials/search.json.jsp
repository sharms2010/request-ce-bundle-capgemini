<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<json:array>
  <c:forEach var="match" items="${CatalogSearchHelper.search(kapp.forms, param['q'], param['pageSize'], param['offset'])}">
    <json:object>
      <json:property name="title" value="${match.form.name}"/>
      <json:property name="description" value="${match.form.description}"/>
      <json:property name="icon" value="${match.form.getAttribute('Icon')}"/>
      <json:property name="url" value="${bundle.kappLocation}/${match.form.slug}"/>
      <json:property name="weight" value="${match.weight}"/>
      <json:property name="kappSlug" value="${kapp.slug}"/>
      <json:property name="kappName" value="${kapp.name}"/>
    </json:object>
  </c:forEach>
</json:array>
