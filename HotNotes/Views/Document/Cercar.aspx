<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<List<HotNotes.Models.DocumentLlistat>, List<HotNotes.Models.Assignatura>, List<HotNotes.Models.Usuari>>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Resultats_cerca") %>: <%: ViewBag.TermesCerca %>
    <%  }
        else
        { %>
    <%: Lang.GetString(lang, "Error") %>
    <%  } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Styles.Render("~/Plugins/DataTables/css/jquery.dataTables.css") %>
    <%: Styles.Render("~/Plugins/DataTables/css/dataTables.bootstrap.css") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/jquery.dataTables.min.js") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/dataTables.bootstrap.js") %>
    <%: Scripts.Render("~/Scripts/Ordenacio_DataTables.js") %>
    <script>
        var translations = {
            sLengthMenu: '<%: Lang.GetString(lang, "DT_sLengthMenu") %>',
            sZeroRecords: '<%: Lang.GetString(lang, "DT_sZeroRecords") %>',
            sInfo: '<%: Lang.GetString(lang, "DT_sInfo") %>',
            sInfoEmpty: '<%: Lang.GetString(lang, "DT_sInfoEmpty") %>',
            sInfoFiltered: '<%: Lang.GetString(lang, "DT_sInfoFiltered") %>',
            sProcessing: '<%: Lang.GetString(lang, "DT_sProcessing") %>',
            sEmptyTable: '<%: Lang.GetString(lang, "DT_sEmptyTable") %>',
            sSearch: '<%: Lang.GetString(lang, "DT_sSearch") %>',
            oPaginate: {
                sFirst: '<%: Lang.GetString(lang, "DT_sFirst") %>',
                sPrevious: '<%: Lang.GetString(lang, "DT_sPrevious") %>',
                sNext: '<%: Lang.GetString(lang, "DT_sNext") %>',
                sLast: '<%: Lang.GetString(lang, "DT_sLast") %>'
            }
        };

        $(document).ready(function () {
            $('#tableDocuments').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'l>r>t<'row-fluid'<'col-md-5'i><'col-sd-9'p>>",
                sPaginationType: 'bootstrap',
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                aaSorting: [[4, 'desc']],
                oLanguage: translations,
                aoColumns: [
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true, sType: 'datetime', asSorting: ['desc', 'asc'] },
                    { bSearchable: false, bSortable: true, sType: 'valoracio', asSorting: ['desc', 'asc'] }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });

            $('#tableAssignatures').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'l>r>t<'row-fluid'<'col-md-5'i><'col-sd-9'p>>",
                sPaginationType: 'bootstrap',
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                oLanguage: translations,
                aoColumns: [
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });

            $('#tableUsuaris').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'l>r>t<'row-fluid'<'col-md-5'i><'col-sd-9'p>>",
                sPaginationType: 'bootstrap',
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                oLanguage: translations,
                aoColumns: [
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });

            $('input[name=termesCerca]').val('<%= ViewBag.TermesCerca %>');
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 <% if (ViewBag.Error == null)
       { %>
    <% string lang = ViewBag.Lang; %>
    <h2 style="margin-bottom: 2em;"><%: Lang.GetString(lang, "Resultats_cerca") %>: "<%: ViewBag.TermesCerca %>"</h2>
    
    <h3><%: Lang.GetString(lang, "Documents") %></h3>
    <table id="tableDocuments" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Nom") %></th>
                <th><%: Lang.GetString(lang, "Username") %></th>
                <th><%: Lang.GetString(lang, "Assignatura") %></th>
                <th><%: Lang.GetString(lang, "Data_creacio") %></th>
                <th><%: Lang.GetString(lang, "Valoracio") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (DocumentLlistat d in Model.Item1)
            { 
        %>
            <tr>
                <td><a href="<%: Url.Action("Veure", "Document", new { Id = d.Id }) %>"><%: d.Nom %></a></td>
                <td><a href="<%: Url.Action("Usuari", "Document", new { Id = d.IdUsuari }) %>"><%: d.Username %></a></td>
                <td><a href="<%: Url.Action("Assignatura", "Document", new { Id = d.IdAssignatura }) %>"><%: d.NomAssignatura %></a></td>
                <td><%: d.DataAfegit.ToShortDateString() %> <%: d.DataAfegit.ToShortTimeString() %></td>
                <td>
                    <span data-valoracio="<%: d.Valoracio %>">
                    <%
                    double valoracio = d.Valoracio / 2;
                    int partEntera = Convert.ToInt32(Math.Floor(valoracio));
                    double partDecimal = valoracio - partEntera;
                    if (partDecimal < 0.25) 
                    {
                        partDecimal = 0;
                    } else if (partDecimal > 0.75) 
                    {
                        partEntera++;
                        partDecimal = 0;
                    } else 
                    {
                        partDecimal = 0.5;
                    }

                    for (var i = 0; i < partEntera; i++) 
                    { 
                    %>
                        <img src="<%: Url.Content("~/Content/images/star-full.png") %>" />
                    <%
                    }

                    if (partDecimal == 0.5) 
                    {
                    %>
                        <img src="<%: Url.Content("~/Content/images/star-half.png") %>" />
                    <%
                    }

                    for (int i = (partEntera + (int)(2 * partDecimal)); i < 5; i++) 
                    {
                    %>
                        <img src="<%: Url.Content("~/Content/images/star-empty.png") %>" />
                    <%
                    }
                    %>
                    </span>
                </td>
            </tr>
        <%
            } 
        %>
        </tbody>
    </table>
    
    <div style="clear: both; margin-bottom: 1.5em;"></div>
    
    <h3><%: Lang.GetString(lang, "Assignatures") %></h3>
    <table id="tableAssignatures" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Nom") %></th>
                <th><%: Lang.GetString(lang, "Carrera") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (Assignatura a in Model.Item2)
            { 
        %>
            <tr>
                <td><a href="<%: Url.Action("Assignatura", "Document", new { Id = a.Id }) %>"><%: a.Nom %></a></td>
                <td><%: a.Carrera.Nom %></td>
            </tr>
        <%
            } 
        %>
        </tbody>
    </table>
    
    <div style="clear: both; margin-bottom: 1.5em;"></div>

    <h3><%: Lang.GetString(lang, "Usuaris") %></h3>
    <table id="tableUsuaris" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Username") %></th>
                <th><%: Lang.GetString(lang, "Nom") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (Usuari u in Model.Item3)
            { 
        %>
            <tr>
                <td><a href="<%: Url.Action("Perfil", "Usuari", new { Id = u.Id }) %>"><%: u.Username %></a></td>
                <td><%: u.Nom %> <%: u.Cognoms %></td>
            </tr>
        <%
            } 
        %>
        </tbody>
    </table>
    <% }
       else
       { %>
    <div class="alert alert-danger"><%: ViewBag.Error %></div>
    <% } %>
</asp:Content>


