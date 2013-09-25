<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<%
    if (ViewBag.Error == null)
    { 
%>

<h2><%: Model.Nom%></h2>

<fieldset>
    <legend>Document</legend>
</fieldset>
<p>
    <%: Html.ActionLink("Edit", "Edit", new { /* id=Model.PrimaryKey */ })%> |
    <%: Html.ActionLink("Back to List", "Index")%>
</p>

<%  }
    else
    {
%>
    <div id="errors" class="alert alert-block alert-danger">
        <h4><%: Lang.GetString(ViewBag.Lang, "Error") %></h4>
        <p><%= ViewBag.Error %></p>
    </div>  
<%  }
%>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>
