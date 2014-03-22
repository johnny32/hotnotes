//System
using System;
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
                            return RedirectToAction("Index", "Home");
                        }
                        else
                        {
                            //Encara no ha activat el compte
                            ViewBag.Error = Lang.GetString(base.lang, "Compte_desactivat");
                        }
                    }
                    else
                    {
                        //Password incorrecte
                        ViewBag.Error = Lang.GetString(base.lang, "Username_password_incorrecte");
                    }
                }
                else
                {
                    //Usuari incorrecte
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
            /*Session.Abandon();

            // clear authentication cookie
            HttpCookie cookie1 = new HttpCookie(FormsAuthentication.FormsCookieName, "");
            cookie1.Expires = DateTime.Now.AddYears(-1);
            Response.Cookies.Add(cookie1);

            // clear session cookie (not necessary for your current problem but i would recommend you do it anyway)
            HttpCookie cookie2 = new HttpCookie("ASP.NET_SessionId", "");
            cookie2.Expires = DateTime.Now.AddYears(-1);
            Response.Cookies.Add(cookie2);
            */
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

                            return View("Register_Complete");
                        }
                        catch (SqlException)
                        {
                            reader.Close();
                            transaction.Rollback();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        catch (SmtpException)
                        {
                            reader.Close();
                            transaction.Rollback();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        //TODO Substituir els catch's per catch (Exception)
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
                        ViewBag.Response = Lang.GetString(base.lang, "Activar_correcte");
                    }
                    catch (SqlException)
                    {
                        ViewBag.Error = Lang.GetString(base.lang, "Error_activar");
                    }
                }
                else
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Codi_activar_incorrecte");
                }
            }
            return View();
        }

        //
        // GET: /Account/Manage

        public ActionResult Configuracio()
        {
            HttpCookie cookie = HttpContext.Request.Cookies.Get("UserID");
            int id = int.Parse(cookie.Value);
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                MySqlCommand cmd = new MySqlCommand("SELECT Id, Username, Password, Email, Nom, Cognoms, DataNaixement, Sexe, Activat FROM Usuaris WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", id);
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
                        Id = id,
                        Username = reader.GetString(reader.GetOrdinal("Username")),
                        Password = reader.GetString(reader.GetOrdinal("Password")),
                        Email = reader.GetString(reader.GetOrdinal("Email")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Cognoms = reader.GetString(reader.GetOrdinal("Cognoms")),
                        DataNaixement = reader.GetDateTime(reader.GetOrdinal("DataNaixement")),
                        Sexe = sexe,
                        Activat = reader.GetBoolean(reader.GetOrdinal("Activat"))
                    };

                    return View(u);
                }
                else
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Usuari_no_existeix");
                }
                return View();
            }
        }

        //
        // POST: /Account/Manage

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Configuracio(string PasswordEnc, string Email, string Nom, string Cognoms, DateTime DataNaixement, char Sexe)
        {
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

                                return View("Register_Complete");
                            }
                            else
                            {
                                ViewBag.Message = Lang.GetString(base.lang, "Dades_actualitzades");
                            }
                            return RedirectToAction("Index", "Home");
                        }
                        catch (MySqlException)
                        {
                            reader.Close();
                            transaction.Rollback();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        catch (SmtpException)
                        {
                            reader.Close();
                            transaction.Rollback();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        //TODO Substituir els catch's per catch (Exception)
                    }
                    else
                    {
                        //Usuari no existent previament!
                        reader.Close();
                        transaction.Rollback();

                        ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                    }
                }
            }

            return View(u);
        }

        [HttpPost]
        public ActionResult Subscriure(int IdUsuariSubscrit)
        {
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
                    resultat = Lang.GetString(lang, "Error_subscriure");
                }
            }

            return Json(resultat);
        }

        [HttpPost]
        public ActionResult Dessubscriure(int IdUsuariSubscrit)
        {
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
                        resultat = Lang.GetString(lang, "Error_no_subscrit");
                    }
                }
                catch (MySqlException e)
                {
                    resultat = Lang.GetString(lang, "Error_subscriure");
                }
            }

            return Json(resultat);
        }
    }
}
