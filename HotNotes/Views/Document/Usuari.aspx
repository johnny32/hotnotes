<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.DocumentLlistat>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Documents_usuari") %>: <%: ViewBag.Username %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Styles.Render("~/Plugins/DataTables/css/jquery.dataTables.css") %>
    <%: Styles.Render("~/Plugins/DataTables/css/dataTables.bootstrap.css") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/jquery.dataTables.min.js") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/dataTables.bootstrap.js") %>
    <script>
        $(document).ready(function () {
            $('#tableDocuments').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'i>r>t<'row-fluid'<'col-md-5'l><'col-sd-9'p>>",
                sPaginationType: 'bootstrap',
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                aoColumns: [
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2 style="margin-bottom: 2em;"><%: Lang.GetString(lang, "Documents_usuari") %>: <%: ViewBag.Username %></h2>

    <table id="tableDocuments" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Nom") %></th>
                <th><%: Lang.GetString(lang, "Tipus") %></th>
                <th><%: Lang.GetString(lang, "Assignatura") %></th>
                <th><%: Lang.GetString(lang, "Data_creacio") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (DocumentLlistat d in Model)
            { 
        %>
            <tr>
                <td><a href="<%: Url.Action("Veure", "Document", new { Id = d.Id }) %>"><%: d.Nom %></a></td>
                <td><%: d.Tipus.ToString() %></td>
                <td><a href="<%: Url.Action("Assignatura", "Document", new { Id = d.IdAssignatura }) %>"><%: d.NomAssignatura %></a></td>
                <td><%: d.DataAfegit.ToShortDateString() %> <%: d.DataAfegit.ToShortTimeString() %></td>
            </tr>
        <%
            } 
        %>
        </tbody>
    </table>

</asp:Content>
