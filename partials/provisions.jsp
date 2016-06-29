<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<div class="table-container">
    <table class="table table-striped table-hover">
        <thead>
            <tr>
                <th>Host Name</th>
                <th>System Type</th>
                <th>Total Physical Memory</th>
                <th>Virtual</th>
                <th>Virtual System Type</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${records}" var="record">
                <tr>
                    <td>${record.get('HostName')}</td>
                    <td>${record.get('SystemType')}</td>
                    <td>${record.get('TotalPhysicalMemory')}</td>
                    <td>${record.get('isVirtual')}</td>
                    <td>${record.get('VirtualSystemType')}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
