﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Configuration;
using log4net;
using Amazon;

namespace HotNotes.Controllers
{
    public class BaseController : Controller
    {
        protected string lang { get; private set; }

        protected ILog Log
        {
            get
            {
                return LogManager.GetLogger("HotNotes");
            }
        }

        protected RegionEndpoint AmazonEndPoint
        {
            get
            {
                return RegionEndpoint.EUWest1;
            }
        }

        protected string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["HotNotes"].ConnectionString;
            }
        }

        protected int IdUsuari
        {
            get
            {
                HttpCookie cookie = HttpContext.Request.Cookies.Get("UserID");
                if (cookie != null) return int.Parse(cookie.Value);
                return -1;
            }
        }

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
            var newCookie = new HttpCookie("HotNotes_lang", lang)
            {
                Expires = DateTime.Now.AddYears(5)
            };

            filterContext.HttpContext.Response.SetCookie(newCookie);
        }

    }
}
