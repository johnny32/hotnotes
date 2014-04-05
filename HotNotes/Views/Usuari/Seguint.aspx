<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<HotNotes.Models.Usuari, List<HotNotes.Models.Usuari>>>" %>
<%@ Import Namespace="HotNotes.Models" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Usuaris_segueix") %> <%: Model.Item1.Username %>
    <%  }
        else
        { %>
    <%: Lang.GetString(lang, "Error") %>
    <%  } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Styles.Render("~/Plugins/DataTables/css/jquery.dataTables.css") %>
    <%: Styles.Render("~/Plugins/DataTables/css/dataTables.bootstrap.css") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/jquery.dataTables.min.js") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/dataTables.bootstrap.js") %>

    <% string lang = ViewBag.Lang; %>
    <% if (ViewBag.Error != null)
       { %>
    <script>
        $(document).ready(function () {
            $('#errors').removeClass('hide');
        });
    </script>
    <% }
       else
       { %>
    <script>
        $(document).ready(function () {
            tableSeguidorsObj = $('#tableSeguint').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'>r>t",
                bPaginate: false,
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
                    { bSearchable: false, bSortable: false }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });
        });
    </script>
    <% } %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <div id="errors" class="alert alert-block alert-danger hide">
        <% if (ViewBag.Error != null)
            { %>
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <p><%= ViewBag.Error %></p>
        <% } %>
    </div>  

    <% if (ViewBag.Error == null)
       { %>
    <h2 style="margin-bottom: 1em;"><%: Lang.GetString(lang, "Usuaris_segueix") %> <%: Model.Item1.Username %></h2>

    <table id="tableSeguint" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Nom") %></th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <% foreach (Usuari u in Model.Item2)
           { %>
            <tr>
                <td><%: u.Nom %> <%: u.Cognoms %></td>
                <td><a href="<%: Url.Action("Perfil", "Usuari", new { Id = u.Id }) %>" class="btn btn-default btn-sm"><span class="glyphicon glyphicon-eye-open"></span> <%: Lang.GetString(lang, "Veure_perfil") %></a></td>
            </tr>
        <% } %>
        </tbody>
    </table>

    <% } %>

</asp:Content>
