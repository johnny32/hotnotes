<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/SiteAdmin.Master" Inherits="System.Web.Mvc.ViewPage<HotNotes.Models.Document>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Moderar_document") %>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>

    <ol class="breadcrumb">
        <li><a href="<%: Url.Action("Index", "Admin") %>"><%: Lang.GetString(lang, "Moderar_documents") %></a></li>
        <li><a href="<%: Url.Action("ModerarDocumentsCarrera", "Admin", new { Id = Model.Assignatura.Carrera.Id }) %>"><%: Model.Assignatura.Carrera.Nom %></a></li>
        <li><a href="<%: Url.Action("ModerarDocumentsAssignatura", "Admin", new { Id = Model.Assignatura.Id }) %>"><%: Model.Assignatura.Nom %></a></li>
        <li class="active"><%: Model.Nom %></li>
    </ol>

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
                <input type="text" id="id" name="id" class="form-control" value="<%: Model.Id %>" disabled>
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
                <input type="checkbox" id="examenCorregit" name="examenCorregitChk" <%: Model.ExamenCorregit.HasValue && Model.ExamenCorregit.Value ? "checked" : "" %> onchange="$('input[name=examenCorregit]').val(this.checked ? 'True' : 'False');">
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
                <select id="carrera" name="carrera" class="form-control" onchange="carregarAssignatures();">
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
        <input type="hidden" name="examenCorregit" value="<%: Model.ExamenCorregit.HasValue && Model.ExamenCorregit.Value %>">
        <br>
        <button type="submit" class="btn btn-primary"><%: Lang.GetString(lang, "Desar") %></button>
        <button type="button" class="btn btn-danger" onclick="modalEliminar();"><%: Lang.GetString(lang, "Eliminar") %></button>
    </form>

    <div id="modalConfirmarEliminar" class="modal fade"tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only"><%: Lang.GetString(lang, "Tancar") %></span></button>
                    <h4 class="modal-title" id="myModalLabel"><%: Lang.GetString(lang, "Eliminar_document") %>: <%: Model.Nom %></h4>
                </div>
                <div class="modal-body">
                    <%: Lang.GetString(lang, "Confirmar_eliminar_document") %>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal"><%: Lang.GetString(lang, "Tancar") %></button>
                    <button type="button" class="btn btn-danger" onclick="eliminarDocument();"><%: Lang.GetString(lang, "Eliminar") %></button>
                </div>
            </div>
        </div>
    </div>

    <%  }
        else
        { %>
    <div class="alert alert-danger"><%: ViewBag.Error %></div>
    <%  } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsSection" runat="server">
    <% string lang = ViewBag.Lang; %>
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

        function carregarAssignatures() {
            var params = {
                idCarrera: $('#carrera option:selected').val()
            };

            $.ajax({
                url: '<%: Url.Action("LlistaAssignatures", "Admin") %>',
                type: 'get',
                data: params,
                dataType: 'json',
                success: function (data) {
                    var html = '';
                    $.each(data, function (i, assignatura) {
                        html += '<option value="' + assignatura.Id + '">' + assignatura.Nom + ' (' + assignatura.Curs + ')</option>';
                    });
                    $('#assignatura').html(html);
                },
                error: function (xhr, ajaxStatus, thrownError) {
                    if (xhr.status == 401) {
                        location.href = '<%: Url.Action("Login", "Admin") %>';
                    } else {
                        alert(thrownError);
                    }
                }
            });
        }

        function modalEliminar() {
            $('#modalConfirmarEliminar').modal('show');
        }

        function eliminarDocument() {
            var params = {
                id: <%: Model.Id %>
            };

            $.ajax({
                url: '<%: Url.Action("EliminarDocument", "Admin") %>',
                type: 'delete',
                data: params,
                dataType: 'json',
                success: function (data) {
                    if (data == 'OK') {
                        $('#modalConfirmarEliminar .modal-body').html('<%: Lang.GetString(lang, "Document_eliminat") %>');
                        $('#modalConfirmarEliminar .modal-footer .btn-danger').hide();
                        $('#modalConfirmarEliminar').on('hide.bs.modal', function (evt) {
                            location.href = '<%: Url.Action("ModerarDocumentsAssignatura", "Admin", new { Id = Model.Assignatura.Id }) %>';
                        });
                    } else {
                        alert(data);
                    }
                },
                error: function (xhr, ajaxStatus, thrownError) {
                    if (xhr.status == 401) {
                        location.href = '<%: Url.Action("Login", "Admin") %>';
                    } else {
                        alert(thrownError);
                    }
                }
            });
        }
    </script>
</asp:Content>
