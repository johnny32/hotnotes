<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Inicia_sessio") %>
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <% if (ViewBag.Error != null)
       { %>
       <div class="alert alert-block alert-danger" style="margin-right: 0.8em;">
           <button type="button" class="close" data-dismiss="alert">&times;</button>
           <h4><%: Lang.GetString(lang, "Error") %></h4>
           <p><%= ViewBag.Error %></p>
       </div>
    <% } %>
    <hgroup class="title">
        <img src="<%: Url.Content("~/Content/images/logo.png") %>" alt="HotNotes" />
        <h2><%: Lang.GetString(lang, "Benvingut") %></h2>
    </hgroup>

    <% using (Html.BeginForm(new { ReturnUrl = ViewBag.ReturnUrl }))
        { %>
    <%: Html.AntiForgeryToken() %>
    <fieldset class="text-center">
        <legend>Log in Form</legend>
        <div class="container" style="width: 100%;">
            <div class="row">
                <div class="col-md-5 text-right">
                    <label for="UserName"><%: Lang.GetString(lang, "Username") %></label>
                </div>
                <div class="col-md-7 text-left">
                    <input name="Username" type="text" required/>
                </div>
            </div>
            <div class="row">
                <div class="col-md-5 text-right">
                    <label for="Password"><%: Lang.GetString(lang, "Password") %></label>
                </div>
                <div class="col-md-7 text-left">
                    <input name="Password" type="password" required/>
                </div>
            </div>
            <div class="row">
                <div class="col-md-5 text-right">
                    <label for="RememberMe"><%: Lang.GetString(lang, "No_tanquis_sessio") %></label>
                </div>
                <div class="col-md-7 text-left">
                    <input name="RememberMeCB" type="checkbox" value="dasdasd"/>
                </div>
            </div>
            <br />
            <div class="row">
                <div class="col-md-6 text-right">
                    <input name="PasswordEnc" type="hidden" />
                </div>
                <div class="col-md-6 text-right">
                    <input name="RememberMe" type="hidden" />
                </div>
            </div>
        </div>
        
        <button type="submit" class="btn btn-default"><%: Lang.GetString(lang, "Inicia_sessio") %></button> <button type="button" class="btn btn-info" onclick="window.location='<%: Url.Action("Register", "Account") %>'"><%: Lang.GetString(lang, "Registrat") %></button>
    </fieldset>
    <br />
    <p>
        
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