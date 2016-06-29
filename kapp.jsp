<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>
<c:set var="bundleCategories" value="${CategoryHelper.getCategories(kapp)}"/>
<%-- Bridged CTM Person Data --%>
<c:set var="params" value="${BridgedResourceHelper.map()}"/>
<c:set target="${params}" property="User" value="${identity.getAttributeValue('ARS Login')}"/>
<c:set scope="session" var="company" value="${BridgedResourceHelper.retrieve('CTM Person',params)}"/>
<c:if test="${empty sessionScope.parentCompany || not empty param['company']}">
    <c:choose>
        <c:when test="${not empty param['company'] && param['company'] ne company.get('Company Name')}">
            <c:set scope="session" var="companyName" value="${param['company']}" />
            <c:set scope="session" var="parentCompany" value="false" />
        </c:when>
        <c:otherwise>
            <c:set scope="session" var="parentCompany" value="true" />
            <c:set scope="session" var="companyName" value="${text.escape(sessionScope.company.get('Company Name'))}" />
        </c:otherwise>
    </c:choose>
</c:if>
<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Kinetic Data ${text.escape(kapp.name)}</title>
    </bundle:variable>
    <div class="row">
        <div class="col-md-12 cloud-offerings">
            <h3 class="section-header">Cloud Offerings</h3>
            <div class="col-sm-6">
                <div class="card small">
                    <div class="card-content">
                        <div class="col-sm-6">
                            <a href="${bundle.kappLocation}/fully-managed">
                                <img src="https://a0.awsstatic.com/main/images/logos/aws_logo_mobile@2x.png"  style="width: 75%" />
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <h3>Fully Managed</h3>
                            <ul>
                                <li>ABC 24/7</li>
                                <li>XYZ M-S</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card-action clearfix text-right">
                        <a href="${bundle.kappLocation}/fully-managed">
                            Start Provision<span class="fa fa-caret-right fa-fw"></span>
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-sm-6">
                <div class="card small">
                    <div class="card-content">
                        <div class="col-sm-6">
                            <a href="${bundle.kappLocation}/semi-managed">
                                <a href="${bundle.kappLocation}/semi-managed">
                                    <img src="http://www.kellerschroeder.com/news/wp-content/uploads/sites/2/2015/11/Microsoft-Azure.png" style="width: 75%" />
                                </a>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <h3>Semi Managed</h3>
                            <ul>
                                <li>ABC 9-5</li>
                                <li>XYZ M-F</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card-action clearfix text-right">
                        <a href="${bundle.kappLocation}/semi-managed">
                            Start Provision<span class="fa fa-caret-right fa-fw"></span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <c:if test="${sessionScope.parentCompany}">
            <div class="col-md-12 table-container pending-provisions">
                <h3>Pending Provisions</h3>
                <!-- Set variable used to count and display submissions -->
                <c:set scope="request" var="submissionsList" value="${SubmissionHelper.retrieveRecentSubmissions('Service', 'Submitted', 999)}"/>
                <c:import url="${bundle.path}/partials/submissions.jsp" charEncoding="UTF-8"/>
            </div>
        </c:if>
        <div class="col-md-12 table-container completed-provisions">
            <h3>${text.escape(sessionScope.companyName)} Provisions</h3>
            <!-- Set variable used to count and display submissions -->
            <c:set var="params" value="${BridgedResourceHelper.map()}"/>
            <c:set target="${params}" property="Company" value="${sessionScope.companyName}"/>
            <c:set scope="request" var="records" value="${BridgedResourceHelper.search('CMDB ComputerSystem',params)}"/>
            <c:import url="${bundle.path}/partials/provisions.jsp" charEncoding="UTF-8"/>
        </div>
    </div>
</bundle:layout>