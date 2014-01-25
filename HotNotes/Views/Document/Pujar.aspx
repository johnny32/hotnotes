<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Assignatura>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Pujar_Document") %>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
    <style>
        .row
        {
            margin-bottom: 10px;
        }
    </style>

    <script>
        $(document).ready(function () {
            $('#rowExamen').hide();

            $('select[name=Tipus]').change(function () {
                var opt = $('select[name=Tipus] option:selected').val();

                if (opt == 'Examen') {
                    $('#rowExamen').show();
                } else {
                    $('#rowExamen').hide();
                }

                if (opt == 'LinkExtern' || opt == 'LinkYoutube') {
                    $('#rowFitxer').hide();
                    $('#rowRuta').show();
                    $('#formPujar').removeAttr('enctype');
                } else {
                    $('#rowRuta').hide();
                    $('#rowFitxer').show();
                    $('#formPujar').attr('enctype', 'multipart/form-data');
                }
            });

            $('#formPujar').submit(function () {
                $('input[name=ExamenCorregit]').val($('input[name=ExamenCorregitCB]').prop('checked'));
            });
        });        
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2><%: Lang.GetString(lang, "Pujar_document") %></h2>

    <% if (ViewBag.Error != null)
       { %>
       <div class="alert alert-block alert-danger" style="margin-right: 0.8em;">
           <button type="button" class="close" data-dismiss="alert">&times;</button>
           <h4><%: Lang.GetString(lang, "Error") %></h4>
           <p><%= ViewBag.Error %></p>
       </div>
    <% } %>

    <form id="formPujar" action="<%: Url.Action("Pujar", "Document") %>" method="post" enctype="multipart/form-data">
        <fieldset class="text-center">
            <legend>Pujar nou document</legend>
            <div class="container" style="width: 100%;">
                <div class="row">
                    <div class="col-md-5 text-right">
                        <label for="Nom"><%: Lang.GetString(lang, "Nom") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <input name="Nom" type="text" style="width: 100%;" required/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-5 text-right">
                        <label for="IdAssignatura"><%: Lang.GetString(lang, "Assignatura") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <select name="IdAssignatura" class="form-control">
                        <%
                            for (int i = 0; i < Model.Count; i++)
                            {
                                Assignatura a = Model[i];

                                if (i == 0)
                                { %>
                            <optgroup label="<%: a.NomCarrera %>">
                                <%
                                }
                                else if (a.NomCarrera != Model[i - 1].NomCarrera)
                                { %>
                            </optgroup>
                            <optgroup label="<%: a.NomCarrera %>">
                                <%
                                }
                            %>
                            <option value="<%: a.Id %>"><%: a.Nom %> (<%: a.Curs %>)</option>
                            <%
                            }
                        %>
                            </optgroup>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-5 text-right">
                        <label for="Idioma"><%: Lang.GetString(lang, "Idioma") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <select name="Idioma" class="form-control">
                            <option value="es" <%: lang == "es" ? "selected" : "" %>><%: Lang.GetString(lang, "Castella") %></option>
                            <option value="ca" <%: lang == "ca" ? "selected" : "" %>><%: Lang.GetString(lang, "Catala") %></option>
                            <option value="en"><%: Lang.GetString(lang, "Angles") %></option>
                            <option value="-"><%: Lang.GetString(lang, "Altres") %></option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-5 text-right">
                        <label for="Tipus"><%: Lang.GetString(lang, "Tipus") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <select name="Tipus" class="form-control">
                        <%
                            string selected = "selected";
                            foreach (TipusDocument td in Document.TipusDocuments)
                            {
                            %>
                            <option value="<%: td.ToString() %>" <%: selected %>><%: Lang.GetString(lang, td.ToString()) %></option>
                            <%
                                selected = "";
                            }
                        %>
                        </select>
                    </div>
                </div>
                <div class="row" id="rowExamen">
                    <div class="col-md-5 text-right">
                        <label for="ExamenCorregitCB"><%: Lang.GetString(lang, "Es_examen_corregit") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <input name="ExamenCorregitCB" type="checkbox" />
                        <input name="ExamenCorregit" type="hidden" />
                    </div>
                </div>
                <div class="row" id="rowFitxer">
                    <div class="col-md-5 text-right">
                        <label for="Fitxer"><%: Lang.GetString(lang, "Fitxer") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <input name="Fitxer" type="file" />
                    </div>
                </div>
                <div class="row" id="rowRuta" style="display: none;">
                    <div class="col-md-5 text-right">
                        <label for="Ruta"><%: Lang.GetString(lang, "Ruta") %></label>
                    </div>
                    <div class="col-md-7 text-left">
                        <input name="Ruta" type="text" style="width: 100%;" />
                    </div>
                </div>
                <br />
                <div class="row">
                    <div class="col-md-6 text-right">
                        <button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-upload"></span> <%: Lang.GetString(lang, "Pujar") %></button>
                    </div>
                    <div class="col-md-6 text-left">
                        <button type="reset" class="btn btn-default"><%: Lang.GetString(lang, "Reset") %></button>
                    </div>
                </div>
            </div>
        </fieldset>
    </form>
</asp:Content>


