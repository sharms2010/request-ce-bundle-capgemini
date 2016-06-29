<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<bundle:layout page="${bundle.path}/layouts/layout.jsp">

    <bundle:variable name="head">
        <title>${text.escape(space.name)} Search</title>
    </bundle:variable>
    
    <div class="search-results">
        <h3>${kappIter.name} Search Results <c:if test="${text.isNotBlank(param['q'])}">for '${param['q']}'</c:if></h3>
        <div class="card-container">
            <c:choose>
                <c:when test="${text.isNotBlank(param['q'])}">
                    <c:catch var ="searchException">
                       <c:set var="searchResults" scope="request" value="${CatalogSearchHelper.search(kapp.forms, param['q'])}" />
                    </c:catch>
                    <c:choose>
                        <c:when test="${searchException ne null}">
                            <div class="card">
                                <div class="card-content alert alert-danger">
                                    <h5>
                                        <span class="fa fa-exclamation-triangle"></span>
                                        <span>Error: ${searchException.cause}</span>
                                    </h5>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="result" items="${searchResults}">
                                <div class="card" data-weight="${result.weight}">
                                    <div class="card-title small">
                                        <c:if test="${result.form.hasAttribute("Icon")}">
                                            <span class="fa ${result.form.getAttribute("Icon")}"></span>
                                        </c:if>
                                        <a href="${bundle.kappLocation}/${result.form.slug}">${result.form.name}</a>
                                    </div>
                                    <c:if test="${text.isNotBlank(result.form.description)}">
                                        <div class="card-content">
                                            <p>${result.form.description}</p>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>                
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <div class="card">
                        <div class="card-content alert alert-danger">
                            <h5>
                                <span class="fa fa-exclamation-triangle"></span>
                                <span>Search term not found.</span>
                            </h5>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</bundle:layout>