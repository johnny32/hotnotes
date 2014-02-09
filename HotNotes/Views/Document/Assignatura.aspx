<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Document>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.NomAssignatura %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript" src="<%: Url.Content("~/Plugins/jquery.bootpag.min.js") %>"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2><%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.NomAssignatura %></h2>
    <span style="font-style: italic; font-size: small;"><%: Lang.GetString(lang, "Total") %>: <%: Model.Count %> <%: Lang.GetString(lang, "Documents").ToLower() %></span>

    <%
        foreach (Document d in Model)
        {
            %>
        <div id="document<%: d.Id %>" class="documentListItem">
            <div style="float: left">
                <h3><a href="<%: Url.Action("Veure", "Document", new { Id = d.Id }) %>"><%: d.Nom %></a></h3>
                <span style="font-size: small;"><%: Lang.GetString(ViewBag.Lang, "Autor") %>: <a href="<%: d.LinkPerfilAutor %>"><%: d.NomAutor %></a></span>
            </div>
            <div style="float: right">
                <%: Lang.GetString(ViewBag.Lang, "Tipus") %>: <%: Lang.GetString(ViewBag.Lang, d.Tipus.ToString()) %><br />
                <%: Lang.GetString(ViewBag.Lang, "Data_creacio") %>: <%: d.DataAfegit.ToShortDateString() %><br />
            </div>
            <div style="clear: both"></div>
        </div>
    <%
        }
    %>

</asp:Content>
