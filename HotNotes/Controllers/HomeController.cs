using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.ModelBinding.Binders;
using System.Web.Mvc;
using MySql.Data.MySqlClient;
using HotNotes.Models;
using HotNotes.Helpers;

namespace HotNotes.Controllers
{
    public class HomeController : BaseController
    {
        [Authorize]
        public ActionResult Index()
        {
            Log.Info("Pagina principal per l'usuari " + IdUsuari);
            return View();
        }

        [Authorize]
        public JsonResult DocumentsPaginaPrincipal()
        {
            using (var connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                /* Obtenir els 100 ultims documents (amb els usuaris, les assignatures a les que corresponen i les valoracions si existeixen)
                 * de les assignatures que pertanyen a les carreres i cursos matriculats
                 * o als usuaris que seguim, ordenats per data en que es van afegir descendentment
                 * (els mes recents primers)
                 */
                var command = new MySqlCommand("SELECT d.Id, d.Nom, d.Tipus, d.DataAfegit, d.IdUsuari, u.Username, d.IdAssignatura, a.Nom AS NomAssignatura, c.Nom AS NomCarrera," +
                                               " IF(EXISTS(SELECT v.IdDocument FROM Valoracions v WHERE v.IdDocument = d.Id), (SELECT AVG(v.Valoracio) FROM Valoracions v WHERE v.IdDocument = d.Id), 0) AS Valoracio " +
                                               " FROM Documents d, Usuaris u, Assignatures a, Carreres c" +
                                               " WHERE d.IdUsuari = u.Id AND d.IdAssignatura = a.Id AND a.IdCarrera = c.Id" +
                                               " AND (IdAssignatura IN (SELECT a.Id FROM Assignatures a, Matricules m WHERE a.IdCarrera = m.IdCarrera AND a.Curs = m.Curs AND m.IdUsuari = @IdUsuari)" +
                                               " OR IdUsuari IN (SELECT Id FROM Usuaris u, Subscripcions s WHERE u.Id = s.IdUsuariSubscrit AND s.IdUsuariSubscriu = @IdUsuari))" +
                                               " ORDER BY DataAfegit DESC" +
                                               " LIMIT 100", connection);
                command.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                MySqlDataReader reader = command.ExecuteReader();

                var resultats = new List<DocumentLlistat>();

                while (reader.Read())
                {
                    var d = new DocumentLlistat
                    {
                        Id = reader.GetInt32(reader.GetOrdinal("Id")),
                        Nom = reader.GetString(reader.GetOrdinal("Nom")),
                        Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus"))),
                        DataAfegit = reader.GetDateTime(reader.GetOrdinal("DataAfegit")),
                        IdUsuari = reader.GetInt32(reader.GetOrdinal("IdUsuari")),
                        Username = reader.GetString(reader.GetOrdinal("Username")),
                        IdAssignatura = reader.GetInt32(reader.GetOrdinal("IdAssignatura")),
                        NomAssignatura = reader.GetString(reader.GetOrdinal("NomAssignatura")),
                        NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera")),
                        Valoracio = reader.GetDouble(reader.GetOrdinal("Valoracio")),
                    };

                    d.DataAfegitString = d.DataAfegit.ToShortDateString() + " " + d.DataAfegit.ToShortTimeString();
                    d.TipusString = Lang.GetString(lang, d.Tipus.ToString());
                    d.LinkDocument = Url.Action("Veure", "Document", new { Id = d.Id });
                    d.LinkUsuari = Url.Action("Perfil", "Usuari", new { Id = d.IdUsuari });
                    d.LinkAssignatura = Url.Action("Assignatura", "Document", new { Id = d.IdAssignatura });

                    resultats.Add(d);
                }

                Log.Info("Total de documents: " + resultats.Count);

                return Json(resultats, JsonRequestBehavior.AllowGet);
            }
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
