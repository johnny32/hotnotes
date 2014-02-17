<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Document>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.Nom %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script src="<%: Url.Content("~/Plugins/jquery.bootpag.min.js") %>"></script>
    <script src="<%: Url.Content("~/Scripts/Filtre.js") %>"></script>
    <script>
        var _offset = 0;
        var _amount = 20;

        function Filtre(tipus, id, offset, amount) {
            _offset = offset;
            _amount = amount;
            _total = <%: ViewBag.Total %>;

            $('#documentsContainer').html('');

            $.ajax({
                url: NETUrl('Document/Filtre?Tipus=' + tipus + '&Id=' + id + '&Offset=' + offset + '&Amount=' + amount),
                dataType: 'json',
                type: 'GET',
                success: function (data, textStatus, jqXHR) {
                    var html = '';
                    $.each(data, function (i, item) {
                        html += '<div id="document' + item.Id + '" class="documentListItem">';
                        html += '<div style="float: left">';
                        html += '<h3><a href="' + NETUrl('Document/Veure/' + item.Id) + '">' + item.Nom + '</a></h3>';
                        html += '<span style="font-size: small;"><%: Lang.GetString(ViewBag.Lang, "Autor") %>: <a href="' + NETUrl('Usuari/' + item.IdUsuari) + '">' + item.Username + '</a></span>';
                        html += '</div>';
                        html += '<div style="float: right">';
                        html += '<%: Lang.GetString(ViewBag.Lang, "Data_creacio") %>: ' + item.DataAfegit + '<br />';
                        html += '<%: Lang.GetString(ViewBag.Lang, "Assignatura") %>: <a href="' + NETUrl('Document/Assignatura/' + item.IdAssignatura) + '">' + item.NomAssignatura + '</a><br />';
                        html += '<span style="font-size: small;">(' + item.NomCarrera + ')</span>';
                        html += '</div>';
                        html += '<div style="clear: both;"></div>';
                        html += '</div>';
                    });

                    $('#documentsContainer').append(html);
                    
                    var currentPage = Math.round(_offset / _amount + 1);

                    html = '';

                    var j = 1;

                    for (var i = 0; i <= _total; i += _amount) {
                        if (j == currentPage) {
                            html += '<li class="active"><a href="#" data-page="' + j + '" onclick="Filtre(\'Assignatura\', <%: ViewBag.Id %>, ' + (i + 1) + ', _amount);">' + j + '</a></li>';
                            if (j == 1) {
                                prevPage = '<li class="disabled"><a href="#">&laquo;</a></li>';
                            } else {
                                prevPage = '<li><a href="#" id="prevPage" data-page="' + (j - 1) + '" onclick="Filtre(\'Assignatura\', <%: ViewBag.Id %>, ' + (i - 19) + ', _amount);">&laquo;</a></li>';
                            }
                            if (i < _total - 20) {
                                nextPage = '<li><a href="#" id="prevPage" data-page="' + (j + 1) + '" onclick="Filtre(\'Assignatura\', <%: ViewBag.Id %>, ' + (i + 21) + ', _amount);">&laquo;</a></li>';
                            } else {
                                nextPage = '<li class="disabled"><a href="#">&raquo;</a></li>';
                            }
                        } else {
                            html += '<li><a href="#" data-page="' + j + '" onclick="Filtre(\'Assignatura\', <%: ViewBag.Id %>, ' + (i + 1) + ', _amount);">' + j + '</a></li>';
                        }
                        j++;
                    }

                    $('ul.pagination').html(prevPage + html + nextPage);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert(errorThrown);
                }
            });
        }

        $(document).ready(function () {
            Filtre('Assignatura', <%: ViewBag.Id %>, _offset, _amount);
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2><%: Lang.GetString(lang, "Documents_assignatura") %>: <%: ViewBag.Nom %></h2>

    <div id="documentsContainer"></div>

    <div style="text-align: right;">
        <div class="dropdown">
            <a id="dLabel" role="button" data-toggle="dropdown" data-target="#" href="/page.html">
                Dropdown <span class="caret"></span>
            </a>
            <ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
                <li><a href="#" onclick="Filtre('Assignatura', <%: ViewBag.Id %>, _offset, 10);">10</a></li>
                <li><a href="#" onclick="Filtre('Assignatura', <%: ViewBag.Id %>, _offset, 20);">20</a></li>
                <li><a href="#" onclick="Filtre('Assignatura', <%: ViewBag.Id %>, _offset, 50);">50</a></li>
                <li><a href="#" onclick="Filtre('Assignatura', <%: ViewBag.Id %>, _offset, 100);">100</a></li>
            </ul>
        </div>

        <ul class="pagination"></ul>
        <br />
        <%: Lang.GetString(lang, "Total") + ": " + ViewBag.Total + " " + Lang.GetString(lang, "Documents").ToLower() %>
    </div>
</asp:Content>
