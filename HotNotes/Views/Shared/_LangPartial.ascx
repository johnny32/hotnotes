<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<dynamic>" %>
<%@ Import Namespace="HotNotes.Helpers" %>
<% string lang = ViewBag.Lang; %>

<div id="menuLang" class="btn-group">
<%  if (lang == "es")
    { %>
    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
        <img src="<%: Url.Content("~/Content/images/es-flag.png") %>" style="width: 16px;" />&nbsp;&nbsp;<%: Lang.GetString(lang, "Castella") %>
        <span class="caret"></span>
    </button>
    <ul class="dropdown-menu" role="menu">
        <li><a href="<%: Url.Action("CanviarIdioma", "Home", new { codiIdioma = "ca" }) %>"><img src="<%: Url.Content("~/Content/images/ca-flag.png") %>" style="width: 16px;" />&nbsp;&nbsp;<%: Lang.GetString(lang, "Catala") %></a></li>
    </ul>
<%  }
    else
    { %>
    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
        <img src="<%: Url.Content("~/Content/images/ca-flag.png") %>" style="width: 16px;" />&nbsp;&nbsp;<%: Lang.GetString(lang, "Catala") %>
        <span class="caret"></span>
    </button>
    <ul class="dropdown-menu" role="menu">
        <li><a href="<%: Url.Action("CanviarIdioma", "Home", new { codiIdioma = "es" }) %>"><img src="<%: Url.Content("~/Content/images/es-flag.png") %>" style="width: 16px;" />&nbsp;&nbsp;<%: Lang.GetString(lang, "Castella") %></a></li>
    </ul>
<%  } %>
</div>