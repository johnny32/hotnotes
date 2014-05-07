using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

//HotNotes
using HotNotes.Helpers;
using HotNotes.Models;

//MySQL
using MySql.Data.MySqlClient;

namespace HotNotes.Controllers
{
    public class AdminController : BaseController
    {
        //
        // GET: /Admin/

        private bool IsAdmin
        {
            get
            {
                HttpCookie cookie = HttpContext.Request.Cookies.Get("IsAdmin");
                if (cookie != null) return bool.Parse(cookie.Value);
                return false;
            }
        }

        [AllowAnonymous]
        public ActionResult Index()
        {
            if (!IsAdmin)
            {
                return RedirectToAction("Login");
            }

            return View();
        }

        [AllowAnonymous]
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        public ActionResult Login(string Username, string Password, bool RememberMe)
        {
            Log.Info("Login administrador: " + Username);
            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT Password FROM Administradors WHERE Username = @Username", connection);
                cmd.Parameters.AddWithValue("@Username", Username);
                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    if (Password == reader.GetString(reader.GetOrdinal("Password")))
                    {
                        var cookie = new HttpCookie("IsAdmin", "true");
                        HttpContext.Response.Cookies.Add(cookie);
                        FormsAuthentication.SetAuthCookie(Username, RememberMe);
                        Log.Info("Login correcte");
                        return RedirectToAction("Index", "Home");
                    }
                    else
                    {
                        //Password incorrecte
                        Log.Warn("Login incorrecte: Password incorrecte");
                        ViewBag.Error = Lang.GetString(base.lang, "Username_password_incorrecte");
                    }
                }
                else
                {
                    //Usuari incorrecte
                    Log.Warn("Login incorrecte: Username incorrecte");
                    ViewBag.Error = Lang.GetString(base.lang, "Username_password_incorrecte");
                }
            }

            return View();
        }

    }
}
