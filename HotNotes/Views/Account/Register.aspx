<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Register
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <script type="text/javascript">
        /*$(function () {
            $('#Birthday')[0].datepicker({
                changeMonth: true,
                changeYear: true
            });
        });*/
    </script>
    <hgroup class="title">
        <h1>Register.</h1>
        <h2>Create a new account.</h2>
    </hgroup>

    <% using (Html.BeginForm()) { %>
        <%: Html.AntiForgeryToken() %>
        <%: Html.ValidationSummary() %>

        <div id="errors" class="alert alert-error" style="width: 80%; margin-left: auto; margin-right: auto;">
            <% if (ViewBag.Error != null)
               {
                   Response.Write(ViewBag.Error);
               } %>
        </div>

        <fieldset>
            <legend>Registration Form</legend>
            <ol class="form-input">
                <li class="form-left-column">
                    <label for="Username"><%: Lang.GetString(lang, "Username") %></label>
                    <input name="Username" type="text" required/>
                </li>
                <li class="form-right-column">
                    <label for="Nom"><%: Lang.GetString(lang, "Nom") %></label>
                    <input name="Nom" type="text" required/>
                </li>
                <li class="form-left-column">
                    <label for="Password"><%: Lang.GetString(lang, "Password") %></label>
                    <input name="Password" type="password" required/>
                </li>
                <li class="form-right-column">
                    <label for="Cognoms"><%: Lang.GetString(lang, "Cognoms") %></label>
                    <input name="Cognoms" type="text" required/>
                </li>
                <li class="form-left-column">
                    <label for="ConfirmarPassword"><%: Lang.GetString(lang, "Confirma_password") %></label>
                    <input name="ConfirmarPassword" type="password" required />
                </li>
                <li class="form-right-column">
                    <label for="DataNaixement"><%: Lang.GetString(lang, "Data_naixement") %></label>
                    <input name="DataNaixement" type="date" required/>
                </li>
                <li class="form-left-column">
                    <label for="Email"><%: Lang.GetString(lang, "Correu_electronic") %></label>
                    <input name="Email" type="email" required />
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
            <input name="PasswordEnc" type="hidden" />
            <input style="clear: both;" type="submit" value="Register" />
        </fieldset>
    <% } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#errors').html().trim() == '') {
                $('#errors').hide();
            }

            $('form').submit(function () {
                
            });
        });
    </script>
</asp:Content>
