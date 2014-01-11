<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<List<HotNotes.Models.Assignatura>>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<%@ Import Namespace="HotNotes.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <%: Lang.GetString(lang, "Pujar_Document") %>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <% string lang = ViewBag.Lang; %>
    <h2><%: Lang.GetString(lang, "Pujar_document") %></h2>

    <fieldset class="text-center">
        <legend>Pujar nou document</legend>
        <div class="container" style="width: 100%;">
            <div class="row">
                <div class="col-md-5 text-right">
                    <label for="Nom"><%: Lang.GetString(lang, "Nom") %></label>
                </div>
                <div class="col-md-7 text-left">
                    <input name="Username" type="text" required/>
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
                        foreach (TipusDocument td in Document.TipusDocuments)
                        {
                        %>
                        <option value="<%: td.ToString() %>"><%: Lang.GetString(lang, td.ToString()) %></option>
                        <%
                        }
                    %>
                    </select>
                </div>
            </div>
        </div>
    </fieldset>

</asp:Content>


