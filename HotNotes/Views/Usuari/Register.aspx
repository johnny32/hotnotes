<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Registrarse")  %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <% string lang = ViewBag.Lang; %>

    <script type="text/javascript">
        var username_curt = '<%: Lang.GetString(lang, "Username_curt") %>';
        var passwords_no_coincideixen = '<%: Lang.GetString(lang, "Passwords_no_coincideixen") %>';
        var password_curta = '<%: Lang.GetString(lang, "Password_curta") %>';
        var major_edat = '<%: Lang.GetString(lang, "Major_edat") %>';

        $(document).ready(function () {
            $('form').submit(function () {
                var username = $('input[name=Username]').val();
                var pass1 = $('input[name=Password]').val();
                var pass2 = $('input[name=ConfirmarPassword]').val();
                var datanaixementstring = $('input[name=DataNaixement]').val();

                var errormsg = '';

                if (username.length < 6) {
                    errormsg = username_curt;
                } else if (pass1 != pass2) {
                    errormsg = passwords_no_coincideixen;
                } else if (pass1.length < 6 || pass2.length < 6) {
                    errormsg = password_curta;
                } else {
                    datanaixement = new Date(datanaixementstring);
                    avui = new Date();
                    avui.setHours(0);
                    avui.setMinutes(0);
                    avui.setSeconds(0);
                    avui.setMilliseconds(0);
                    fa18anys = new Date(avui.getFullYear() - 18, avui.getMonth(), avui.getDate(), 0, 0, 0, 0);

                    if (datanaixement > fa18anys) {
                        errormsg = major_edat;
                    }
                }

                if (errormsg != '') {
                    $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button>'
                      + '<h4>Error</h4>'
                      + '<p>' + errormsg + '</p>');
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

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <style>
        .container input, .container select
        {
            width: 100%;
            height: 2em;
        }
        
        .col-md-3
        {
            padding-bottom: 0.25em;
        }
    </style>

    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Registrat") %></h1>
    </hgroup>

    <% using (Html.BeginForm()) { %>
        <%: Html.AntiForgeryToken() %>
        <%: Html.ValidationSummary() %>
        
        <div id="errors" class="alert alert-block alert-danger hide">
            <% if (ViewBag.Error != null)
               { %>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <h4><%: Lang.GetString(lang, "Error") %></h4>
            <p><%= ViewBag.Error %></p>
            <script>
                $('#errors').removeClass('hide');
            </script>
            <% } %>
        </div>        

        <fieldset>
            <legend>Registration Form</legend>
            <div class="container" style="width: 100%;">
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Username"><%: Lang.GetString(lang, "Username") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Username" type="text" tabindex="1" required/>
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Nom"><%: Lang.GetString(lang, "Nom") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Nom" type="text" tabindex="5" required/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Password"><%: Lang.GetString(lang, "Password") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Password" type="password" tabindex="2" required/>
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Cognoms"><%: Lang.GetString(lang, "Cognoms") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Cognoms" type="text" tabindex="6" required/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="ConfirmarPassword"><%: Lang.GetString(lang, "Confirma_password") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="ConfirmarPassword" type="password" tabindex="3" required />
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="DataNaixement"><%: Lang.GetString(lang, "Data_naixement") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="DataNaixement" type="date" tabindex="7" required/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Email"><%: Lang.GetString(lang, "Correu_electronic") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Email" type="email" tabindex="4" required />
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Sexe"><%: Lang.GetString(lang, "Sexe") %></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <select name="Sexe" tabindex="8">
                            <option value="-" selected><%: Lang.GetString(lang, "No_especificat") %></option>
                            <option value="H"><%: Lang.GetString(lang, "Home") %></option>
                            <option value="D"><%: Lang.GetString(lang, "Dona") %></option>
                        </select>
                    </div>
                </div>
            </div>
            <input name="PasswordEnc" type="hidden" />
            <div class="text-center" style="margin: 2em;">
                <button type="submit" tabindex="9" class="btn btn-info"><%: Lang.GetString(lang, "Registrarse") %></button>
            </div>
        </fieldset>
    <% } %>
</asp:Content>