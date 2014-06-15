<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Carrera>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Moderar_documents") %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <ol class="breadcrumb">
        <li class="active"><%: Lang.GetString(lang, "Moderar_documents") %></li>
    </ol>

    <h3><%: Lang.GetString(lang, "Tria_carrera") %></h3>

    <ul>
        <% foreach (Carrera c in Model)
           { %>
        <li><a href="<%: Url.Action("ModerarDocumentsCarrera", "Admin", new { Id = c.Id }) %>"><%: c.Nom %></a></li>
        <% } %>
    </ul>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>
