//System
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

//HotNotes
using HotNotes.Helpers;

//Json.NET
using Newtonsoft.Json;

namespace HotNotes.Controllers
{
    public class DocumentController : BaseController
    {
        //
        // GET: /Document/

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult TipusDocuments()
        {
            Dictionary<string, string> tipusLinks = new Dictionary<string,string>();
            tipusLinks.Add("Apunts", Lang.GetString(base.lang, "Apunts"));
            tipusLinks.Add("Treball", Lang.GetString(base.lang, "Treballs"));
            tipusLinks.Add("Examen", Lang.GetString(base.lang, "Examens"));
            tipusLinks.Add("Article", Lang.GetString(base.lang, "Articles"));
            tipusLinks.Add("PFC", Lang.GetString(base.lang, "PFC"));
            tipusLinks.Add("Paper", Lang.GetString(base.lang, "Paper"));
            tipusLinks.Add("Practica", Lang.GetString(base.lang, "Practiques"));
            tipusLinks.Add("LinkExtern", Lang.GetString(base.lang, "Links_externs"));
            tipusLinks.Add("LinkYoutube", Lang.GetString(base.lang, "Links_youtube"));

            return new ContentResult { Content = JsonConvert.SerializeObject(tipusLinks), ContentType = "application/json" };
        }

    }
}
