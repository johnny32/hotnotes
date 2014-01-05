<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Pujar
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsSection" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Pujar nou document</h2>

    <fieldset class="text-center">
        <legend>Pujar nou document</legend>
        <div class="container" style="width: 100%;">
            <div class="row">
                <div class="col-md-5 text-right">
                    <label for="UserName"><%: Lang.GetString(lang, "Username") %></label>
                </div>
                <div class="col-md-7 text-left">
                    <input name="Username" type="text" required/>
                </div>
            </div>
        </div>
    </fieldset>

</asp:Content>


