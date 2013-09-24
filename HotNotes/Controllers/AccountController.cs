using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using HotNotes.Helpers;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.Routing;
using HotNotes.Models;

namespace HotNotes.Controllers
{
    [Authorize]
    public class AccountController : BaseController
    {
        //
        // GET: /Account/Login

        [AllowAnonymous]
        public ActionResult Login(string returnUrl)
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        //
        // POST: /Account/Login

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string Username, string PasswordEnc, bool RememberMe)
        {
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Id, Password, Activat FROM Usuaris WHERE Username = '" + Username + "'", connection);
                SqlDataReader reader = cmd.ExecuteReader();

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
            return RedirectToAction("Login", "Account");
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
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Username FROM Usuaris WHERE Username = '" + Username + "'", connection);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Usuari_ja_existent");
                }
                else
                {
                    reader.Close();
                    cmd = new SqlCommand("SELECT Email FROM Usuaris WHERE Email = '" + Email + "'", connection);
                    reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        ViewBag.Error = Lang.GetString(base.lang, "Email_ja_existent");
                    }
                    else
                    {
                        reader.Close();
                        string SexeSQL = (Sexe != '-') ? ("'" + Sexe + "'") : "NULL";
                        Guid g = Guid.NewGuid();
                        string CodiActivacio = Convert.ToBase64String(g.ToByteArray());
                        CodiActivacio = CodiActivacio.Replace("=", "");
                        CodiActivacio = CodiActivacio.Replace("+", "");
                        CodiActivacio = CodiActivacio.Replace("/", "");
                        cmd = new SqlCommand("INSERT INTO Usuaris (Username, Password, Email, Nom, Cognoms, DataNaixement, Sexe, Activat, CodiActivacio) VALUES ('" + Username + "', '" + PasswordEnc + "', '" + Email + "', '" + Nom + "', '" + Cognoms + "', '" + DataNaixement.ToString() + "', " + SexeSQL + ", 'false', '" + CodiActivacio + "')", connection);
                        try
                        {
                            reader = cmd.ExecuteReader();

                            var urlBuilder = new System.UriBuilder(Request.Url.AbsoluteUri)
                                {
                                    Path = Url.Action("Activate", "Account", new RouteValueDictionary(new { id = CodiActivacio }))
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
                            return View("Register_Complete");
                        }
                        catch (SqlException)
                        {
                            reader.Close();
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        catch (SmtpException)
                        {
                            reader.Close();

                            cmd = new SqlCommand("DELETE FROM Usuaris WHERE Username = '" + Username + "'", connection);
                            cmd.ExecuteReader();
                            reader.Close();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        //TODO Substituir els catch's per catch (Exception)
                    }
                }
            }

            // If we got this far, something failed, redisplay form
            return View();
        }

        //
        // GET: /Account/Activate
        [AllowAnonymous]
        public ActionResult Activate(string id)
        {
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Id FROM Usuaris WHERE CodiActivacio = '" + id + "'", connection);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    reader.Close();

                    try
                    {
                        cmd = new SqlCommand("UPDATE Usuaris SET Activat = 'true', CodiActivacio = NULL WHERE Id = " + Id.ToString(), connection);
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

        public ActionResult Manage()
        {
            HttpCookie cookie = HttpContext.Request.Cookies.Get("UserID");
            int id = int.Parse(cookie.Value);
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Id, Username, Password, Email, Nom, Cognoms, DataNaixement, Sexe, Activat FROM Usuaris WHERE Id = " + id, connection);
                SqlDataReader reader = cmd.ExecuteReader();

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
        public ActionResult Manage(int Id, string Username, string PasswordEnc, string Email, string Nom, string Cognoms, DateTime DataNaixement, char Sexe)
        {
            Usuari u = new Usuari()
            {
                Id = Id,
                Username = Username,
                Password = PasswordEnc,
                Email = Email,
                Nom = Nom,
                Cognoms = Cognoms,
                DataNaixement = DataNaixement,
                Sexe = Sexe,
                Activat = true
            };

            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Username FROM Usuaris WHERE Username = '" + Username + "' AND Id != " + Id, connection);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Usuari_ja_existent");
                }
                else
                {
                    reader.Close();
                    cmd = new SqlCommand("SELECT Email FROM Usuaris WHERE Email = '" + Email + "' AND Id != " + Id, connection);
                    reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        ViewBag.Error = Lang.GetString(base.lang, "Email_ja_existent");
                    }
                    else
                    {
                        reader.Close();
                        string SexeSQL = (Sexe != '-') ? ("'" + Sexe + "'") : "NULL";
                        Guid g = Guid.NewGuid();
                        string CodiActivacio = Convert.ToBase64String(g.ToByteArray());
                        CodiActivacio = CodiActivacio.Replace("=", "");
                        CodiActivacio = CodiActivacio.Replace("+", "");
                        CodiActivacio = CodiActivacio.Replace("/", "");

                        string passwordSQL = "";
                        if (PasswordEnc != "")
                        {
                            passwordSQL = ", Password = '" + PasswordEnc + "'";
                        }

                        cmd = new SqlCommand("UPDATE Usuaris SET Username = '" + Username + "'" + passwordSQL + ", Email = '" + Email + "', Nom = '" + Nom + "', Cognoms = '" + Cognoms + "', DataNaixement = '" + DataNaixement.ToString() + "', Sexe = " + SexeSQL + " WHERE Id = " + Id, connection);
                        try
                        {
                            reader = cmd.ExecuteReader();

                            reader.Close();

                            ViewBag.Message = Lang.GetString(base.lang, "Dades_actualitzades");
                            return View(u);
                        }
                        catch (SqlException)
                        {
                            reader.Close();
                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }
                        /*catch (SmtpException)
                        {
                            reader.Close();

                            cmd = new SqlCommand("DELETE FROM Usuaris WHERE Username = '" + Username + "'", connection);
                            cmd.ExecuteReader();
                            reader.Close();

                            ViewBag.Error = Lang.GetString(base.lang, "Error_registre");
                        }*/
                        //TODO Substituir els catch's per catch (Exception)
                    }
                }
            }

            return View(u);
        }

    }
}
