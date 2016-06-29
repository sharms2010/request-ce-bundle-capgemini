<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>
<bundle:layout page="layouts/form.jsp">
    <bundle:variable name="head">
        <title>${text.escape(form.name)}</title>
        
        <%-- If the form has a "Locked By" field and is not being displayed in review mode. --%>
        <c:if test="${form.getField('Locked By') != null && param.review == null}">
            <script>
                // Set the bundle ready callback function (this is called automatically by the 
                // application after the kinetic form has been initialized/activated)
                bundle.config.ready = function(kineticForm) {
                    // Prepare locking
                    bundle.ext.locking.observe(kineticForm, {
                        lockDuration: 15,
                        lockInterval: 10
                    });
                };
            </script>
        </c:if>
    </bundle:variable>
    <section class="page" data-page="${page.name}">
        <div class="page-header">
            <h3>${text.escape(form.name)}</h3>
        </div>
        <c:if test="${param.review != null && pages.size() > 1}">
            <c:import url="partials/review.jsp" charEncoding="UTF-8"></c:import>
        </c:if>
        <app:bodyContent/>
    </section>
</bundle:layout>
