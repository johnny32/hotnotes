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
                SqlCommand cmd = new SqlCommand("SELECT Password, Activat FROM Usuaris WHERE Username = '" + Username + "'", connection);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    if (PasswordEnc == (string)reader["Password"])
                    {
                        if ((bool)reader["Activat"])
                        {
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

                            MailMessage msg = new MailMessage();
                            msg.To.Add(Email);
                            msg.Subject = Lang.GetString(lang, "Completa_el_registre");
                            msg.From = new MailAddress("webmasterhotnotes@gmail.com", "HotNotes Admin");
                            msg.Body = "This is the message body";

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
            /*if (ModelState.IsValid)
            {
                // Attempt to register the user
                try
                {
                    WebSecurity.CreateUserAndAccount(model.UserName, model.Password);
                    WebSecurity.Login(model.UserName, model.Password);
                    return RedirectToAction("Index", "Home");
                }
                catch (MembershipCreateUserException e)
                {
                    ModelState.AddModelError("", ErrorCodeToString(e.StatusCode));
                }
            }*/

            // If we got this far, something failed, redisplay form
            return View();
        }

    }
}
