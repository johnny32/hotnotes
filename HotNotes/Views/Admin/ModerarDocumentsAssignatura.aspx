<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.DocumentLlistat>>" %>
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
        <li><a href="<%: Url.Action("ModerarDocumentsCarrera", "Admin", new { Id = ViewBag.IdCarrera }) %>"><%: ViewBag.NomCarrera %></a></li>
        <li class="active"><%: ViewBag.NomAssignatura %></li>
    </ol>

    <h3><%: Lang.GetString(lang, "Tria_document") %></h3>

    <ul>
        <% foreach (DocumentLlistat d in Model)
           { %>
        <li><a href="<%: Url.Action("ModerarDocument", "Admin", new { Id = d.Id }) %>"><%: d.Nom %> (<%: d.Valoracio %>)</a> </li>
        <% } %>
    </ul>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>