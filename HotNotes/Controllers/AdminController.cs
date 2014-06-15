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
                Log.Info("Intent d'acces a pagina principal d'Admin sense estar loggejat. Redirigint a Login...");
                return RedirectToAction("Login");
            }

            Log.Info("Pagina principal d'Admin (Moderar documents)");
            ViewBag.Action = "Moderar";

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT Id, Nom FROM Carreres ORDER BY Id ASC", connection);
                MySqlDataReader reader = cmd.ExecuteReader();

                var r = new List<Carrera>();

                while (reader.Read())
                {
                    var c = new Carrera()
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("Id")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom"))
                    };

                    r.Add(c);
                }

                return View(r);
            }
        }

        [AllowAnonymous]
        public ActionResult Login()
        {
            HttpContext.Request.Cookies.Remove("UserID");
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        public ActionResult Login(string Username, string PasswordEnc, bool RememberMe)
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
                    if (PasswordEnc == reader.GetString(reader.GetOrdinal("Password")))
                    {
                        var cookie = new HttpCookie("IsAdmin", "true");
                        HttpContext.Response.Cookies.Add(cookie);
                        FormsAuthentication.SetAuthCookie(Username, RememberMe);
                        Log.Info("Login correcte");
                        return RedirectToAction("Index", "Admin");
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

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public ActionResult Logout()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Login", "Admin");
        }

        [Authorize]
        public ActionResult ModerarDocumentsCarrera(int Id)
        {
            if (!IsAdmin)
            {
                return RedirectToAction("Login");
            }

            Log.Info("Moderar documents de carrera amb id: " + Id);

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT a.Id, a.Nom, a.Curs, a.IdCarrera, c.Nom AS NomCarrera FROM Assignatures a, Carreres c WHERE a.IdCarrera = @IdCarrera AND a.IdCarrera = c.Id ORDER BY Curs, Id ASC", connection);
                cmd.Parameters.AddWithValue("@IdCarrera", Id);
                MySqlDataReader reader = cmd.ExecuteReader();

                ViewBag.NomCarrera = "";

                var r = new List<Assignatura>();
                while (reader.Read())
                {
                    var a = new Assignatura()
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("Id")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Curs = reader.GetInt32(reader.GetOrdinal("Curs")),
                        Carrera = new Carrera()
                        {
                            Id = Id,
                            Nom = reader.GetString(reader.GetOrdinal("NomCarrera"))
                        }
                    };

                    ViewBag.NomCarrera = a.Carrera.Nom;

                    r.Add(a);
                }

                return View(r);
            }
        }

        [Authorize]
        public ActionResult ModerarDocumentsAssignatura(int Id)
        {
            if (!IsAdmin)
            {
                return RedirectToAction("Login");
            }

            Log.Info("Moderar documents de carrera amb id: " + Id);

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT d.Id, d.Nom, d.IdAssignatura, a.Nom AS NomAssignatura, " +
                                            "IF(EXISTS(SELECT v.IdDocument FROM Valoracions v WHERE v.IdDocument = d.Id), (SELECT AVG(v.Valoracio) FROM Valoracions v WHERE v.IdDocument = d.Id), 0) AS Valoracio, " +
                                            "a.IdCarrera, c.Nom AS NomCarrera FROM Documents d, Assignatures a, Carreres c WHERE d.IdAssignatura = @IdAssignatura AND d.IdAssignatura = a.Id AND a.IdCarrera = c.Id ORDER BY Valoracio, d.Id ASC", connection);
                cmd.Parameters.AddWithValue("@IdAssignatura", Id);
                MySqlDataReader reader = cmd.ExecuteReader();

                ViewBag.IdCarrera = -1;
                ViewBag.NomCarrera = "";
                ViewBag.NomAssignatura = "";

                var r = new List<DocumentLlistat>();
                while (reader.Read())
                {
                    var d = new DocumentLlistat()
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("Id")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Valoracio = reader.IsDBNull(reader.GetOrdinal("Valoracio")) ? 0.0 : reader.GetDouble(reader.GetOrdinal("Valoracio")),
                        IdAssignatura = Id,
                        NomAssignatura = reader.GetString(reader.GetOrdinal("NomAssignatura"))
                    };

                    ViewBag.IdCarrera = reader.GetInt32(reader.GetOrdinal("IdCarrera"));
                    ViewBag.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));
                    ViewBag.NomAssignatura = d.NomAssignatura;

                    r.Add(d);
                }

                return View(r);
            }
        }
    }
}
