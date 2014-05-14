<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Area_administradors") %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script>
        $(document).ready(function() {
            $('form').submit(function () {
                var encpassword = CryptoJS.SHA3($('#password').val());
                $('#PasswordEnc').val(encpassword.toString());
                $('#password').val('');

                $('#RememberMe').val($('#RememberMeCB').prop('checked'));
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2><%: Lang.GetString(lang, "Area_administradors") %></h2>
    
    <% if (ViewBag.Error != null)
       { %>
    <div class="alert alert-danger">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <h4><%: Lang.GetString(lang, "Error") %></h4>
        <p><%= ViewBag.Error %></p>
    </div>
    <% } %>
    
    <div class="well">
        <form role="form" action="<%: Url.Action("Login", "Admin") %>" method="POST">
            <div class="form-group">
                <label for="username"><%: Lang.GetString(lang, "Username") %>:</label>
                <input id="username" name="Username" type="text" class="form-control" value="" />
            </div>
            <div class="form-group">
                <label for="password"><%: Lang.GetString(lang, "Password") %>:</label>
                <input id="password" name="Password" type="password" class="form-control" value="" />
            </div>
            <div class="checkbox">
                <label>
                    <input type="checkbox" id="RememberMeCB"> <%: Lang.GetString(lang, "No_tanquis_sessio") %>
                </label>
            </div>
            <input type="hidden" id="PasswordEnc" name="PasswordEnc" value=""/>
            <input type="hidden" id="RememberMe" name="RememberMe" value="false" />
            <button type="submit" class="btn btn-default"><%: Lang.GetString(lang, "Inicia_sessio") %></button>
        </form>
    </div>

</asp:Content>