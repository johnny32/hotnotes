<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Inicia_sessio") %>
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Inicia_sessio") %></h1>
    </hgroup>

    <% using (Html.BeginForm(new { ReturnUrl = ViewBag.ReturnUrl }))
        { %>
    <%: Html.AntiForgeryToken() %>
    <fieldset>
        <legend>Log in Form</legend>
        <ol>
            <li>
                <label for="UserName"><%: Lang.GetString(lang, "Username") %></label>
                <input name="Username" type="text" required/>
            </li>
            <li>
                <label for="Password"><%: Lang.GetString(lang, "Password") %></label>
                <input name="Password" type="password" required/>
            </li>
            <li>
                <label for="RememberMe"><%: Lang.GetString(lang, "No_tanquis_sessio") %></label>
                <input name="RememberMeCB" type="checkbox" value="dasdasd"/>
            </li>
        </ol>
        <input name="PasswordEnc" type="hidden" />
        <input name="RememberMe" type="hidden" />
        <input type="submit" value="<%: Lang.GetString(lang, "Inicia_sessio") %>" />
    </fieldset>
    <br />
    <p>
        <%: Html.ActionLink(Lang.GetString(lang, "Registrat"), "Register") %>
    </p>
    <% } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('form').submit(function () {
                var encpassword = CryptoJS.SHA3($('input[name=Password]').val());
                $('input[name=PasswordEnc]').val(encpassword.toString());
                $('input[name=Password]').val('');
                
                $('input[name=RememberMe]').val($('input[name=RememberMeCB]').prop('checked'));
            });
        });
    </script>
</asp:Content>