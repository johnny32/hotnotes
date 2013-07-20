using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace HotNotes.Controllers
{
    public class HomeController : BaseController
    {
        [Authorize]
        public ActionResult Index()
        {
            ViewBag.Message = "Modify this template to jump-start your ASP.NET MVC application.";
            ViewBag.nSharedDocs = "26379";

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

        public RedirectToRouteResult CanviarIdioma(string codiIdioma)
        {
            HttpCookie newCookie = new HttpCookie("HotNotes_lang", codiIdioma);
            newCookie.Expires = DateTime.Now.AddYears(5);
            HttpContext.Response.SetCookie(newCookie);
            return RedirectToAction("Index");
        }
    }
}
