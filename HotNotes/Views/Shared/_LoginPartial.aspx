<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>
<% if (Request.IsAuthenticated) { %>
    <ul class="nav navbar-nav navbar-right">
        <li><%: Html.ActionLink(User.Identity.Name, "Manage", "Usuari", routeValues: null, htmlAttributes: new { @class = "username", title = "Manage" }) %></li>
        <li> <% using (Html.BeginForm("Logout", "Usuari", FormMethod.Post, new { id = "logoutForm", @class = "navbar-form navbar-right" })) { %>
            <%: Html.AntiForgeryToken() %>
            <button type="button" class="btn btn-primary" onclick="document.getElementById('logoutForm').submit()"><%: Lang.GetString(lang, "Tanca_sessio") %></button>
        <% } %></li>
    </ul>
<% } else { %>
    <ul class="nav navbar-nav navbar-right">
        <li><%: Html.ActionLink(Lang.GetString(lang, "Registrat"), "Register", "Usuari", routeValues: null, htmlAttributes: new { id = "registerLink" })%></li>
        <li><%: Html.ActionLink(Lang.GetString(lang, "Inicia_sessio"), "Login", "Usuari", routeValues: null, htmlAttributes: new { id = "loginLink" })%></li>
    </ul>
<% } %>