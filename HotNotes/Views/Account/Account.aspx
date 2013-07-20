<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.LoginModel>" %>
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
    <%: Html.ValidationSummary(true) %>
    <fieldset>
        <legend>Log in Form</legend>
        <ol>
            <li>
                <label for="UserName">
                    <%: Lang.GetString(lang, "Username") %></label>
                <%: Html.TextBoxFor(m => m.UserName) %>
                <%: Html.ValidationMessageFor(m => m.UserName) %>
            </li>
            <li>
                <label for="UserName">
                    <%: Lang.GetString(lang, "Password") %></label>
                <%: Html.PasswordFor(m => m.Password) %>
                <%: Html.ValidationMessageFor(m => m.Password) %>
            </li>
            <li>
                <%: Html.CheckBoxFor(m => m.RememberMe) %>
                <%: Html.LabelFor(m => m.RememberMe, new { @class = "checkbox" }) %>
            </li>
        </ol>
        <%: Html.HiddenFor(m => m.PasswordEnc) %>
        <input type="submit" value="<%: Lang.GetString(lang, "Inicia_sessio") %>" />
    </fieldset>
    <br />
    <p>
        <%: Html.ActionLink(Lang.GetString(lang, "Registrat"), "Register") %>
    </p>
    <% } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/jqueryval") %>

    <script type="text/javascript">
        $(document).ready(function () {
            $('form').submit(function () {
                var encpassword = CryptoJS.SHA3($('#Password').val());
                $('#PasswordEnc').val(encpassword.toString());
                $('#Password').val('');
            });
        });
    </script>
</asp:Content>