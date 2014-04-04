<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<HotNotes.Models.Usuari, List<HotNotes.Models.Usuari>>>" %>
<%@ Import Namespace="HotNotes.Models" %>
<%@ Import Namespace="HotNotes.Helpers" %>

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
    <% if (ViewBag.Error != null)
       { %>
    <script>
        $(document).ready(function () {
            $('#errors').removeClass('hide');
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
    <h2><%: Lang.GetString(lang, "Seguidors_usuari") %> <%: Model.Item1.Username %></h2>

    <ul>
        <% foreach (Usuari u in Model.Item2)
           { %>
        <li><a href="<%: Url.Action("Veure", "Usuari", new { Id = u.Id }) %>"><%: u.Nom %> <%: u.Cognoms %></a></li>
        <% } %>
    </ul>

    <% } %>

</asp:Content>
