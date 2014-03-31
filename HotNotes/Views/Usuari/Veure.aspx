<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Usuari>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <%  string lang = ViewBag.Lang;
        if (ViewBag.Error == null)
        { %>
    <%: Lang.GetString(lang, "Perfil_usuari") %> <%: Model.Username %>
    <%  }
        else
        { %>
    <%: Lang.GetString(lang, "Error") %>
    <%  } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
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
                        $('#buttonFollow').html('<button type="button" class="btn btn-danger" onclick="dessubscriure(<%: Model.Id %>);"><%: Lang.GetString(lang, "Dessubscriures") %></button>');
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
                        $('#buttonFollow').html('<button type="button" class="btn btn-success" onclick="subscriure(<%: Model.Id %>);"><%: Lang.GetString(lang, "Subscriures") %></button>');
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
<div class="row-fluid">
    <div class="col-md-9">
        <h2><%: Model.Username %></h2>
    </div>
    <div class="col-md-3">
        <div id="buttonFollow">
        <% if (Model.ElSegueixo)
           { %>
            <button type="button" class="btn btn-danger" onclick="dessubscriure(<%: Model.Id %>);"><%: Lang.GetString(lang, "Dessubscriures") %></button>
        <% }
           else
           { %>
            <button type="button" class="btn btn-success" onclick="subscriure(<%: Model.Id %>);"><%: Lang.GetString(lang, "Subscriures") %></button>
        <% } %>
        </div>
    <% if (Model.EmSegueix)
       { %>
        <div style="margin-top: 0.7em;">
            <span style="padding: 0.25em; background-color: darkgray; color: white;"><%: Lang.GetString(lang, "Et_segueix") %></span>
        </div>
    <% } %>
    </div>
</div>
<div class="row-fluid">

</div>
<%  }
    else
    { %>
        <script>
            $('#errors').removeClass('hide');
        </script>
<%  } %>
</asp:Content>


