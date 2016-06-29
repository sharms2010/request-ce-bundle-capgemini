<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<nav class="navbar navbar-default" id="bundle-header">
    <div class="container">
        <div class="navbar-header col-sm-4">
            <a class="navbar-brand" href="${not empty kapp ? bundle.kappLocation : bundle.spaceLocation}">
                <c:choose>
                    <c:when test="${space.hasAttribute('Logo Url')}">
                        <img src="${kapp.getAttributeValue('Logo Url')}" alt="logo">
                    </c:when>
                    <c:when test="${not empty kapp && kapp.hasAttribute('Logo Url')}">
                        <img src="${space.getAttributeValue('Logo Url')}" alt="logo">
                    </c:when>
                    <c:when test="${not empty kapp}">
                        <i class="fa fa-home"></i> ${text.escape(kapp.name)}
                    </c:when>
                    <c:otherwise>
                        <i class="fa fa-home"></i> ${text.escape(space.name)}
                    </c:otherwise>
                </c:choose>
            </a>
        </div>
        <div class="col-sm-4 header-title">
            <h1>DIR Marketplace</h1>
            <div class="tagline hidden-xs hidden-sm">Your place for Cloud service offerings</div>
        </div>
        <div class="col-sm-4 text-right">
            <div class="hidden-xs pull-right">
                <c:choose>
                    <c:when test="${identity.anonymous}">
                        <a href="${bundle.spaceLocation}/app/login" class="hidden-xs"><i class="fa fa-sign-in fa-fw"></i> Login</a>
                    </c:when>
                    <c:otherwise>
                            Welcome <a href="${bundle.spaceLocation}/?page=profile">${text.escape(text.trim(identity.displayName, identity.username))}</a> | 
                            <a href="${bundle.spaceLocation}/app/logout"> Logout</a>
                            <div class="dropdown">
                                <c:if test="${empty sessionScope.parentCompany && not empty space.getBridgeModel('CTM Person')}">
                                    <%-- Bridged CTM Person Data --%>
                                    <c:set var="params" value="${BridgedResourceHelper.map()}"/>
                                    <c:set target="${params}" property="User" value="${identity.getAttributeValue('ARS Login')}"/>
                                    <c:set scope="session" var="company" value="${BridgedResourceHelper.retrieve('CTM Person',params)}"/>
                                    <c:set scope="session" var="companyName" value="${text.escape(sessionScope.company.get('Company Name'))}" />
                                </c:if>
                                <a id="drop2" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                    ${text.escape(companyName)} <span class="fa fa-caret-down fa-fw"></span>
                                </a>
                                 <c:if test="${not empty space.getBridgeModel('CTM Person') && not empty space.getBridgeModel('CTM Permission Groups')}">
                                    <%-- Bridged CTM Person Data --%>
                                    <c:set var="params" value="${BridgedResourceHelper.map()}"/>
                                    <c:set target="${params}" property="User" value="${identity.getAttributeValue('CTM People Id')}"/>
                                    <c:set scope="request" var="companies" value="${BridgedResourceHelper.search('CTM Permission Groups',params)}"/>
                                  
                                    <ul class="dropdown-menu pull-right" aria-labelledby="drop2">
                                        <c:if test="${!sessionScope.parentCompany}">
                                            <li class="header"><a href="${bundle.kappLocation}?company=${text.escape(sessionScope.company.get('Company Name'))}">${text.escape(company.get("Company Name"))}</a></li> 
                                        </c:if>
                                        <c:forEach var="company" items="${companies}">
                                            <c:if test="${company.get('Company Name').length() > 0}">
                                                <li>
                                                    <a href="${bundle.kappLocation}?company=${text.escape(company.get('Company Name'))}">${text.escape(company.get('Company Name'))}</a>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </c:if>
                            </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
<nav class="navbar navbar-default  subnav">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
    </div>
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
        <ul class="nav navbar-nav" style="width:100%">
            <li class="<c:if test="${empty param['page'] && empty form}">active</c:if>"><a href="${bundle.kappLocation}"><i class="fa fa-home fa-fw"></i> Home</a></li>
            <li class="dropdown <c:if test="${not empty form && (form.getSlug() eq 'fully-managed' || form.getSlug() eq 'semi-managed')}">active</c:if>"">
                <a id="drop1" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                    <i class="fa fa-cloud fa-fw"></i> Cloud Offerings<span class="fa fa-caret-down fa-fw"></span>
                </a>
                <ul class="dropdown-menu priority " aria-labelledby="drop1">
                    <li class="hidden-xs"><a href="${bundle.kappLocation}/fully-managed">
                        Fully Managed</a>
                    </li>
                    <li class="hidden-xs"><a href="${bundle.kappLocation}/semi-managed">
                        Semi Managed</a>
                    </li>
                </ul>
            </li>
            <li class="<c:if test="${param['page'] eq 'approvals'}">active</c:if>"><a href="${bundle.kappLocation}?page=approvals"><i class="fa fa-check-square-o fa-fw"></i> Approvals</a></li>
            <li><a href="#">DCS Portal</a></li>
        </ul>
  </div>
</nav>
