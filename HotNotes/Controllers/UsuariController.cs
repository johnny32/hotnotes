//System
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;

//HotNotes
using HotNotes.Helpers;
using HotNotes.Models;

//MySQL
using MySql.Data.MySqlClient;

namespace HotNotes.Controllers
{
    [Authorize]
    public class UsuariController : BaseController
    {
        [Authorize]
        public ActionResult Perfil(int Id)
        {
            //Veure perfil d'un usuari
            Log.Info("Veure perfil de l'usuari " + Id);

            if (Id == base.IdUsuari)
            {
                return RedirectToAction("Configuracio");
            }

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand cmd = new MySqlCommand("SELECT u.Username, u.Nom, u.Cognoms, u.Sexe, COUNT(d.Id) AS NumDocumentsPujats, EXISTS(SELECT * FROM Subscripcions WHERE IdUsuariSubscriu = @IdUsuari AND IdUsuariSubscrit = @IdUsuariSubscrit) AS EmSegueix, EXISTS(SELECT * FROM Subscripcions WHERE IdUsuariSubscriu = @IdUsuariSubscrit AND IdUsuariSubscrit = @IdUsuari) AS ElSegueixo FROM Usuaris u, Documents d WHERE IdUsuari = @IdUsuari AND d.IdUsuari = u.Id", connection);
                cmd.Parameters.AddWithValue("@IdUsuari", Id);
                cmd.Parameters.AddWithValue("@IdUsuariSubscrit", base.IdUsuari);

                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read() && !reader.IsDBNull(reader.GetOrdinal("Username")))
                {
                    Usuari u = new Usuari();
                    u.Id = Id;
                    u.Username = reader.GetString(reader.GetOrdinal("Username"));
                    u.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    u.Cognoms = reader.GetString(reader.GetOrdinal("Cognoms"));
                    if (!reader.IsDBNull(reader.GetOrdinal("Sexe")))
                    {
                        u.Sexe = reader.GetChar(reader.GetOrdinal("Sexe"));
                    }
                    else
                    {
                        u.Sexe = '-';
                    }
                    u.NumDocumentsPujats = reader.GetInt32(reader.GetOrdinal("NumDocumentsPujats"));
                    u.EmSegueix = reader.GetBoolean(reader.GetOrdinal("EmSegueix"));
                    u.ElSegueixo = reader.GetBoolean(reader.GetOrdinal("ElSegueixo"));

                    reader.Close();
                    cmd = new MySqlCommand("SELECT m.IdCarrera, m.Curs, c.Nom AS NomCarrera, f.Nom AS NomFacultat, u.Nom AS NomUniversitat " +
                                            "FROM Matricules m, Carreres c, Facultats f, Universitats u " +
                                            "WHERE m.IdUsuari = @IdUsuari AND m.IdCarrera = c.Id AND c.IdFacultat = f.Id AND f.IdUniversitat = u.Id " +
                                            "ORDER BY c.Nom ASC, m.Curs ASC", connection);
                    cmd.Parameters.AddWithValue("@IdUsuari", Id);
                    reader = cmd.ExecuteReader();

                    List<Matricula> matricules = new List<Matricula>();

                    while (reader.Read())
                    {
                        Matricula m = new Matricula();
                        m.IdUsuari = IdUsuari;
                        m.IdCarrera = reader.GetInt32(reader.GetOrdinal("IdCarrera"));
                        m.Curs = reader.GetInt32(reader.GetOrdinal("Curs"));
                        m.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));
                        m.NomFacultat = reader.GetString(reader.GetOrdinal("NomFacultat"));
                        m.NomUniversitat = reader.GetString(reader.GetOrdinal("NomUniversitat"));

                        matricules.Add(m);
                    }

                    return View(new Tuple<Usuari, List<Matricula>>(u, matricules));
                }
                else
                {
                    Log.Warn("ID d'usuari inexistent: " + Id);
                    ViewBag.Error = Lang.GetString(lang, "Error_id_usuari");
                }

                return View();
            }
        }


        //
        // GET: /Usuari/Login

        [AllowAnonymous]
        public ActionResult Login(string returnUrl)
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        //
        // POST: /Usuari/Login

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string Username, string PasswordEnc, bool RememberMe)
        {
            Log.Info("Login usuari: " + Username);
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand cmd = new MySqlCommand("SELECT Id, Password, Activat FROM Usuaris WHERE Username = @Username", connection);
                cmd.Parameters.AddWithValue("@Username", Username);
                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    if (PasswordEnc == reader.GetString(reader.GetOrdinal("Password")))
                    {
                        if ((bool)reader["Activat"])
                        {
                            string id = reader.GetInt32(reader.GetOrdinal("Id")).ToString();
                            HttpCookie cookie = new HttpCookie("UserID", id);
                            HttpContext.Response.Cookies.Add(cookie);
                            FormsAuthentication.SetAuthCookie(Username, RememberMe);
                            Log.Info("Login correcte");
                            return RedirectToAction("Index", "Home");
                        }
                        else
                        {
                            //Encara no ha activat el compte
                            Log.Warn("Login incorrecte: Compte desactivat");
                            ViewBag.Error = Lang.GetString(base.lang, "Compte_desactivat");
                        }
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

        //
        // POST: /Account/LogOff

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public ActionResult Logout()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Login", "Usuari");
        }

        //
        // GET: /Account/Register

        [AllowAnonymous]
        public ActionResult Register()
        {
            return View();
        }

        //
        // POST: /Account/Register

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public ActionResult Register(string Username, string PasswordEnc, string Email, string Nom, string Cognoms, DateTime DataNaixement, char Sexe)
        {
            Log.Info("Registrar nou usuari: " + Username);
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();

                MySqlTransaction transaction = connection.BeginTransaction();

                MySqlCommand cmd = new MySqlCommand("SELECT Username FROM Usuaris WHERE Username = @Username", connection);
                cmd.Parameters.AddWithValue("@Username", Username);
                cmd.Transaction = transaction;

                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    reader.Close();
                    transaction.Rollback();
                    Log.Warn("Username " + Username + " ja existent");
                    ViewBag.Error = Lang.GetString(base.lang, "Usuari_ja_existent");
                }
                else
                {
                    reader.Close();

                    cmd = new MySqlCommand("SELECT Email FROM Usuaris WHERE Email = @Email", connection);
                    cmd.Parameters.AddWithValue("@Email", Email);
                    cmd.Transaction = transaction;

                    reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        Log.Warn("Email " + Email + " ja existent");
                        ViewBag.Error = Lang.GetString(base.lang, "Email_ja_existent");
                    }
                    else
                    {
                        reader.Close();
                        object SexeSQL = Sexe.ToString();
                        if (Sexe == '-')
                        {
                            SexeSQL = DBNull.Value;
                        }

                        Guid g = Guid.NewGuid();
                        string CodiActivacio = Convert.ToBase64String(g.ToByteArray());
                        CodiActivacio = CodiActivacio.Replace("=", "");
                        CodiActivacio = CodiActivacio.Replace("+", "");
                        CodiActivacio = CodiActivacio.Replace("/", "");

                        cmd = new MySqlCommand("INSERT INTO Usuaris (Username, Password, Email, Nom, Cognoms, DataNaixement, Sexe, Activat, CodiActivacio) VALUES (@Username, @Password, @Email, @Nom, @Cognoms, @DataNaixement, @Sexe, @Activat, @CodiActivacio)", connection);
                        cmd.Parameters.AddWithValue("@Username", Username);
                        cmd.Parameters.AddWithValue("@Password", PasswordEnc);
                        cmd.Parameters.AddWithValue("@Email", Email);
                        cmd.Parameters.AddWithValue("@Nom", Nom);
                        cmd.Parameters.AddWithValue("@Cognoms", Cognoms);
                        cmd.Parameters.AddWithValue("@DataNaixement", DataNaixement);
                        cmd.Parameters.AddWithValue("@Sexe", SexeSQL);
                        cmd.Parameters.AddWithValue("@Activat", false);
                        cmd.Parameters.AddWithValue("@CodiActivacio", CodiActivacio);
                        cmd.Transaction = transaction;

                        try
                        {
                            reader = cmd.ExecuteReader();

                            var urlBuilder = new System.UriBuilder(Request.Url.AbsoluteUri)
                            {
                                Path = Url.Action("Activate", "Usuari", new RouteValueDictionary(new { id = CodiActivacio }))
                            };

                            string url = urlBuilder.ToString();

                            MailMessage msg = new MailMessage();
                            msg.To.Add(Email);
                            msg.Subject = Lang.GetString(lang, "Completa_el_registre");
                            msg.From = new MailAddress("webmasterhotnotes@gmail.com", "HotNotes Admin");
                            msg.Body = Lang.GetString(base.lang, "Email_registre").Replace("[[NOM]]", Nom).Replace("[[LINK]]", url);
                            msg.IsBodyHtml = true;

                            NetworkCredential nwCredential = new NetworkCredential("webmasterhotnotes", "thehotnotespassword");

                            SmtpClient smtp = new SmtpClient("smtp.gmail.com");
                            smtp.UseDefaultCredentials = false;
                            smtp.Credentials = nwCredential;
                            smtp.EnableSsl = true;
                            smtp.Send(msg);

                            reader.Close();
                            transaction.Commit();

                            ViewBag.Accio = Lang.GetString(base.lang, "Registrat");
                            ViewBag.Message = Lang.GetString(base.lang, "Registre_completat");
                            Log.Info("Registre completat");
                            return View("Register_Complete");
                        }
                        catch (SqlException e)
                        {
                            reader.Close();
                            transaction.Rollback();
                            Log.Error("Error al registrar", e);
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        catch (SmtpException e)
                        {
                            reader.Close();
                            transaction.Rollback();
                            Log.Error("Error al enviar email de confirmacio", e);
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                    }
                }
            }

            return View();
        }

        //
        // GET: /Account/Activate
        [AllowAnonymous]
        public ActionResult Activate(string id)
        {
            Log.Info("Activar compte amb codi d'activacio " + id);
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand cmd = new MySqlCommand("SELECT Id FROM Usuaris WHERE CodiActivacio = @CodiActivacio", connection);
                cmd.Parameters.AddWithValue("@CodiActivacio", id);
                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    reader.Close();

                    try
                    {
                        cmd = new MySqlCommand("UPDATE Usuaris SET Activat = @Activat, CodiActivacio = @CodiActivacio WHERE Id = @Id", connection);
                        cmd.Parameters.AddWithValue("@Activat", true);
                        cmd.Parameters.AddWithValue("@CodiActivacio", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Id", Id.ToString());
                        cmd.ExecuteReader();
                        Log.Info("Activacio correcte");
                        ViewBag.Response = Lang.GetString(base.lang, "Activar_correcte");
                    }
                    catch (SqlException e)
                    {
                        Log.Error("Error al activar compte d'usuari", e);
                        ViewBag.Error = Lang.GetString(base.lang, "Error_activar");
                    }
                }
                else
                {
                    Log.Warn("Codi d'activacio inexistent");
                    ViewBag.Error = Lang.GetString(base.lang, "Codi_activar_incorrecte");
                }
            }
            return View();
        }

        //
        // GET: /Account/Manage
        [Authorize]
        public ActionResult Configuracio()
        {
            Log.Info("Carregar configuracio de l'usuari " + IdUsuari);
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand cmd = new MySqlCommand("SELECT Id, Username, Password, Email, Nom, Cognoms, DataNaixement, Sexe, Activat FROM Usuaris WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", IdUsuari);
                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    char sexe;
                    if (reader.IsDBNull(reader.GetOrdinal("Sexe")))
                    {
                        sexe = '-';
                    }
                    else
                    {
                        sexe = reader.GetString(reader.GetOrdinal("Sexe"))[0];
                    }

                    Usuari u = new Usuari()
                    {
                        Id = IdUsuari,
                        Username = reader.GetString(reader.GetOrdinal("Username")),
                        Password = reader.GetString(reader.GetOrdinal("Password")),
                        Email = reader.GetString(reader.GetOrdinal("Email")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Cognoms = reader.GetString(reader.GetOrdinal("Cognoms")),
                        DataNaixement = reader.GetDateTime(reader.GetOrdinal("DataNaixement")),
                        Sexe = sexe,
                        Activat = reader.GetBoolean(reader.GetOrdinal("Activat"))
                    };

                    reader.Close();

                    cmd = new MySqlCommand("SELECT m.IdCarrera, m.Curs, c.Nom AS NomCarrera, f.Nom AS NomFacultat, u.Nom AS NomUniversitat " + 
                                           "FROM Matricules m, Carreres c, Facultats f, Universitats u " + 
                                           "WHERE m.IdUsuari = @IdUsuari AND m.IdCarrera = c.Id AND c.IdFacultat = f.Id AND f.IdUniversitat = u.Id " +
                                           "ORDER BY c.Nom ASC, m.Curs ASC", connection);
                    cmd.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                    reader = cmd.ExecuteReader();

                    List<Matricula> matricules = new List<Matricula>();

                    while (reader.Read())
                    {
                        Matricula m = new Matricula();
                        m.IdUsuari = IdUsuari;
                        m.IdCarrera = reader.GetInt32(reader.GetOrdinal("IdCarrera"));
                        m.Curs = reader.GetInt32(reader.GetOrdinal("Curs"));
                        m.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));
                        m.NomFacultat = reader.GetString(reader.GetOrdinal("NomFacultat"));
                        m.NomUniversitat = reader.GetString(reader.GetOrdinal("NomUniversitat"));

                        matricules.Add(m);
                    }

                    return View(new Tuple<Usuari, List<Matricula>>(u, matricules));
                }
                else
                {
                    Log.Warn("ID d'usuari inexistent");
                    ViewBag.Error = Lang.GetString(base.lang, "Usuari_no_existeix");
                }
                return View();
            }
        }

        //
        // POST: /Account/Manage

        [HttpPost]
        [Authorize]
        public ActionResult Configuracio(string PasswordEnc, string Email, string Nom, string Cognoms, DateTime DataNaixement, char Sexe)
        {
            Log.Info("Guardar configuracio de l'usuari " + IdUsuari);
            Usuari u = new Usuari()
            {
                Id = IdUsuari,
                Password = PasswordEnc,
                Email = Email,
                Nom = Nom,
                Cognoms = Cognoms,
                DataNaixement = DataNaixement,
                Sexe = Sexe,
                Activat = true
            };

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();

                MySqlTransaction transaction = connection.BeginTransaction();

                MySqlCommand cmd = new MySqlCommand("SELECT Email FROM Usuaris WHERE Email = @Email AND Id != @Id", connection);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Id", IdUsuari);
                cmd.Transaction = transaction;

                MySqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    reader.Close();
                    transaction.Rollback();
                    Log.Warn("Email " + Email + " ja esta registrat per un altre usuari");
                    ViewBag.Error = Lang.GetString(base.lang, "Email_ja_existent");
                }
                else
                {
                    reader.Close();

                    cmd = new MySqlCommand("SELECT Email FROM Usuaris WHERE Id = @Id", connection);
                    cmd.Parameters.AddWithValue("@Id", IdUsuari);
                    cmd.Transaction = transaction;

                    reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        string emailAntic = reader.GetString(reader.GetOrdinal("Email"));
                        bool emailModificat = emailAntic != Email;

                        reader.Close();

                        object SexeSQL = Sexe.ToString();
                        if (Sexe == '-')
                        {
                            SexeSQL = DBNull.Value;
                        }

                        object CodiActivacio = DBNull.Value;
                        bool Activat = true;

                        if (emailModificat)
                        {
                            Log.Info("Email modificat. Enviar correu nou de confirmacio i desactivar el compte");
                            Guid g = Guid.NewGuid();
                            string CodiActivacioString = Convert.ToBase64String(g.ToByteArray());
                            CodiActivacioString = CodiActivacioString.Replace("=", "");
                            CodiActivacioString = CodiActivacioString.Replace("+", "");
                            CodiActivacioString = CodiActivacioString.Replace("/", "");
                            CodiActivacio = CodiActivacioString;
                            Activat = false;
                        }

                        string passwordSQL = "";
                        if (PasswordEnc != "")
                        {
                            passwordSQL = ", Password = @Password";
                        }

                        cmd = new MySqlCommand("UPDATE Usuaris SET Email = @Email" + passwordSQL + ", Nom = @Nom, Cognoms = @Cognoms, DataNaixement = @DataNaixement, Sexe = @Sexe, Activat = @Activat, CodiActivacio = @CodiActivacio WHERE Id = @Id", connection);
                        if (PasswordEnc != "")
                        {
                            cmd.Parameters.AddWithValue("@Password", PasswordEnc);
                        }
                        cmd.Parameters.AddWithValue("@Email", Email);
                        cmd.Parameters.AddWithValue("@Nom", Nom);
                        cmd.Parameters.AddWithValue("@Cognoms", Cognoms);
                        cmd.Parameters.AddWithValue("@DataNaixement", DataNaixement);
                        cmd.Parameters.AddWithValue("@Sexe", SexeSQL);
                        cmd.Parameters.AddWithValue("@Activat", Activat);
                        cmd.Parameters.AddWithValue("@CodiActivacio", CodiActivacio);
                        cmd.Parameters.AddWithValue("@Id", IdUsuari);
                        cmd.Transaction = transaction;

                        try
                        {
                            reader = cmd.ExecuteReader();

                            reader.Close();
                            transaction.Commit();

                            if (emailModificat)
                            {
                                var urlBuilder = new System.UriBuilder(Request.Url.AbsoluteUri)
                                {
                                    Path = Url.Action("Activate", "Usuari", new RouteValueDictionary(new { id = CodiActivacio }))
                                };

                                string url = urlBuilder.ToString();

                                MailMessage msg = new MailMessage();
                                msg.To.Add(Email);
                                msg.Subject = Lang.GetString(lang, "Completa_el_registre");
                                msg.From = new MailAddress("webmasterhotnotes@gmail.com", "HotNotes Admin");
                                msg.Body = Lang.GetString(base.lang, "Email_registre").Replace("[[NOM]]", Nom).Replace("[[LINK]]", url);
                                msg.IsBodyHtml = true;

                                NetworkCredential nwCredential = new NetworkCredential("webmasterhotnotes", "thehotnotespassword");

                                SmtpClient smtp = new SmtpClient("smtp.gmail.com");
                                smtp.UseDefaultCredentials = false;
                                smtp.Credentials = nwCredential;
                                smtp.EnableSsl = true;
                                smtp.Send(msg);

                                FormsAuthentication.SignOut();
                                ViewBag.Accio = Lang.GetString(base.lang, "Dades_actualitzades");
                                ViewBag.Message = Lang.GetString(base.lang, "Email_modificat");
                                Log.Info("Email de confirmacio enviat");
                                return View("Register_Complete");
                            }
                            else
                            {
                                Log.Info("Dades actualitzades");
                                ViewBag.Message = Lang.GetString(base.lang, "Dades_actualitzades");
                            }
                            return RedirectToAction("Index", "Home");
                        }
                        catch (MySqlException e)
                        {
                            reader.Close();
                            transaction.Rollback();
                            Log.Error("Error actualitzant dades", e);
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        catch (SmtpException e)
                        {
                            reader.Close();
                            transaction.Rollback();
                            Log.Error("Error enviant email de confirmacio", e);
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                    }
                    else
                    {
                        //Usuari no existent previament!
                        reader.Close();
                        transaction.Rollback();
                        Log.Warn("ID d'usuari inexistent");
                        ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                    }
                }
            }

            return View(u);
        }

        [HttpPost]
        [Authorize]
        public ActionResult Subscriure(int IdUsuariSubscrit)
        {
            Log.Info("Subscriure usuari " + IdUsuari + " a actualitzacions de l'usuari " + IdUsuariSubscrit);
            string resultat = "";

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("INSERT INTO Subscripcions (IdUsuariSubscriu, IdUsuariSubscrit) VALUES (@IdUsuariSubscriu, @IdUsuariSubscrit)", connection);
                command.Parameters.AddWithValue("@IdUsuariSubscriu", IdUsuari);
                command.Parameters.AddWithValue("@IdUsuariSubscrit", IdUsuariSubscrit);

                try
                {
                    command.ExecuteNonQuery();
                    resultat = "OK";
                }
                catch (MySqlException e)
                {
                    Log.Error("Error al subscriure usuari", e);
                    resultat = Lang.GetString(lang, "Error_subscriure");
                }
            }

            return Json(resultat);
        }

        [HttpPost]
        [Authorize]
        public ActionResult Dessubscriure(int IdUsuariSubscrit)
        {
            Log.Info("Dessubscriure usuari " + IdUsuari + " de les actualitzacions de l'usuari " + IdUsuariSubscrit);
            string resultat = "";

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("DELETE FROM Subscripcions WHERE IdUsuariSubscriu = @IdUsuariSubscriu AND IdUsuariSubscrit = @IdUsuariSubscrit", connection);
                command.Parameters.AddWithValue("@IdUsuariSubscriu", IdUsuari);
                command.Parameters.AddWithValue("@IdUsuariSubscrit", IdUsuariSubscrit);

                try
                {
                    int nFiles = command.ExecuteNonQuery();
                    if (nFiles == 1)
                    {
                        resultat = "OK";
                    }
                    else
                    {
                        Log.Warn("Usuari no subscrit previament");
                        resultat = Lang.GetString(lang, "Error_no_subscrit");
                    }
                }
                catch (MySqlException e)
                {
                    Log.Error("Error al dessubscriure usuari", e);
                    resultat = Lang.GetString(lang, "Error_dessubscriure");
                }
            }

            return Json(resultat);
        }

        #region Matricules

        [HttpPost]
        [Authorize]
        public ActionResult AfegirMatricula(int IdCarrera, int Curs)
        {
            Log.Info("Matricular usuari " + IdUsuari + " a la carrera " + IdCarrera + " i curs " + Curs);
            string resultat = "";

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT * FROM Matricules WHERE IdUsuari = @IdUsuari AND IdCarrera = @IdCarrera AND Curs = @Curs", connection);
                command.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                command.Parameters.AddWithValue("@IdCarrera", IdCarrera);
                command.Parameters.AddWithValue("@Curs", Curs);

                MySqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    Log.Warn("Usuari ja matriculat previament");
                    resultat = Lang.GetString(lang, "Error_ja_matriculat");
                }
                else
                {
                    reader.Close();
                    command = new MySqlCommand("INSERT INTO Matricules (IdUsuari, IdCarrera, Curs) VALUES (@IdUsuari, @IdCarrera, @Curs)", connection);
                    command.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                    command.Parameters.AddWithValue("@IdCarrera", IdCarrera);
                    command.Parameters.AddWithValue("@Curs", Curs);

                    int nRows = command.ExecuteNonQuery();
                    if (nRows == 1)
                    {
                        resultat = "OK";
                    }
                    else
                    {
                        resultat = Lang.GetString(lang, "Error_matricular");
                    }
                }
            }

            return Json(resultat);
        }

        [HttpPost]
        [Authorize]
        public ActionResult EliminarMatricula(int IdCarrera, int Curs)
        {
            Log.Info("Eliminar matricula de l'usuari " + IdUsuari + " a la carrera " + IdCarrera + " i curs " + Curs);
            string resultat = "";

            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("DELETE FROM Matricules WHERE IdUsuari = @IdUsuari AND IdCarrera = @IdCarrera AND Curs = @Curs", connection);
                command.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                command.Parameters.AddWithValue("@IdCarrera", IdCarrera);
                command.Parameters.AddWithValue("@Curs", Curs);

                try
                {
                    int nFiles = command.ExecuteNonQuery();
                    if (nFiles == 1)
                    {
                        resultat = "OK";
                    }
                    else
                    {
                        Log.Warn("Usuari no matriculat previament");
                        resultat = Lang.GetString(lang, "Error_no_matriculat");
                    }
                }
                catch (MySqlException e)
                {
                    Log.Error("Error al eliminar matricula", e);
                    resultat = Lang.GetString(lang, "Error_eliminar_matricula");
                }
            }

            return Json(resultat);
        }

        [Authorize]
        public ActionResult LlistatUniversitats()
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT u.Id, u.Nom, p.Poblacio FROM Universitats u, Poblacions p WHERE u.IdPoblacio = p.Id ORDER BY Nom ASC", connection);
                MySqlDataReader reader = command.ExecuteReader();

                List<Universitat> resultat = new List<Universitat>();

                while (reader.Read())
                {
                    Universitat u = new Universitat();

                    u.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    u.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    u.Poblacio = reader.GetString(reader.GetOrdinal("Poblacio"));

                    resultat.Add(u);
                }

                return Json(resultat, JsonRequestBehavior.AllowGet);
            }
        }

        [Authorize]
        public ActionResult LlistatFacultats(int IdUniversitat)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT Id, Nom, Campus FROM Facultats WHERE IdUniversitat = @IdUniversitat ORDER BY Nom ASC", connection);
                command.Parameters.AddWithValue("@IdUniversitat", IdUniversitat);

                MySqlDataReader reader = command.ExecuteReader();

                List<Facultat> resultat = new List<Facultat>();

                while (reader.Read())
                {
                    Facultat f = new Facultat();

                    f.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    f.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    if (!reader.IsDBNull(reader.GetOrdinal("Campus")))
                    {
                        f.Campus = reader.GetString(reader.GetOrdinal("Campus"));
                    }

                    resultat.Add(f);
                }

                return Json(resultat, JsonRequestBehavior.AllowGet);
            }
        }

        [Authorize]
        public ActionResult LlistatCarreres(int IdFacultat)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT Id, Nom FROM Carreres WHERE IdFacultat = @IdFacultat ORDER BY Nom ASC", connection);
                command.Parameters.AddWithValue("@IdFacultat", IdFacultat);

                MySqlDataReader reader = command.ExecuteReader();

                List<Carrera> resultat = new List<Carrera>();

                while (reader.Read())
                {
                    Carrera c = new Carrera();

                    c.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    c.Nom = reader.GetString(reader.GetOrdinal("Nom"));

                    resultat.Add(c);
                }

                return Json(resultat, JsonRequestBehavior.AllowGet);
            }
        }

        [Authorize]
        public ActionResult Seguidors(int Id)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT Id, Username FROM Usuaris WHERE Id = @Id", connection);
                command.Parameters.AddWithValue("@Id", Id);
                MySqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    Usuari usuariPrincipal = new Usuari();
                    usuariPrincipal.Username = reader.GetString(reader.GetOrdinal("Username"));

                    reader.Close();
                    command = new MySqlCommand("SELECT s.IdUsuariSubscriu, u.Nom, u.Cognoms FROM Subscripcions s, Usuaris u WHERE s.IdUsuariSubscrit = @IdUsuariSubscrit AND s.IdUsuariSubscriu = u.Id ORDER BY u.Nom ASC", connection);
                    command.Parameters.AddWithValue("@IdUsuariSubscrit", Id);

                    reader = command.ExecuteReader();

                    List<Usuari> resultat = new List<Usuari>();

                    while (reader.Read())
                    {
                        Usuari u = new Usuari();
                        u.Id = reader.GetInt32(reader.GetOrdinal("IdUsuariSubscriu"));
                        u.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                        u.Cognoms = reader.GetString(reader.GetOrdinal("Cognoms"));

                        resultat.Add(u);
                    }

                    return View(new Tuple<Usuari, List<Usuari>>(usuariPrincipal, resultat));
                }
                else
                {
                    Log.Warn("ID d'usuari inexistent: " + Id);
                    ViewBag.Error = Lang.GetString(lang, "Error_id_usuari");
                    return View();
                }
            }
        }

        [Authorize]
        public ActionResult Seguint(int Id)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand command = new MySqlCommand("SELECT Id, Username FROM Usuaris WHERE Id = @Id", connection);
                command.Parameters.AddWithValue("@Id", Id);
                MySqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    Usuari usuariPrincipal = new Usuari();
                    usuariPrincipal.Username = reader.GetString(reader.GetOrdinal("Username"));

                    reader.Close();
                    command = new MySqlCommand("SELECT s.IdUsuariSubscrit, u.Nom, u.Cognoms FROM Subscripcions s, Usuaris u WHERE s.IdUsuariSubscriu = @IdUsuariSubscriu AND s.IdUsuariSubscrit = u.Id ORDER BY u.Nom ASC", connection);
                    command.Parameters.AddWithValue("@IdUsuariSubscriu", Id);

                    reader = command.ExecuteReader();

                    List<Usuari> resultat = new List<Usuari>();

                    while (reader.Read())
                    {
                        Usuari u = new Usuari();
                        u.Id = reader.GetInt32(reader.GetOrdinal("IdUsuariSubscrit"));
                        u.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                        u.Cognoms = reader.GetString(reader.GetOrdinal("Cognoms"));

                        resultat.Add(u);
                    }

                    return View(new Tuple<Usuari, List<Usuari>>(usuariPrincipal, resultat));
                }
                else
                {
                    Log.Warn("ID d'usuari inexistent: " + Id);
                    ViewBag.Error = Lang.GetString(lang, "Error_id_usuari");
                    return View();
                }
            }
        }

        #endregion
    }
}
