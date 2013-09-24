<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Usuari>" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Register
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <script type="text/javascript">
        var username_curt = '<%: Lang.GetString(lang, "Username_curt") %>';
        var passwords_no_coincideixen = '<%: Lang.GetString(lang, "Passwords_no_coincideixen") %>';
        var password_curta = '<%: Lang.GetString(lang, "Password_curta") %>';
        var major_edat = '<%: Lang.GetString(lang, "Major_edat") %>';
    </script>

    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Modificar_dades") %></h1>
    </hgroup>

     <% if (ViewBag.Message != null)
        { %>
        <div id="Div2" class="alert alert-block alert-info">       
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <p><%= ViewBag.Message %></p>
        </div>
    <% } %>

    <div id="errors" class="alert alert-block alert-danger hide">
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

    <% if (ViewBag.Error == null)
       { %>

    <% using (Html.BeginForm())
       { %>
        <%: Html.AntiForgeryToken()%>
        <%: Html.ValidationSummary()%>

        <fieldset>
            <legend>Registration Form</legend>
            <ol class="form-input">
                <li class="form-left-column">
                    <label for="Username"><%: Lang.GetString(lang, "Username")%></label>
                    <input name="Username" type="text" tabindex="1" required value="<%: Model.Username %>"/>
                </li>
                <li class="form-right-column">
                    <label for="Nom"><%: Lang.GetString(lang, "Nom")%></label>
                    <input name="Nom" type="text" tabindex="5" required value="<%: Model.Nom %>"/>
                </li>
                <li class="form-left-column">
                    <label for="Password"><%: Lang.GetString(lang, "Password")%></label>
                    <input name="Password" type="password" tabindex="2" required value="<%: Model.Password %>"/>
                </li>
                <li class="form-right-column">
                    <label for="Cognoms"><%: Lang.GetString(lang, "Cognoms")%></label>
                    <input name="Cognoms" type="text" tabindex="6" required value="<%: Model.Cognoms %>"/>
                </li>
                <li class="form-left-column">
                    <label for="ConfirmarPassword"><%: Lang.GetString(lang, "Confirma_password")%></label>
                    <input name="ConfirmarPassword" type="password" tabindex="3" required value="<%: Model.Password %>" />
                </li>
                <li class="form-right-column">
                    <label for="DataNaixement"><%: Lang.GetString(lang, "Data_naixement")%></label>
                    <input name="DataNaixement" type="date" tabindex="7" required value="<%: Model.DataNaixement.ToString("yyyy-MM-dd") %>"/>
                </li>
                <li class="form-left-column">
                    <label for="Email"><%: Lang.GetString(lang, "Correu_electronic")%></label>
                    <input name="Email" type="email" tabindex="4" required value="<%: Model.Email %>"/>
                </li>
                <li class="form-right-column">
                    <label for="Sexe"><%: Lang.GetString(lang, "Sexe")%></label>
                    <select name="Sexe" tabindex="8">
                        <option value="-" <%: (Model.Sexe == '-') ? "selected" : "" %>><%: Lang.GetString(lang, "No_especificat")%></option>
                        <option value="H" <%: (Model.Sexe == 'H') ? "selected" : "" %>><%: Lang.GetString(lang, "Home")%></option>
                        <option value="D" <%: (Model.Sexe == 'D') ? "selected" : "" %>><%: Lang.GetString(lang, "Dona")%></option>
                    </select>
                </li>
            </ol>
            <input name="Id" type="hidden" value="<%: Model.Id %>" />
            <input name="PasswordOld" type="hidden" value="<%: Model.Password %>" />
            <input name="PasswordEnc" type="hidden" value=""/>
            <div style="clear: both; width: 100%; text-align: center;">
                <input style="clear: both;" type="submit" tabindex="9" value="<%: Lang.GetString(lang, "Modificar") %>" />
            </div>
        </fieldset>
     <%     }
        } %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('input[name=Password],input[name=ConfirmarPassword]').focus(function () {
                esborrarPasswordAntic(this);
            });

            $('input[name=Password],input[name=ConfirmarPassword]').focusout(function () {
                restaurarPasswordAntic(this);
            });

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

                if ($('input[name=Password]').val() == $('input[name=PasswordOld]').val() && $('input[name=ConfirmarPassword]').val() == $('input[name=PasswordOld]').val()) {
                    $('input[name=PasswordEnc]').val('');
                    $('input[name=Password]').val('');
                    $('input[name=ConfirmarPassword]').val('');
                } else {
                    var passenc = CryptoJS.SHA3(pass1);
                    $('input[name=PasswordEnc]').val(passenc);
                    $('input[name=Password]').val('');
                    $('input[name=ConfirmarPassword]').val('');
                }
                return true;
            });
        });

        function esborrarPasswordAntic(domElem) {
            if ($(domElem).val() == $('input[name=PasswordOld]').val()) {
                $(domElem).val('');
            }
        }

        function restaurarPasswordAntic(domElem) {
            if ($(domElem).val() == '') {
                $(domElem).val($('input[name=PasswordOld]').val());
            }
        }
    </script>
</asp:Content>
