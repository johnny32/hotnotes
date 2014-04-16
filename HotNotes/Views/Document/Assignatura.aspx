<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.DocumentLlistat>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.Nom %>
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
        $(document).ready(function () {
            $('#tableDocuments').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'l>r>t<'row-fluid'<'col-md-5'i><'col-sd-9'p>>",
                sPaginationType: 'bootstrap',
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                oLanguage: {
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
                },
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
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% if (ViewBag.Error == null)
       { %>
    <% string lang = ViewBag.Lang; %>
    <h2 style="margin-bottom: 2em;"><%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.Nom %></h2>

    <table id="tableDocuments" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Nom") %></th>
                <th><%: Lang.GetString(lang, "Tipus") %></th>
                <th><%: Lang.GetString(lang, "Username") %></th>
                <th><%: Lang.GetString(lang, "Data_creacio") %></th>
                <th><%: Lang.GetString(lang, "Valoracio") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (DocumentLlistat d in Model)
            { 
        %>
            <tr>
                <td><a href="<%: Url.Action("Veure", "Document", new { Id = d.Id }) %>"><%: d.Nom %></a></td>
                <td><%: Lang.GetString(lang, d.Tipus.ToString()) %></td>
                <td><a href="<%: Url.Action("Perfil", "Usuari", new { Id = d.IdUsuari }) %>"><%: d.Username %></a></td>
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

                    for (int i = 0; i < partEntera; i++) 
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
    <%
    }
    else
    { %>
    <div class="alert alert-danger"><%: ViewBag.Error %></div>
    <% } %>
</asp:Content>
