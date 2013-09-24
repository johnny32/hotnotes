//System
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.SqlClient;

//HotNotes
using HotNotes.Helpers;
using HotNotes.Models;

//Json.NET
using Newtonsoft.Json;

namespace HotNotes.Controllers
{
    public class DocumentController : BaseController
    {
        //
        // GET: /Document/

        public ActionResult Index(int Id)
        {
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Nom, Idioma, Tipus, Ruta, Extensio, DataAfegit, DataModificat, Versio FROM Documents WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", Id);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    Document d = new Document();
                    d.Id = Id;
                    d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    d.Idioma = reader.GetString(reader.GetOrdinal("Idioma"));
                    d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));
                    d.Ruta = reader.GetString(reader.GetOrdinal("Ruta"));

                    if (reader.IsDBNull(reader.GetOrdinal("Extensio")))
                    {
                        d.Extensio = null;
                    }
                    else
                    {
                        d.Extensio = reader.GetString(reader.GetOrdinal("Extensio"));
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

                    return View(d);
                }
                else
                {
                    reader.Close();
                    ViewBag.Error = Lang.GetString(base.lang, "Document_no_existeix");
                }
            }
            return View();
        }

        public ActionResult TipusDocuments()
        {
            Dictionary<string, string> tipusLinks = new Dictionary<string,string>();
            tipusLinks.Add(TipusDocument.Apunts.ToString(), Lang.GetString(base.lang, "Apunts"));
            tipusLinks.Add(TipusDocument.Article.ToString(), Lang.GetString(base.lang, "Articles"));
            tipusLinks.Add(TipusDocument.Examen.ToString(), Lang.GetString(base.lang, "Examens"));
            tipusLinks.Add(TipusDocument.LinkExtern.ToString(), Lang.GetString(base.lang, "Links_externs"));
            tipusLinks.Add(TipusDocument.LinkYoutube.ToString(), Lang.GetString(base.lang, "Links_youtube"));
            tipusLinks.Add(TipusDocument.Paper.ToString(), Lang.GetString(base.lang, "Paper"));
            tipusLinks.Add(TipusDocument.PFC.ToString(), Lang.GetString(base.lang, "PFC"));
            tipusLinks.Add(TipusDocument.Practica.ToString(), Lang.GetString(base.lang, "Practiques"));
            tipusLinks.Add(TipusDocument.Treball.ToString(), Lang.GetString(base.lang, "Treballs"));

            return new ContentResult { Content = JsonConvert.SerializeObject(tipusLinks), ContentType = "application/json" };
        }
        
    }
}
