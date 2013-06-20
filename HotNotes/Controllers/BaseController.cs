using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace HotNotes.Controllers
{
    public class BaseController : Controller
    {
        protected string lang;

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            //Triem l'idioma segons la cookie (si existeix)
            HttpCookie cookie = Request.Cookies["HotNotes_lang"];
            if (cookie != null) //Ja existeix la cookie, obtenim el seu valor
            {
                lang = cookie.Value;
            }
            else //No existeix la cookie. Li posem un valor per defecte i l'assignem
            {
                lang = "es";
                SetLangCookie(filterContext, lang);
            }

            ViewBag.Lang = lang;

            base.OnActionExecuting(filterContext);
        }

        protected void SetLangCookie(ActionExecutingContext filterContext, string lang)
        {
            HttpCookie newCookie = new HttpCookie("HotNotes_lang", lang);
            newCookie.Expires = DateTime.Now.AddYears(5);
            filterContext.HttpContext.Response.SetCookie(newCookie);
        }

    }
}
