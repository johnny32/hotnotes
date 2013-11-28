﻿<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
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
        <h1>"IMATGE BENVINGUT"</h1>
        <h2><%: Lang.GetString(lang, "Inicia_sessio") %></h2>
    </hgroup>

    <% using (Html.BeginForm(new { ReturnUrl = ViewBag.ReturnUrl }))
        { %>
    <%: Html.AntiForgeryToken() %>
    <fieldset class="text-center">
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