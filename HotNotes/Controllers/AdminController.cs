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
            ViewBag.Action = "Moderar";

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT a.Id, a.Nom, a.Curs, a.IdCarrera, c.Nom AS NomCarrera, (SELECT COUNT(Id) FROM Documents WHERE IdAssignatura = a.Id) AS NumDocs FROM Assignatures a, Carreres c WHERE a.IdCarrera = @IdCarrera AND a.IdCarrera = c.Id ORDER BY Curs, Id ASC", connection);
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
                        NumDocs = reader.GetInt32(reader.GetOrdinal("NumDocs")),
                        Carrera = new Carrera()
                        {
                            Id = Id,
                            Nom = reader.GetString(reader.GetOrdinal("NomCarrera"))
                        }
                    };

                    ViewBag.NomCarrera = a.Carrera.Nom;

                    r.Add(a);
                }

                if (string.IsNullOrEmpty(ViewBag.NomCarrera))
                {
                    reader.Close();
                    cmd = new MySqlCommand("SELECT Nom FROM Carreres WHERE Id = @Id", connection);
                    cmd.Parameters.AddWithValue("@Id", Id);
                    reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        ViewBag.NomCarrera = reader.GetString(reader.GetOrdinal("Nom"));
                    }
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
            ViewBag.Action = "Moderar";

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

                if (ViewBag.IdCarrera == -1)
                {
                    reader.Close();
                    cmd = new MySqlCommand("SELECT a.Nom AS NomAssignatura, c.Id AS IdCarrera, c.Nom AS NomCarrera FROM Assignatures a, Carreres c WHERE a.IdCarrera = c.Id AND a.Id = @IdAssignatura", connection);
                    cmd.Parameters.AddWithValue("@IdAssignatura", Id);
                    reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        ViewBag.IdCarrera = reader.GetInt32(reader.GetOrdinal("IdCarrera"));
                        ViewBag.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));
                        ViewBag.NomAssignatura = reader.GetString(reader.GetOrdinal("NomAssignatura"));
                    }
                }

                return View(r);
            }
        }

        [Authorize]
        [HttpGet]
        public ActionResult ModerarDocument(int id, string resultat = "")
        {
            if (!IsAdmin)
            {
                return RedirectToAction("Login");
            }

            Log.Info("Moderar document: " + id);
            ViewBag.Action = "Moderar";

            if (!string.IsNullOrEmpty(resultat))
            {
                ViewBag.Resultat = resultat;
            }

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT d.Nom, d.Idioma, d.Tipus, d.ExamenCorregit, d.DataAfegit, d.DataModificat, d.Versio, d.IdAssignatura, a.Nom AS NomAssignatura, a.IdCarrera, c.Nom AS NomCarrera " +
                                           "FROM Documents d, Assignatures a, Carreres c " +
                                           "WHERE d.Id = @IdDocument AND d.IdAssignatura = a.Id AND a.IdCarrera = c.Id", connection);
                cmd.Parameters.AddWithValue("@IdDocument", id);
                MySqlDataReader reader = cmd.ExecuteReader();
                Document d = new Document();
                if (reader.Read())
                {
                    d.Id = id;
                    d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    d.Idioma = reader.GetString(reader.GetOrdinal("Idioma"));
                    d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));
                    if (reader.IsDBNull(reader.GetOrdinal("ExamenCorregit")))
                    {
                        d.ExamenCorregit = null;
                    }
                    else
                    {
                        d.ExamenCorregit = reader.GetBoolean(reader.GetOrdinal("ExamenCorregit"));   
                    }
                    d.DataAfegit = reader.GetDateTime(reader.GetOrdinal("DataAfegit"));
                    if (reader.IsDBNull(reader.GetOrdinal("DataModificat")))
                    {
                        d.DataModificat = null;
                    }
                    else
                    {
                        d.DataModificat = reader.GetDateTime(reader.GetOrdinal("DataModificat"));
                    }
                    if (reader.IsDBNull(reader.GetOrdinal("Versio")))
                    {
                        d.Versio = null;
                    }
                    else
                    {
                        d.Versio = reader.GetDouble(reader.GetOrdinal("Versio"));
                    }
                    d.Assignatura = new Assignatura
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("IdAssignatura")),
                        Nom = reader.GetString(reader.GetOrdinal("NomAssignatura")),
                        Carrera = new Carrera
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("IdCarrera")),
                            Nom = reader.GetString(reader.GetOrdinal("NomCarrera"))
                        }
                    };

                    reader.Close();

                    cmd = new MySqlCommand("SELECT c.Id, c.Nom FROM Carreres c ORDER BY c.Id ASC", connection);
                    reader = cmd.ExecuteReader();
                    var carreres = new List<Carrera>();

                    while (reader.Read())
                    {
                        carreres.Add(new Carrera
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("Id")),
                            Nom = reader.GetString(reader.GetOrdinal("Nom"))
                        });
                    }

                    ViewBag.Carreres = carreres;

                    reader.Close();

                    cmd = new MySqlCommand("SELECT a.Id, a.Nom, a.Curs FROM Assignatures a WHERE a.IdCarrera = @IdCarrera ORDER BY a.Id ASC", connection);
                    cmd.Parameters.AddWithValue("@IdCarrera", d.Assignatura.Carrera.Id);
                    reader = cmd.ExecuteReader();
                    var assignatures = new List<Assignatura>();

                    while (reader.Read())
                    {
                        assignatures.Add(new Assignatura
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("Id")),
                            Nom = reader.GetString(reader.GetOrdinal("Nom")),
                            Curs = reader.GetInt32(reader.GetOrdinal("Curs"))
                        });
                    }

                    ViewBag.Assignatures = assignatures;
                }
                else
                {
                    Log.Warn("El document " + id + " no existeix");
                    ViewBag.Error = Lang.GetString(base.lang, "Document_no_existeix");
                }

                reader.Close();
                return View(d);
            }
        }

        [Authorize]
        [HttpPost]
        public ActionResult ModerarDocument(int id, string nom, string idioma, string tipus, bool examenCorregit, int assignatura)
        {
            if (!IsAdmin)
            {
                return RedirectToAction("Login");
            }

            Log.Info("Moderar document: " + id);

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("UPDATE Documents SET Nom = @Nom, Idioma = @Idioma, Tipus = @Tipus, ExamenCorregit = @ExamenCorregit, IdAssignatura = @IdAssignatura, DataModificat = NOW(), Versio = Versio + 1 WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Nom", nom);
                cmd.Parameters.AddWithValue("@Idioma", idioma);
                cmd.Parameters.AddWithValue("@Tipus", tipus);
                cmd.Parameters.AddWithValue("@ExamenCorregit", examenCorregit ? 1 : 0);
                cmd.Parameters.AddWithValue("@IdAssignatura", assignatura);
                cmd.ExecuteNonQuery();

                return RedirectToAction("ModerarDocument", "Admin", new { id = id, resultat = Lang.GetString(lang, "Document_modificat") });
            }
        }

        [Authorize]
        public JsonResult LlistaAssignatures(int idCarrera)
        {
            if (!IsAdmin)
            {
                Response.StatusCode = 401;
                return Json("", JsonRequestBehavior.AllowGet);
            }

            Log.Info("Obtenint llistat d'assignatures de la carrera " + idCarrera);

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("SELECT Id, Nom, Curs FROM Assignatures WHERE IdCarrera = @IdCarrera ORDER BY Id ASC", connection);
                cmd.Parameters.AddWithValue("@IdCarrera", idCarrera);
                MySqlDataReader reader = cmd.ExecuteReader();

                var assignatures = new List<Assignatura>();

                while (reader.Read())
                {
                    assignatures.Add(new Assignatura
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("Id")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Curs = reader.GetInt32(reader.GetOrdinal("Curs"))
                    });
                }

                reader.Close();
                return Json(assignatures, JsonRequestBehavior.AllowGet);
            }
        }

        [Authorize]
        [HttpDelete]
        public JsonResult EliminarDocument(int id)
        {
            if (!IsAdmin)
            {
                Response.StatusCode = 401;
                return Json("", JsonRequestBehavior.AllowGet);
            }

            Log.Info("Eliminant document " + id);

            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                var cmd = new MySqlCommand("DELETE FROM Comentaris WHERE IdDocument = @IdDocument", connection);
                cmd.Parameters.AddWithValue("@IdDocument", id);
                cmd.ExecuteNonQuery();

                cmd = new MySqlCommand("DELETE FROM Valoracions WHERE IdDocument = @IdDocument", connection);
                cmd.Parameters.AddWithValue("@IdDocument", id);
                cmd.ExecuteNonQuery();

                cmd = new MySqlCommand("DELETE FROM Documents WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.ExecuteNonQuery();

                return Json("OK");
            }
        }
    }
}
