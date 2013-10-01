<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<%
    if (ViewBag.Error == null)
    { 
%>

<h2><%: Model.Nom%></h2>

<%
    if (Model.Tipus == TipusDocument.LinkYoutube || Model.Extensio == "pdf")
    {
        //Embed
    }    
%>

<div id="infoLeft" style="float: left;">
    <a href="<%: Model.Ruta %>" target="_blank" style="font-size: medium;"><%: Lang.GetString(ViewBag.Lang, "Descarregar_document") %></a><br />
    <span style="font-size: small;"><%: Lang.GetString(ViewBag.Lang, "Autor") %>: <a href="<%: Model.LinkPerfilAutor %>"><%: Model.NomAutor %></a></span>
</div>

<div id="infoRight" style="float: right; font-style: italic; text-align: right;">
    <%: Lang.GetString(ViewBag.Lang, "Tipus") %>: <%: Lang.GetString(ViewBag.Lang, Model.Tipus.ToString()) %><br />
    <%: Lang.GetString(ViewBag.Lang, "Data_creacio") %>: <%: Model.DataAfegit.ToShortDateString() %><br />
    <%
        if (Model.DataModificat.HasValue)
        { %>
    <%: Lang.GetString(ViewBag.Lang, "Data_modificat") %>: <%: Model.DataModificat.Value.ToShortDateString() %><br />
    <%
        }

        if (Model.Versio.HasValue)
        { %>
    <%: Lang.GetString(ViewBag.Lang, "Versio") %>: <%: Model.Versio.Value %><br />
    <%
        }
    %>
</div>

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
