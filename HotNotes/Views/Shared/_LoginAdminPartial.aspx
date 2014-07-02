<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>
<% if (!string.IsNullOrEmpty(ViewBag.AdminUsername))
   { %>
<ul class="nav navbar-nav navbar-right">
    <li><%: Html.ActionLink((string)ViewBag.AdminUsername, "Configuracio", "Admin", routeValues: null, htmlAttributes: new { @class = "username", title = "Manage" }) %></li>
    <li>
        <button type="button" class="btn btn-primary" style="margin-top: 0.5em;" onclick="location.href='<%: Url.Action("Logout", "Admin") %>'"><%: Lang.GetString(lang, "Tanca_sessio") %></button>
    </li>
</ul>
<% } %>