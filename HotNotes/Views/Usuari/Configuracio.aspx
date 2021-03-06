﻿<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<Tuple<HotNotes.Models.Usuari, System.Collections.Generic.List<HotNotes.Models.Matricula>>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="registerTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Modificar_dades")  %>
</asp:Content>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Styles.Render("~/Plugins/DataTables/css/jquery.dataTables.css") %>
    <%: Styles.Render("~/Plugins/DataTables/css/dataTables.bootstrap.css") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/jquery.dataTables.min.js") %>
    <%: Scripts.Render("~/Plugins/DataTables/js/dataTables.bootstrap.js") %>

    <% string lang = ViewBag.Lang; %>

    <style>
        .container input, .container select
        {
            width: 100%;
            height: 2em;
        }

        .col-md-3
        {
            padding-bottom: 0.25em;
        }

        #modalMatricula > .modal-dialog
        {
            width: 48em;
        }
    </style>

    <script type="text/javascript">
        var username_curt = '<%: Lang.GetString(lang, "Username_curt") %>';
        var passwords_no_coincideixen = '<%: Lang.GetString(lang, "Passwords_no_coincideixen") %>';
        var password_curta = '<%: Lang.GetString(lang, "Password_curta") %>';
        var major_edat = '<%: Lang.GetString(lang, "Major_edat") %>';

        var passwordOld = '<%: Model.Item1.Password %>';

        var tableMatriculesObj;

        $(document).ready(function () {
            $('input[name=Password]').focus(function () {
                esborrarPasswordAntic(this);
            });

            $('input[name=Password]').focusout(function () {
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
                } else if (pass1 != pass2 && pass1 != passwordOld && pass2 != '') {
                    errormsg = passwords_no_coincideixen;
                } else if ((pass1.length < 6 || pass2.length < 6) && pass1 != passwordOld && pass2 != '') {
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

                if (pass1 != passwordOld && pass2 != '') {
                    var passenc = CryptoJS.SHA3(pass1);
                    $('input[name=PasswordEnc]').val(passenc);
                    $('input[name=Password]').val('');
                    $('input[name=ConfirmarPassword]').val('');
                }

                return true;
            });

            tableMatriculesObj = $('#tableMatricules').dataTable({
                sDom: "<'row-fluid'<'col-md-6'f><'col-md-6'<'#btnAfegirMatricula'>>r>t",
                bPaginate: false,
                bStateSave: false,
                bAutoWidth: false,
                bDestroy: true,
                oLanguage: {
                    sLengthMenu: '<%: Lang.GetString(lang, "DT_sLengthMenu") %>',
                    sZeroRecords: '<%: Lang.GetString(lang, "DT_sZeroRecords") %>',
                    sInfo: '<%: Lang.GetString(lang, "DT_sInfo") %>',
                    sInfoEmpty: '<%: Lang.GetString(lang, "DT_sInfoEmpty") %>',
                    sInfoFiltered: '<%: Lang.GetString(lang, "DT_sInfoFiltered") %>',
                    sProcessing: '<%: Lang.GetString(lang, "DT_sProcessing") %>',
                    sEmptyTable: '<%: Lang.GetString(lang, "DT_sEmptyTable") %>',
                    sSearch: '<%: Lang.GetString(lang, "DT_sSearch") %>',
                    oPaginate: {
                        sFirst: '<%: Lang.GetString(lang, "DT_sFirst") %>',
                        sPrevious: '<%: Lang.GetString(lang, "DT_sPrevious") %>',
                        sNext: '<%: Lang.GetString(lang, "DT_sNext") %>',
                        sLast: '<%: Lang.GetString(lang, "DT_sLast") %>'
                    }
                },
                aoColumns: [
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: true },
                    { bSearchable: true, bSortable: false },
                    { bSearchable: true, bSortable: false },
                    { bSearchable: false, bSortable: false }
                ],
                fnInitComplete: function () {
                    this.fnFilter('');
                }
            });

            $('#btnAfegirMatricula').css('float', 'right').html('<button type="button" class="btn btn-primary" onclick="obrirModalAfegirMatricula();"><%: Lang.GetString(lang, "Afegir_matricula") %></button>');
        });

        function obrirModalAfegirMatricula() {
            $('#modalMatriculaContingut').hide();
            $('#modalMatriculaProgressBar').show();
            $('#modalMatricula').modal('show');

            $.ajax({
                url: '<%: Url.Action("LlistatUniversitats", "Usuari") %>',
                type: 'get',
                dataType: 'json',
                async: false,
                success: function (data) {
                    var html = '';
                    $.each(data, function (i, item) {
                        html += '<option value="' + item.Id + '">' + item.Nom + '</option>';
                    });
                    $('#selectUniversitats').html(html);
                    carregarFacultats();
                    $('#modalMatriculaProgressBar').hide();
                    $('#modalMatriculaContingut').show();
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#modalMatricula').html('<div class="alert alert-danger"><%: Lang.GetString(lang, "Error_desconegut") %>: ' + errorThrown + '</div>');
                }
            })
        }

        function carregarFacultats() {
            var params = {
                IdUniversitat: $('#selectUniversitats option:selected').val()
            };

            $.ajax({
                url: '<%: Url.Action("LlistatFacultats", "Usuari") %>',
                type: 'get',
                data: params,
                dataType: 'json',
                async: false,
                success: function (data) {
                    var html = '';
                    $.each(data, function (i, item) {
                        html += '<option value="' + item.Id + '">' + item.Nom + '</option>';
                    });
                    $('#selectFacultats').html(html);
                    carregarCarreres();
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#modalMatricula').html('<div class="alert alert-danger"><%: Lang.GetString(lang, "Error_desconegut") %>: ' + errorThrown + '</div>');
                }
            });
        }

        function carregarCarreres() {
            var params = {
                IdFacultat: $('#selectFacultats option:selected').val()
            };

            $.ajax({
                url: '<%: Url.Action("LlistatCarreres", "Usuari") %>',
                type: 'get',
                data: params,
                dataType: 'json',
                async: false,
                success: function (data) {
                    var html = '';
                    $.each(data, function (i, item) {
                        html += '<option value="' + item.Id + '">' + item.Nom + '</option>';
                    });
                    $('#selectCarreres').html(html);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#modalMatricula').html('<div class="alert alert-danger"><%: Lang.GetString(lang, "Error_desconegut") %>: ' + errorThrown + '</div>');
                }
            });
        }

        function afegirMatricula() {
            var params = {
                IdCarrera: $('#selectCarreres option:selected').val(),
                Curs: $('#selectCurs option:selected').val()
            };

            $.ajax({
                url: '<%: Url.Action("AfegirMatricula", "Usuari") %>',
                type: 'post',
                data: params,
                dataType: 'json',
                success: function (data) {
                    if (data == 'OK') {
                        tableMatriculesObj.fnAddData([
                            $('#selectCarreres option:selected').text(),
                            params.Curs,
                            $('#selectFacultats option:selected').text(),
                            $('#selectUniversitats option:selected').text(),
                            '<button type="button" class="btn btn-danger btn-xs" onclick="eliminarMatricula(this, ' + params.IdCarrera + ', ' + params.Curs + ');"><%: Lang.GetString(lang, "Eliminar") %></button>'
                        ]);
                    } else {
                        $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + data + '</p>');
                        $('#errors').removeClass('hide');
                    }
                    $('#modalMatricula').modal('hide');
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#modalMatricula').html('<div class="alert alert-danger"><%: Lang.GetString(lang, "Error_desconegut") %>: ' + errorThrown + '</div>');
                }
            })
        }

        function eliminarMatricula(domElem, idCarrera, curs) {
            if (confirm('<%= Lang.GetString(lang, "Confirmar_eliminar_matricula") %>')) {
                var params = {
                    IdCarrera: idCarrera,
                    Curs: curs
                };

                $.ajax({
                    url: '<%: Url.Action("EliminarMatricula", "Usuari") %>',
                    type: 'post',
                    data: params,
                    dataType: 'json',
                    success: function (data) {
                        if (data == 'OK') {
                            tableMatriculesObj.fnDeleteRow(tableMatriculesObj.fnGetPosition(domElem.parentElement.parentElement));
                        } else {
                            $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + data + '</p>');
                            $('#errors').removeClass('hide');
                        }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        $('#errors').html('<button type="button" class="close" data-dismiss="alert">&times;</button><p>' + errorThrown + '</p>');
                        $('#errors').removeClass('hide');
                    }
                });
            }
        }

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
            <div class="container" style="width: 100%;">
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Username"><%: Lang.GetString(lang, "Username")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Username" type="text" tabindex="1" disabled value="<%: Model.Item1.Username %>"/>
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Nom"><%: Lang.GetString(lang, "Nom")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Nom" type="text" tabindex="5" required value="<%: Model.Item1.Nom %>"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Password"><%: Lang.GetString(lang, "Password")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Password" type="password" tabindex="2" required value="<%: Model.Item1.Password %>"/>
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Cognoms"><%: Lang.GetString(lang, "Cognoms")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Cognoms" type="text" tabindex="6" required value="<%: Model.Item1.Cognoms %>"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="ConfirmarPassword"><%: Lang.GetString(lang, "Confirma_password")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="ConfirmarPassword" type="password" tabindex="3" value="" />
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="DataNaixement"><%: Lang.GetString(lang, "Data_naixement")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="DataNaixement" type="date" tabindex="7" required value="<%: Model.Item1.DataNaixement.ToString("yyyy-MM-dd") %>"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3 text-left">
                        <label for="Email"><%: Lang.GetString(lang, "Correu_electronic")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <input name="Email" type="email" tabindex="4" required value="<%: Model.Item1.Email %>"/>
                    </div>
                    <div class="col-md-3 text-left">
                        <label for="Sexe"><%: Lang.GetString(lang, "Sexe")%></label>
                    </div>
                    <div class="col-md-3 text-left">
                        <select name="Sexe" tabindex="8">
                            <option value="-" <%: (Model.Item1.Sexe == '-') ? "selected" : "" %>><%: Lang.GetString(lang, "No_especificat")%></option>
                            <option value="H" <%: (Model.Item1.Sexe == 'H') ? "selected" : "" %>><%: Lang.GetString(lang, "Home")%></option>
                            <option value="D" <%: (Model.Item1.Sexe == 'D') ? "selected" : "" %>><%: Lang.GetString(lang, "Dona")%></option>
                        </select>
                    </div>
                </div>
            </div>
            <input name="PasswordEnc" type="hidden" value=""/>
            <div class="text-center" style="margin: 2em;">
                <button type="submit" tabindex="9" class="btn btn-primary" onclick="modificarDades();"><%: Lang.GetString(lang, "Modificar") %></button>
            </div>
        </fieldset>
     <% } %>

    <br />

    <h2><%: Lang.GetString(lang, "Cursos_matriculats") %></h2>
    <table id="tableMatricules" border="0" class="table table-striped table-bordered" style="width: 100%;">
        <thead>
            <tr>
                <th><%: Lang.GetString(lang, "Carrera") %></th>
                <th><%: Lang.GetString(lang, "Curs") %></th>
                <th><%: Lang.GetString(lang, "Facultat") %></th>
                <th><%: Lang.GetString(lang, "Universitat") %></th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <%
            foreach (Matricula m in Model.Item2)
            { %>
            <tr>
                <td><%: m.NomCarrera %></td>
                <td><%: m.Curs %></td>
                <td><%: m.NomFacultat %></td>
                <td><%: m.NomUniversitat %></td>
                <td><button type="button" class="btn btn-danger btn-xs" onclick="eliminarMatricula(this, <%: m.IdCarrera %>, <%: m.Curs %>);"><%: Lang.GetString(lang, "Eliminar") %></button></td>
            </tr>
        <%  } %>
        </tbody>
    </table>

    <div id="modalMatricula" class="modal fade" role="dialog" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title" id="myModalLabel"><%: Lang.GetString(lang, "Afegir_matricula") %></h4>
                </div>
                <div id="modalMatriculaProgressBar" class="modal-body">
                    <div class="progress progress-striped active">
                        <div class="progress-bar"  role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%;">
                            <span class="sr-only"><%: Lang.GetString(lang, "Carregant") %></span>
                        </div>
                    </div>
                </div>
                <div id="modalMatriculaContingut" class="modal-body">
                    <div class="form-group">
                        <label for="selectUniversitats"><%: Lang.GetString(lang, "Tria_universitat") %></label>
                        <select id="selectUniversitats" class="form-control" onchange="carregarFacultats();"></select>
                    </div>
                    <div class="form-group">
                        <label for="selectFacultats"><%: Lang.GetString(lang, "Tria_facultat") %></label>
                        <select id="selectFacultats" class="form-control" onchange="carregarCarreres();"></select>
                    </div>
                    <div class="row">
                        <div class="col-md-9">
                            <div class="form-group">
                                <label for="selectCarreres"><%: Lang.GetString(lang, "Tria_carrera") %></label>
                                <select id="selectCarreres" class="form-control"></select>
                            </div>
                        </div>
                        <div class="col-md-3" style="padding-left: 0;">
                            <div class="form-group">
                                <label for="selectCurs"><%: Lang.GetString(lang, "Curs") %></label>
                                <select id="selectCurs" class="form-control">
                                    <option value="1"><%: Lang.GetString(lang, "Primer") %></option>
                                    <option value="2"><%: Lang.GetString(lang, "Segon") %></option>
                                    <option value="3"><%: Lang.GetString(lang, "Tercer") %></option>
                                    <option value="4"><%: Lang.GetString(lang, "Quart") %></option>
                                    <option value="5"><%: Lang.GetString(lang, "Cinque") %></option>
                                    <option value="0"><%: Lang.GetString(lang, "Sense_especificar") %></option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal"><%: Lang.GetString(lang, "Tancar") %></button>
                    <button type="button" class="btn btn-primary" onclick="afegirMatricula();"><%: Lang.GetString(lang, "Afegir") %></button>
                </div>
            </div>
        </div>
    </div>
    <%
        } %>
</asp:Content>