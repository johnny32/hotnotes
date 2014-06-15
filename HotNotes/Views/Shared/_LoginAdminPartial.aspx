<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>
<% if (Request.IsAuthenticated) { %>
    <ul class="nav navbar-nav navbar-right">
        <li><%: Html.ActionLink(User.Identity.Name, "Configuracio", "Admin", routeValues: null, htmlAttributes: new { @class = "username", title = "Manage" }) %></li>
        <li> <% using (Html.BeginForm("Logout", "Admin", FormMethod.Post, new { id = "logoutForm", @class = "navbar-form navbar-right" })) { %>
            <%: Html.AntiForgeryToken() %>
            <button type="button" class="btn btn-primary" onclick="document.getElementById('logoutForm').submit()"><%: Lang.GetString(lang, "Tanca_sessio") %></button>
        <% } %></li>
    </ul>
<% } %>