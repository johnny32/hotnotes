<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<%
    if (ViewBag.Error == null)
    { 
%>

<h2><%: Model.Nom%></h2>

<%
    if (Model.Tipus == TipusDocument.LinkYoutube || Model.Extensio == "pdf")
    {
        //Embed
    }    
%>

<div id="infoLeft" style="float: left;">
    <a href="<%: Model.Ruta %>" target="_blank" style="font-size: medium;"><%: Lang.GetString(ViewBag.Lang, "Descarregar_document") %></a><br />
    <span style="font-size: small;"><%: Lang.GetString(ViewBag.Lang, "Autor") %>: <a href="<%: Model.LinkPerfilAutor %>"><%: Model.NomAutor %></a></span>
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

<form id="afegirComentari">
    <textarea name="comentari" rows="5" style="width: 98%;" placeholder="<%: Lang.GetString(ViewBag.Lang, "Escriu_un_comentari") %>"></textarea>
    <input type="submit" style="float: right;" value="<%: Lang.GetString(ViewBag.Lang, "Enviar") %>" />
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

<asp:Content ID="Content3" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            carregarComentaris();
        });

        $("#afegirComentari").submit(function () {
            enviarComentari();
            carregarComentaris();
            return false;
        });

        function carregarComentaris() {
            var params = {
                IdDocument: <%: Model.Id %>
            };

            $.ajax({
                url: '<%: Url.Action("GetComentaris", "Document") %>',
                data: params,
                dataType: 'json',
                success: function(data, textStatus, jqXHR) {
                    if (data.length == 0) {
                        $('#comentaris').html('<div style="text-align: center;"><%: Lang.GetString(ViewBag.Lang, "No_hi_ha_comentaris") %></div>');
                    } else {
                        var html = '';
                        
                        $.each(data, function(index, value) {
                            html += '<div id="comentari">';
                            html += '<span style="font-weight: bold;"><a href="' + value.LinkUsuari + '">' + value.NomUsuari + '</a></span> ';
                            html += '<span style="color: lightgray; font-style: italic; font-size: small;">(' + value.Data + ')</span><br />';
                            html += '<span>' + value.TextComentari + '</span>';
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
    </script>
</asp:Content>
