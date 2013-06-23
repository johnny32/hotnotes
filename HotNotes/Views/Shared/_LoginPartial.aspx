<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>
<% if (Request.IsAuthenticated) { %>
    <%: Html.ActionLink(User.Identity.Name, "Manage", "Account", routeValues: null, htmlAttributes: new { @class = "username", title = "Manage" }) %>
    <% using (Html.BeginForm("LogOff", "Account", FormMethod.Post, new { id = "logoutForm" })) { %>
        <%: Html.AntiForgeryToken() %>
        <a href="javascript:document.getElementById('logoutForm').submit()"><%: Lang.GetString(lang, "Tanca_sessio") %></a>
    <% } %>
<% } else { %>
    <ul>
        <li><%: Html.ActionLink(Lang.GetString(lang, "Registrat"), "Register", "Account", routeValues: null, htmlAttributes: new { id = "registerLink" })%></li>
        <li><%: Html.ActionLink(Lang.GetString(lang, "Inicia_sessio"), "Login", "Account", routeValues: null, htmlAttributes: new { id = "loginLink" })%></li>
    </ul>
<% } %>