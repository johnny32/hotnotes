<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.LoginModel>" %>

<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>
<!DOCTYPE html>
<html lang="<%: lang %>">
  <head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title>Login | HotNotes</title>
    <link href="<%: Url.Content("~/favicon.ico") %>" rel="shortcut icon" type="image/x-icon" />
    <meta name="viewport" content="width=device-width" />
    <%: Styles.Render("~/Content/css") %>
    <%: Styles.Render("~/Content/bootstrap/css/bootstrap.min.css") %>
    <%: Scripts.Render("~/Scripts/jquery-1.7.1.min.js") %>
    <%: Scripts.Render("~/bundles/modernizr") %>
    <%: Scripts.Render("~/Content/bootstrap/js/bootstrap.min.js") %>
    <%: Scripts.Render("~/Scripts/sha3.js") %>
    <style>
      .login-box
      {
        width: 20%;
        padding: 2em 2em 1em 1.25em;
        text-align: center;
        background-color: #CCC;
        margin-top: 3em;
        margin-left: auto;
        margin-right: auto;
        border: 2px solid #555;
        border-radius: 30px;
      }
    </style>
    <script>
        $(document).ready(function () {
            $('form').submit(function () {
                var encpassword = CryptoJS.SHA3($('#Password').val());
                $('#Password').val(encpassword.toString());
            });
        });
    </script>
  </head>
  <body>
    <div id="body">
      <div id="content">
        <hgroup class="title" style="text-align: center;">
            <h1>HotNotes</h1>
        </hgroup>
        <div class="container-fluid login-box">
          <% using (Html.BeginForm(new { ReturnUrl = ViewBag.ReturnUrl }))
              { %>
              <%: Html.AntiForgeryToken() %>
              <%: Html.ValidationSummary(true) %>

              <fieldset>
                  <legend>Log in Form</legend>
                  <ol>
                      <li>
                          <label for="UserName"><%: Lang.GetString(lang, "Username") %></label>
                          <%: Html.TextBoxFor(m => m.UserName) %>
                          <%: Html.ValidationMessageFor(m => m.UserName) %>
                      </li>
                      <li>
                          <label for="UserName"><%: Lang.GetString(lang, "Password") %></label>
                          <%: Html.PasswordFor(m => m.Password) %>
                          <%: Html.ValidationMessageFor(m => m.Password) %>
                      </li>
                      <li>
                          <%: Html.CheckBoxFor(m => m.RememberMe) %>
                          <%: Html.LabelFor(m => m.RememberMe, new { @class = "checkbox" }) %>
                      </li>
                  </ol>
                  <input type="submit" value="<%: Lang.GetString(lang, "Inicia_sessio") %>" />
              </fieldset>
              <br />
              <p>
                  <%: Html.ActionLink(Lang.GetString(lang, "Registrat"), "Register") %>
              </p>
          <% } %>
        </div>    
      </div>
    </div>
    <footer>
      <div class="content-wrapper">
          <div style="text-align: center; color: #505050;">
              <p>&copy; <%: DateTime.Now.Year %> - Jonathan Clara Márquez - &copy; <%: Lang.GetString(lang, "Drets_reservats") %>.</p>
          </div>
      </div>
    </footer>
    <%: Scripts.Render("~/bundles/jquery") %>
    <%: Scripts.Render("~/bundles/jqueryval") %>
  </body>
</html>
