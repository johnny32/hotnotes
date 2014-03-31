<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<HotNotes.Models.Usuari, System.Collections.Generic.List<HotNotes.Models.Matricula>>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Perfil_usuari") %> <%: Model.Item1.Username %>
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
    <script>
        function subscriure(id) {
            var params = {
                IdUsuariSubscrit: id
            };

            $.ajax({
                url: '<%: Url.Action("Subscriure", "Usuari") %>',
                type: 'post',
                data: params,
                dataType: 'json',
                success: function (data) {
                    if (data == 'OK') {
                        $('#buttonFollow').html('<button type="button" class="btn btn-danger" onclick="dessubscriure(<%: Model.Item1.Id %>);"><%: Lang.GetString(lang, "Dessubscriures") %></button>');
                    } else {
                        $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + data + '</p>');
                        $('#errors').removeClass('hide');
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + errorThrown + '</p>');
                    $('#errors').removeClass('hide');
                }
            })
        }

        function dessubscriure(id) {
            var params = {
                IdUsuariSubscrit: id
            };

            $.ajax({
                url: '<%: Url.Action("Dessubscriure", "Usuari") %>',
                type: 'post',
                data: params,
                dataType: 'json',
                success: function (data) {
                    if (data == 'OK') {
                        $('#buttonFollow').html('<button type="button" class="btn btn-success" onclick="subscriure(<%: Model.Item1.Id %>);"><%: Lang.GetString(lang, "Subscriures") %></button>');
                    } else {
                        $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + data + '</p>');
                        $('#errors').removeClass('hide');
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + errorThrown + '</p>');
                    $('#errors').removeClass('hide');
                }
            })
        }

        $(document).ready(function () {
            tableMatriculesObj = $('#tableMatricules').dataTable({
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
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: false },
                    { bSearchable: true, bSortable: false }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="errors" class="alert alert-block alert-danger hide">
        <% if (ViewBag.Error != null)
            { %>
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <p><%= ViewBag.Error %></p>
        <% } %>
    </div>   

    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <div class="row">
        <div class="col-md-10">
            <h2><%: Model.Item1.Username %></h2>
        </div>
        <div class="col-md-2">
            <div id="buttonFollow">
            <% if (Model.Item1.ElSegueixo)
               { %>
                <button type="button" class="btn btn-danger" onclick="dessubscriure(<%: Model.Item1.Id %>);"><%: Lang.GetString(lang, "Dessubscriures") %></button>
            <% }
               else
               { %>
                <button type="button" class="btn btn-success" onclick="subscriure(<%: Model.Item1.Id %>);"><%: Lang.GetString(lang, "Subscriures") %></button>
            <% } %>
            </div>
        <% if (Model.Item1.EmSegueix)
           { %>
            <div style="margin-top: 0.7em;">
                <span style="padding: 0.25em; background-color: darkgray; color: white;"><%: Lang.GetString(lang, "Et_segueix") %></span>
            </div>
        <% } %>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <%: Model.Item1.Nom %> <%: Model.Item1.Cognoms %>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <%: Lang.GetString(lang, "Num_documents_pujats") %>: <%: Model.Item1.NumDocumentsPujats %>
            &nbsp;
            <a href="<%: Url.Action("Usuari", "Document", new { Id = Model.Item1.Id }) %>" class="btn btn-default"><span class="glyphicon glyphicon-eye-open"></span> <%: Lang.GetString(lang, "Veure") %></a>
        </div>
    </div>

    <h2><%: Lang.GetString(lang, "Cursos_matriculats") %></h2>
    <table id="tableMatricules" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Carrera") %></th>
                <th><%: Lang.GetString(lang, "Curs") %></th>
                <th><%: Lang.GetString(lang, "Facultat") %></th>
                <th><%: Lang.GetString(lang, "Universitat") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (Matricula m in Model.Item2)
            { %>
            <tr>
                <td><%: m.NomCarrera %></td>
                <td><%: m.Curs %></td>
                <td><%: m.NomFacultat %></td>
                <td><%: m.NomUniversitat %></td>
            </tr>
        <%  } %>
        </tbody>
    </table>
    <%  }
        else
        { %>
            <script>
                $('#errors').removeClass('hide');
            </script>
    <%  } %>
</asp:Content>


