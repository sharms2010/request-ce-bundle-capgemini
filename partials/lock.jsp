<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<c:catch var="lockException">
    <c:choose>
        <c:when test="${pageContext.request.method == 'PUT' || header['X-HTTP-Method-Override'] == 'PUT'}">
            <c:set var="lockable" value="${LockableSubmissionHelper.lock(param.id, param.until)}"/>
        </c:when>
        <c:otherwise>
            <c:set var="lockable" value="${LockableSubmissionHelper.retrieve(param.id)}"/>
        </c:otherwise>
    </c:choose>
</c:catch>

<c:choose>
    <%-- ERROR --%>
    <c:when test="${lockException != null || lockable == null}">
        <div class="alert alert-danger" role="alert">
            Unable to verify lock.  
            <pre style="display:none;">
                ${text.escape(lockException.message)}
            </pre>
        </div>
    </c:when>
    <%-- COMPLETED BY SOMEONE ELSE --%>
    <c:when test="${lockable.submission.coreState != 'Draft'}">
        <div class="alert alert-warning" role="alert">
            This ${text.escape(text.downcase(lockable.submission.type.name))} has been completed by 
            ${text.escape(lockable.submission.submittedBy)}.
        </div>
    </c:when>
    <%-- NOT LOCKED--%>
    <c:when test="${not lockable.isLocked()}">
        <div class="alert alert-warning" role="alert">
            This ${text.escape(text.downcase(lockable.submission.type.name))} is not locked.
        </div>
    </c:when>
    <%-- LOCKED BY SOMEONE ELSE --%>
    <c:when test="${lockable.lockedBy != identity.username}">
        <div class="alert alert-warning" role="alert">
            <c:if test="${identity.isSpaceAdmin()}">
                <strong>WARNING:</strong> You are a space admin and can modify this record 
                without a lock.<br/>
                <br/>
            </c:if>
            This ${text.escape(text.downcase(lockable.submission.type.name))} has been locked by 
            ${text.escape(lockable.lockedBy)}.
        </div>
    </c:when>
    <%-- LOCKED BY YOU --%>
    <c:otherwise>
        <div class="alert alert-success" role="alert">
            This ${text.escape(text.downcase(lockable.submission.type.name))} is locked by you.
        </div>
    </c:otherwise>
</c:choose>