<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<HotNotes.Models.Usuari, System.Collections.Generic.List<HotNotes.Models.Matricula>>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Modificar_dades") %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/Plugins/sha3.js") %>

    <% string lang = ViewBag.Lang; %>

    <script type="text/javascript">
        var passwords_no_coincideixen = '<%: Lang.GetString(lang, "Passwords_no_coincideixen") %>';
        var password_curta = '<%: Lang.GetString(lang, "Password_curta") %>';

        var passwordOld = '<%: ViewBag.Password %>';

        $(document).ready(function () {
            $('input[name=Password], input[name=ConfirmarPassword]').focus(function () {
                esborrarPasswordAntic(this);
            });

            $('input[name=Password], input[name=ConfirmarPassword]').focusout(function () {
                restaurarPasswordAntic(this);
            });

            $('form').submit(function () {
                var pass1 = $('input[name=Password]').val();
                var pass2 = $('input[name=ConfirmarPassword]').val();

                var errormsg = '';

                if (pass1 != pass2 && pass1 != passwordOld && pass2 != '') {
                    errormsg = passwords_no_coincideixen;
                } else if ((pass1.length < 6 || pass2.length < 6) && pass1 != passwordOld && pass2 != '') {
                    errormsg = password_curta;
                }

                if (errormsg != '') {
                    $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button>'
                      + '<h4>Error</h4>'
                      + '<p>' + errormsg + '</p>');
                    $('#errors').removeClass('hide');
                    return false;
                }

                if (pass1 != passwordOld && pass2 != '') {
                    var passenc = CryptoJS.SHA3(pass1);
                    $('input[name=PasswordEnc]').val(passenc);
                    $('input[name=Password]').val('');
                    $('input[name=ConfirmarPassword]').val('');
                }

                return true;
            });

        });

        function esborrarPasswordAntic(domElem) {
            if ($(domElem).val() == passwordOld) {
                $(domElem).val('');
            }
        }

        function restaurarPasswordAntic(domElem) {
            if ($(domElem).val() == '') {
                $(domElem).val(passwordOld);
            }
        }
    </script>
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Modificar_dades") %></h1>
    </hgroup>

     <% if (!string.IsNullOrEmpty(ViewBag.Message))
        { %>
        <div id="Div2" class="alert alert-block alert-info">       
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <p><%= Lang.GetString(lang, ViewBag.Message) %></p>
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

    <form action="<%: Url.Action("Configuracio", "Admin") %>" method="post" class="form-horizontal" role="form">
        <div class="form-group">
            <label class="control-label col-md-4" for="Username"><%: Lang.GetString(lang, "Username") %></label>
            <div class="col-md-8">
                <input name="Username" type="text" tabindex="1" class="form-control" disabled value="<%: ViewBag.Username %>"/>
            </div>
        </div>
        <div class="form-group">
            <label class="control-label col-md-4" for="Password"><%: Lang.GetString(lang, "Password") %></label>
            <div class="col-md-8">
                <input name="Password" type="password" tabindex="1" class="form-control" value="<%: ViewBag.Password %>"/>
            </div>
        </div>
        <div class="form-group">
            <label class="control-label col-md-4" for="ConfirmarPassword"><%: Lang.GetString(lang, "Confirma_password") %></label>
            <div class="col-md-8">
                <input name="ConfirmarPassword" type="password" tabindex="1" class="form-control" value="<%: ViewBag.Password %>"/>
            </div>
        </div>
        <input name="PasswordEnc" type="hidden" value="">
        <input name="Id" type="hidden" value="<%: ViewBag.Id %>">
        <div class="text-center" style="margin: 2em;">
            <button type="submit" tabindex="9" class="btn btn-primary"><%: Lang.GetString(lang, "Modificar") %></button>
        </div>
    </form>

    <%
        } %>
</asp:Content>