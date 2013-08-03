<%@ Page Language="C#" MasterPageFile="~/Views/Shared/SiteNotLogged.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Register
</asp:Content>

<asp:Content ID="registerContent" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <hgroup class="title">
        <h1><%: Lang.GetString(lang, "Registrat") %></h1>
    </hgroup>

    <div>
        <%: Lang.GetString(lang, "Registre_completat") %>
    </div>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>
