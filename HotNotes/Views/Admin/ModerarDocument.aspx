<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Moderar_document") %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <h2><%: Lang.GetString(lang, "Moderar_document") %></h2>

    <%
        if (ViewBag.Error == null)
        { 
            if (ViewBag.Resultat != null) 
            { %>
    <div class="alert alert-info"><%: ViewBag.Resultat %></div>
        <%  } %>

    <form action="<%: Url.Action("ModerarDocument", "Admin") %>" class="form-horizontal" role="form" method="post">
        <div class="form-group">
            <label for="id" class="col-md-2 control-label">Id</label>
            <div class="col-md-6">
                <input type="text" id="id" class="form-control" value="<%: Model.Id %>" disabled>
            </div>
        </div>
        <div class="form-group">
            <label for="nom" class="col-md-2 control-label"><%: Lang.GetString(lang, "Nom") %></label>
            <div class="col-md-6">
                <input type="text" id="nom" name="nom" class="form-control" value="<%: Model.Nom %>">
            </div>
        </div>
        <div class="form-group">
            <label for="idioma" class="col-md-2 control-label"><%: Lang.GetString(lang, "Idioma") %></label>
            <div class="col-md-6">
                <select id="idioma" name="idioma" class="form-control">
                    <option value="ca" <%: Model.Idioma == "ca" ? "selected" : "" %>><%: Lang.GetString(lang, "Catala") %></option>
                    <option value="es" <%: Model.Idioma == "es" ? "selected" : "" %>><%: Lang.GetString(lang, "Castella") %></option>
                    <option value="en" <%: Model.Idioma == "en" ? "selected" : "" %>><%: Lang.GetString(lang, "Angles") %></option>
                    <option value="-" <%: Model.Idioma == "-" ? "selected" : "" %>><%: Lang.GetString(lang, "Altres") %></option>
                </select>
            </div>
        </div>
        <div class="form-group">
            <label for="tipus" class="col-md-2 control-label"><%: Lang.GetString(lang, "Tipus") %></label>
            <div class="col-md-6">
                <select id="tipus" name="tipus" class="form-control">
                <%
                    foreach (TipusDocument td in Document.TipusDocuments)
                    { %>
                    <option value="<%: td.ToString() %>" <%: td == Model.Tipus ? "selected" : "" %>><%: Lang.GetString(lang, td.ToString()) %></option>
                <%  } %>
                </select>
            </div>
        </div>
        <div id="examenCorregitRow" class="form-group" <%= !Model.ExamenCorregit.HasValue || Model.Tipus != TipusDocument.Examen ? "style=\"display: none;\"" : "" %>>
            <label for="examenCorregit" class="col-md-2 control-label"><%: Lang.GetString(lang, "Es_examen_corregit") %></label>
            <div class="col-md-6">
                <input type="checkbox" id="examenCorregit" name="examenCorregit" <%: Model.ExamenCorregit.HasValue && Model.ExamenCorregit.Value ? "checked" : "" %>>
            </div>
        </div>
        <div class="form-group">
            <label for="dataAfegit" class="col-md-2 control-label"><%: Lang.GetString(lang, "Data_creacio") %></label>
            <div class="col-md-6">
                <input type="text" id="dataAfegit" class="form-control" value="<%: Model.DataAfegit.ToShortDateString() + " " + Model.DataAfegit.ToShortTimeString() %>" disabled>
            </div>
        </div>
        <div class="form-group">
            <label for="dataModificat" class="col-md-2 control-label"><%: Lang.GetString(lang, "Data_modificat") %></label>
            <div class="col-md-6">
                <input type="text" id="dataModificat" class="form-control" value="<%: Model.DataModificat.HasValue ? Model.DataModificat.Value.ToShortDateString() + " " + Model.DataModificat.Value.ToShortTimeString() : "" %>" disabled>
            </div>
        </div>
        <div class="form-group">
            <label for="versio" class="col-md-2 control-label"><%: Lang.GetString(lang, "Versio") %></label>
            <div class="col-md-6">
                <input type="text" id="versio" class="form-control" value="<%: Model.Versio.HasValue ? Model.Versio.Value.ToString() : "" %>" disabled>
            </div>
        </div>
        <div class="form-group">
            <label for="carrera" class="col-md-2 control-label"><%: Lang.GetString(lang, "Carrera") %></label>
            <div class="col-md-6">
                <select id="carrera" name="carrera" class="form-control">
                <%
                    foreach (Carrera c in ViewBag.Carreres)
                    { %>
                    <option value="<%: c.Id %>" <%: Model.Assignatura.Carrera.Id == c.Id ? "selected" : "" %>><%: c.Nom %></option>
                <%  } %>
                </select>
            </div>
        </div>
        <div class="form-group">
            <label for="assignatura" class="col-md-2 control-label"><%: Lang.GetString(lang, "Assignatura") %></label>
            <div class="col-md-6">
                <select id="assignatura" name="assignatura" class="form-control">
                <%
                    foreach (Assignatura a in ViewBag.Assignatures)
                    { %>
                    <option value="<%: a.Id %>" <%: Model.Assignatura.Id == a.Id ? "selected" : "" %>><%: a.Nom %> (<%: a.Curs %>)</option>
                <%  } %>
                </select>
            </div>
        </div>
    </form>

    <%  }
        else
        { %>
    <div class="alert alert-danger"><%: ViewBag.Error %></div>
    <%  } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <script>
        $(document).ready(function () {
            $('#tipus').change(function () {
                if ($('#tipus option:selected').val() == '<%: TipusDocument.Examen.ToString() %>') {
                    $('#examenCorregitRow').show();
                } else {
                    $('#examenCorregitRow').hide();
                }
            });
        });
    </script>
</asp:Content>
