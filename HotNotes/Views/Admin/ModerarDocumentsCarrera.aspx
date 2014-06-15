<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Assignatura>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Moderar_documents") %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <ol class="breadcrumb">
        <li><a href="<%: Url.Action("Index", "Admin") %>"><%: Lang.GetString(lang, "Moderar_documents") %></a></li>
        <li class="active"><%: ViewBag.NomCarrera %></li>
    </ol>

    <h3><%: Lang.GetString(lang, "Tria_assignatura") %></h3>

    <ul>
        <% foreach (Assignatura a in Model)
           { %>
        <li><a href="<%: Url.Action("ModerarDocumentsAssignatura", "Admin", new { Id = a.Id }) %>"><%: a.Nom %> (<%: a.Curs %>)</a></li>
        <% } %>
    </ul>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>
