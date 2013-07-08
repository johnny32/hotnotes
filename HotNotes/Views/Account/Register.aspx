<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.RegisterModel>" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Register
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <script type="text/javascript">
        $(function () {
            $('#Birthday')[0].datepicker({
                changeMonth: true,
                changeYear: true
            });
        });
    </script>
    <hgroup class="title">
        <h1>Register.</h1>
        <h2>Create a new account.</h2>
    </hgroup>

    <% using (Html.BeginForm()) { %>
        <%: Html.AntiForgeryToken() %>
        <%: Html.ValidationSummary() %>

        <fieldset>
            <legend>Registration Form</legend>
            <ol class="form-input">
                <li class="form-left-column">
                    <label for="UserName"><%: Lang.GetString(lang, "Username") %></label>
                    <%: Html.TextBoxFor(m => m.UserName) %>
                </li>
                <li class="form-right-column">
                    <label for="Name"><%: Lang.GetString(lang, "Nom") %></label>
                    <%: Html.TextBoxFor(m => m.Name) %>
                </li>
                <li class="form-left-column">
                    <label for="Password"><%: Lang.GetString(lang, "Password") %></label>
                    <%: Html.PasswordFor(m => m.Password) %>
                </li>
                <li class="form-right-column">
                    <label for="LastName"><%: Lang.GetString(lang, "Cognoms") %></label>
                    <%: Html.TextBoxFor(m => m.LastName) %>
                </li>
                <li class="form-left-column">
                    <label for="ConfirmPassword"><%: Lang.GetString(lang, "Confirma_password") %></label>
                    <%: Html.PasswordFor(m => m.ConfirmPassword) %>
                </li>
                <li class="form-right-column">
                    <label for="Birthday"><%: Lang.GetString(lang, "Data_naixement") %></label>
                    <%: Html.TextBoxFor(m => m.Birthday) %>
                </li>
                <li class="form-left-column">
                    <label for="Email"><%: Lang.GetString(lang, "Correu_electronic") %></label>
                    <%: Html.TextBoxFor(m => m.Email) %>
                </li>
                <li class="form-right-column">
                    <label for="Gender"><%: Lang.GetString(lang, "Sexe") %></label>
                    <select name="Gender">
                        <option value="-" selected><%: Lang.GetString(lang, "No_especificat") %></option>
                        <option value="H"><%: Lang.GetString(lang, "Home") %></option>
                        <option value="D"><%: Lang.GetString(lang, "Dona") %></option>
                    </select>
                </li>
            </ol>
            <input style="clear: both;" type="submit" value="Register" />
        </fieldset>
    <% } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/jqueryval") %>
</asp:Content>
