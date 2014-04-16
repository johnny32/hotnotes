<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Benvingut") %>
    <%  }
        else
        { %>
    <%: Lang.GetString(lang, "Error") %>
    <%  } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Styles.Render("~/Plugins/DataTables/css/jquery.dataTables.css") %>
    <%: Styles.Render("~/Plugins/DataTables/css/dataTables.bootstrap.css") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/jquery.dataTables.min.js") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/dataTables.bootstrap.js") %>
    <%: Scripts.Render("~/Scripts/Ordenacio_DataTables.js") %>
    <script>
        $(document).ready(function () {
            $.ajax({
                url: '<%: Url.Action("DocumentsPaginaPrincipal", "Home") %>',
                type: 'get',
                dataType: 'json',
                success: function (data) {
                    html = '<table id="tableDocuments" border="0" class="table table-striped table-bordered" style="width: 100%;">';
                    html += '<thead>';
                    html += '<tr>';
                    html += '<th><%: Lang.GetString(lang, "Nom") %></th>';
                    html += '<th><%: Lang.GetString(lang, "Tipus") %></th>';
                    html += '<th><%: Lang.GetString(lang, "Username") %></th>';
                    html += '<th><%: Lang.GetString(lang, "Assignatura") %></th>';
                    html += '<th><%: Lang.GetString(lang, "Data_creacio") %></th>';
                    html += '<th><%: Lang.GetString(lang, "Valoracio") %></th>';
                    html += '</tr>';
                    html += '</thead>';
                    html += '<tbody>';

                    $.each(data, function (i, item) {
                        html += '<tr>';
                        html += '<td><a href="' + item.LinkDocument + '">' + item.Nom + '</a></td>';
                        html += '<td>' + item.TipusString + '</td>';
                        html += '<td><a href="' + item.LinkUsuari + '">' + item.Username + '</a></td>';
                        html += '<td><a href="' + item.LinkAssignatura + '">' + item.NomAssignatura + '</a></td>';
                        html += '<td>' + item.DataAfegitString + '</td>';
                        html += '<td>';
                        html += '<span data-valoracio="' + item.Valoracio + '">';

                        var valoracio = item.Valoracio / 2.0;
                        var partEntera = Math.floor(valoracio);
                        var partDecimal = valoracio - partEntera;
                        
                        if (partDecimal < 0.25) {
                            partDecimal = 0;
                        } else if (partDecimal > 0.75) {
                            partEntera++;
                            partDecimal = 0;
                        } else {
                            partDecimal = 0.5;
                        }

                        for (var i = 0; i < partEntera; i++) { 
                            html += '<img src="<%: Url.Content("~/Content/images/star-full.png") %>" />';
                        }

                        if (partDecimal == 0.5) {
                            html += '<img src="<%: Url.Content("~/Content/images/star-half.png") %>" />';
                        }

                        for (var i = (partEntera + Math.round(2 * partDecimal)); i < 5; i++) {
                            html += '<img src="<%: Url.Content("~/Content/images/star-empty.png") %>" />';
                        }
                        
                        html += '</span>';
                        html += '</td>';
                        html += '</tr>';
                    });

                    html += '</tbody>';
                    html += '</table>';

                    $('#documentsContainer').html(html);

                    $('#tableDocuments').dataTable({
                        sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'l>r>t<'row-fluid'<'col-md-5'i><'col-sd-9'p>>",
                        sPaginationType: 'bootstrap',
                        bStateSave: false,
                        bAutoWidth: false,
                        bDestroy: true,
                        aaSorting: [[4, 'desc']],
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
                            { bSearchable: true, bSortable: true },
                            { bSearchable: true, bSortable: true, sType: 'datetime', asSorting: ['desc', 'asc'] },
                            { bSearchable: false, bSortable: true, sType: 'valoracio', asSorting: ['desc', 'asc'] }
                        ],
                        fnInitComplete: function () {
                            this.fnFilter('');
                        }
                    });
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#documentsContainer').html('<div id="errors" class="alert alert-block alert-danger"><button type="button" class="close" data-dismiss="alert">&times;</button><p>' + errorThrown + '</p></div>');
                }
            })
        });
    </script>
</asp:Content>

<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <h3><%: Lang.GetString(lang, "Benvingut_a_HotNotes") %></h3>

    <p id="info"><%: Html.Raw(Lang.GetString(lang, "Descripcio_portada").Replace("[[LINKABOUT]]", Html.ActionLink(Lang.GetString(lang, "Sobre_HotNotes"), "About", "Home", new { style = "text-decoration: underline;" }).ToHtmlString())) %></p>
    
    <div id="documentsContainer">
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%;">
                <%: Lang.GetString(lang, "Carregant_ultims_documents") %>
            </div>
        </div>
    </div>
</asp:Content>
