<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%
        if (ViewBag.Error == null)
        {
            Response.Write(Model.Nom + " - " + Model.NomAutor);
        }
        else
        {
            Response.Write(Lang.GetString(ViewBag.Lang, "Error"));
        }
    %>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript" src="<%: Url.Content("~/Scripts/Valoracio.js") %>"></script>
    <script type="text/javascript">
        <% if (ViewBag.Error == null)
           {
        %>
        $(document).ready(function () {
            carregarComentaris();
            carregarValoracions();
        });

        function carregarComentaris() {
            var params = {
                IdDocument: <%: Model.Id %>
            };

            $.ajax({
                url: '<%: Url.Action("GetComentaris", "Document") %>',
                data: params,
                dataType: 'json',
                async: false,
                success: function(data, textStatus, jqXHR) {
                    if (data.length == 0) {
                        $('#comentaris').html('<div style="text-align: center;"><%: Lang.GetString(ViewBag.Lang, "No_hi_ha_comentaris") %></div>');
                    } else {
                        var html = '';
                        
                        $.each(data, function(index, value) {
                            html += '<div class="comentari">';
                            html += '<span class="comentariAutor"><a href="' + value.LinkUsuari + '">' + value.NomUsuari + '</a></span> ';
                            html += '<span class="comentariData">(' + value.Data + ')</span><br />';
                            html += '<span class="comentariText">' + value.TextComentari + '</span>';
                            html += '</div>';
                        });

                        $('#comentaris').html(html);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    $('#comentaris').html('<div class="alert alert-danger"><%: Lang.GetString(ViewBag.Lang, "Error_comentaris") %>: ' + errorThrown + '</div>');
                }
            });
        }

        function enviarComentari() {
            var params = {
                IdDocument: <%: Model.Id %>,
                Comentari: $('textarea[name=comentari]').val()
            };

            $.ajax({
                url: '<%: Url.Action("Comentar", "Document") %>',
                data: params,
                dataType: 'json',
                type: 'post',
                async: false,
                success: function(data, textStatus, jqXHR) {
                    if (data == "Error") {
                        alert('<%: Lang.GetString(ViewBag.Lang, "Error_comentant") %>');
                    } else {
                        $('textarea[name=comentari]').val('');
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    alert('<%: Lang.GetString(ViewBag.Lang, "Error_comentant") %>: ' + errorThrown);
                }
            });
        }

        var originalSrc;

        function carregarValoracions() {
            var params = {
                Id: <%: Model.Id %>
            };

            $.ajax({
                url: '<%: Url.Action("Valoracio", "Document") %>',
                data: params,
                dataType: 'json',
                type: 'get',
                async: false,
                success: function(data) {
                    
                    var estrelles = getEstrelles(data);

                    originalSrc = [];
                    var html = '';
                    var i = 0;
                    while (i < 5 && estrelles[i] == 'full') {
                        html += '<img src="<%: Url.Content("~/Content/images/star-full.png") %>" id="estrella' + i + '" onmouseover="hover(' + i + ');" onmouseout="restaurarEstrelles();" onclick="valorar(' + i + ');" />';
                        originalSrc[i] = '<%: Url.Content("~/Content/images/star-full.png") %>';
                        i++;
                    }

                    while (i < 5 && estrelles[i] == 'half') {
                        html += '<img src="<%: Url.Content("~/Content/images/star-half.png") %>" id="estrella' + i + '" onmouseover="hover(' + i + ');" onmouseout="restaurarEstrelles();" onclick="valorar(' + i + ');" />';
                        originalSrc[i] = '<%: Url.Content("~/Content/images/star-half.png") %>';
                        i++;
                    }

                    while (i < 5) {
                        html += '<img src="<%: Url.Content("~/Content/images/star-empty.png") %>" id="estrella' + i + '" onmouseover="hover(' + i + ');" onmouseout="restaurarEstrelles();" onclick="valorar(' + i + ');" />';
                        originalSrc[i] = '<%: Url.Content("~/Content/images/star-empty.png") %>';
                        i++;
                    }

                    $('#valoracio').html(html);
                }
            });
        }

        function hover(numEstrella) {
            originalSrc = [];

            for (var i = 0; i <= numEstrella; i++) {
                originalSrc[i] = $('#estrella' + i).attr('src');
                $('#estrella' + i).attr('src', '<%: Url.Content("~/Content/images/star-full.png") %>');
            }

            for (var i = numEstrella + 1; i < 5; i++) {
                originalSrc[i] = $('#estrella' + i).attr('src');
                $('#estrella' + i).attr('src', '<%: Url.Content("~/Content/images/star-empty.png") %>');
            }
        }

        function restaurarEstrelles() {
            for (var i = 0; i < 5; i++) {
                $('#estrella' + i).attr('src', originalSrc[i]);
            }
        }

        function valorar(valoracio) {
            var params = {
                Id: <%: Model.Id %>,
                Valoracio: valoracio + 1
            };

            $.ajax({
                url: '<%: Url.Action("Valorar", "Document") %>',
                data: params,
                dataType: 'json',
                type: 'post',
                async: false,
                success: function(data) {
                    if (data != 'OK') {
                        alert('<%: Lang.GetString(ViewBag.Lang, "Error_valoracio") %>');
                    } else {
                        carregarValoracions();
                    }
                }
            });
        }

        <%
        }
        %>
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<%
    if (ViewBag.Error == null)
    { 
%>

<h2><%: Model.Nom%></h2>


<%
    if (Model.Tipus == TipusDocument.LinkYoutube)
    {
%>
<div class="youtubeContainer">
    <iframe width="560" height="315" src="<%: Model.Ruta %>" frameborder="0" allowfullscreen></iframe>
</div>
<%
    }
    else if (Model.MimeType == "application/pdf")
    {
%>
<iframe src="http://docs.google.com/gview?url=<%: Model.Ruta %>&embedded=true" style="width:718px; height:700px;" frameborder="0"></iframe>
<%
    }
%>
<div id="infoLeft" style="float: left;">
<%
    if (Model.Tipus != TipusDocument.LinkYoutube && Model.MimeType != "application/pdf")
    { 
%>
    <span class="glyphicon glyphicon-search"></span> <a href="<%: Url.Action("Descarregar", "Document", new { Id = Model.Id }) %>" target="_blank" style="font-size: medium;"><%: Lang.GetString(ViewBag.Lang, "Descarregar_document") %></a><br />
<%
    } 
%>
    <span style="font-size: small;"><%: Lang.GetString(ViewBag.Lang, "Autor") %>: <a href="<%: Model.LinkPerfilAutor %>"><%: Model.NomAutor %></a></span><br />
    <div id="valoracio"></div>
</div>

<div id="infoRight" style="float: right; font-style: italic; text-align: right;">
    <%: Lang.GetString(ViewBag.Lang, "Tipus") %>: <%: Lang.GetString(ViewBag.Lang, Model.Tipus.ToString()) %><br />
    <%: Lang.GetString(ViewBag.Lang, "Data_creacio") %>: <%: Model.DataAfegit.ToShortDateString() %><br />
    <%
        if (Model.DataModificat.HasValue)
        { %>
    <%: Lang.GetString(ViewBag.Lang, "Data_modificat") %>: <%: Model.DataModificat.Value.ToShortDateString() %><br />
    <%
        }

        if (Model.Versio.HasValue)
        { %>
    <%: Lang.GetString(ViewBag.Lang, "Versio") %>: <%: Model.Versio.Value %><br />
    <%
        }
    %>
</div>

<div style="clear: both;"></div>

<div id="comentaris">
    <div style="text-align: center;">
        <img src="<%= Url.Content( "~/Content/images/Loading.gif" ) %>" alt="<%: Lang.GetString(ViewBag.Lang, "Carregant") %>" />
        &nbsp;
        <%: Lang.GetString(ViewBag.Lang, "Carregant_comentaris") %>
    </div>
</div>

<form id="afegirComentari" action="#">
    <textarea name="comentari" rows="5" style="width: 98%; margin-bottom: 1em;" placeholder="<%: Lang.GetString(ViewBag.Lang, "Escriu_un_comentari") %>"></textarea>
    <button type="button" onclick="enviarComentari(); carregarComentaris();" class="btn btn-primary" style="float: right;"><span class="glyphicon glyphicon-edit"></span> <%: Lang.GetString(ViewBag.Lang, "Enviar") %></button>
</form>

<div style="clear: both;"></div>

<%  }
    else
    {
%>
    <div id="errors" class="alert alert-block alert-danger">
        <h4><%: Lang.GetString(ViewBag.Lang, "Error") %></h4>
        <p><%= ViewBag.Error %></p>
    </div>  
<%  }
%>

</asp:Content>