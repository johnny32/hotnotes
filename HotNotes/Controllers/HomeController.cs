using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.ModelBinding.Binders;
using System.Web.Mvc;
using MySql.Data.MySqlClient;
using HotNotes.Models;
using HotNotes.Helpers;

namespace HotNotes.Controllers
{
    public class HomeController : BaseController
    {
        [Authorize]
        public ActionResult Index()
        {
            Log.Info("Pagina principal per l'usuari " + IdUsuari);
            return View();
        }

        [Authorize]
        public ActionResult About()
        {
            ViewBag.Message = "Your app description page.";

            return View();
        }

        [Authorize]
        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult CanviarIdioma(string codiIdioma, string returnUrl = "")
        {
            HttpCookie newCookie = new HttpCookie("HotNotes_lang", codiIdioma);
            newCookie.Expires = DateTime.Now.AddYears(5);
            HttpContext.Response.SetCookie(newCookie);
            if (returnUrl != string.Empty)
                return Redirect(returnUrl);
            else
                return RedirectToAction("Index");
        }
    }
}
