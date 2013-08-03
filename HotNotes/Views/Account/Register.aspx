﻿<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Register
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <script type="text/javascript">
        var passwords_no_coincideixen = '<%: Lang.GetString(lang, "Passwords_no_coincideixen") %>';
    </script>

    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Registrat") %></h1>
    </hgroup>

    <% using (Html.BeginForm()) { %>
        <%: Html.AntiForgeryToken() %>
        <%: Html.ValidationSummary() %>
        
        <div id="errors" class="alert alert-block alert-danger hide" style="margin-right: 0.8em;">
            <% if (ViewBag.Error != null)
               { %>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <h4><%: Lang.GetString(lang, "Error") %></h4>
            <p><%= ViewBag.Error %></p>
            <script type="text/javascript">
                $('#errors').removeClass('hide');
            </script>
            <% } %>
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
                    <label for="Sexe"><%: Lang.GetString(lang, "Sexe") %></label>
                    <select name="Sexe">
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
            $('form').submit(function () {
                var pass1 = $('input[name=Password]').val();
                var pass2 = $('input[name=ConfirmarPassword]').val();

                if (pass1 != pass2) {
                    $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button>'
                      + '<h4>Error</h4>'
                      + '<p>' + passwords_no_coincideixen + '</p>');
                    $('#errors').removeClass('hide');
                    return false;
                }

                var passenc = CryptoJS.SHA3(pass1);
                $('input[name=PasswordEnc]').val(passenc);
                $('input[name=Password]').val('');
                $('input[name=ConfirmarPassword]').val('');
                return true;
            });
        });
    </script>
</asp:Content>
