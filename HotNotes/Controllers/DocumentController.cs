﻿//System
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Mvc;
using System.Data.SqlClient;
using System.IO;

//HotNotes
using HotNotes.Helpers;
using HotNotes.Models;

//Json.NET
using Newtonsoft.Json;

//AWS
using Amazon.S3;
using Amazon.S3.Model;

namespace HotNotes.Controllers
{
    public class DocumentController : BaseController
    {
        //
        // GET: /Document/

        public ActionResult Veure(int Id)
        {
            using (SqlConnection connection = new SqlConnection(GetConnectionString()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Nom, Idioma, Tipus, KeyAmazon, MimeType, ExamenCorregit, DataAfegit, DataModificat, Versio, IdUsuari FROM Documents WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", Id);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    Document d = new Document();
                    d.Id = Id;
                    d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    d.Idioma = reader.GetString(reader.GetOrdinal("Idioma"));
                    d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));
                    d.KeyAmazon = reader.GetString(reader.GetOrdinal("KeyAmazon"));

                    if (reader.IsDBNull(reader.GetOrdinal("MimeType")))
                    {
                        d.MimeType = null;
                    }
                    else
                    {
                        d.MimeType = reader.GetString(reader.GetOrdinal("MimeType"));
                    }

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
                        d.Versio = reader.GetFloat(reader.GetOrdinal("Versio"));
                    }

                    int idUsuari = reader.GetInt32(reader.GetOrdinal("IdUsuari"));

                    reader.Close();

                    cmd = new SqlCommand("SELECT Nom, Cognoms FROM Usuaris WHERE Id = @Id", connection);
                    cmd.Parameters.AddWithValue("@Id", idUsuari);
                    reader = cmd.ExecuteReader();
                    reader.Read();

                    d.NomAutor = reader.GetString(reader.GetOrdinal("Nom")) + " " + reader.GetString(reader.GetOrdinal("Cognoms"));
                    d.LinkPerfilAutor = Url.Action("Index", "Usuari", new { Id = idUsuari });

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
            Dictionary<string, string> tipusLinks = new Dictionary<string, string>();
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

        public ActionResult GetComentaris(int IdDocument)
        {
            using (SqlConnection connection = new SqlConnection(GetConnectionString()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT C.IdUsuari, U.Nom, U.Cognoms, C.Comentari, C.Data FROM Comentaris C, Usuaris U WHERE C.IdDocument = @IdDocument AND C.IdUsuari = U.Id ORDER BY C.Data ASC", connection);
                cmd.Parameters.AddWithValue("@IdDocument", IdDocument);
                SqlDataReader reader = cmd.ExecuteReader();

                List<Comentari> comentaris = new List<Comentari>();

                while (reader.Read())
                {
                    Comentari comentari = new Comentari();

                    comentari.TextComentari = reader.GetString(reader.GetOrdinal("Comentari"));
                    comentari.Data = reader.GetDateTime(reader.GetOrdinal("Data")).ToShortDateString();
                    comentari.NomUsuari = reader.GetString(reader.GetOrdinal("Nom")) + " " + reader.GetString(reader.GetOrdinal("Cognoms"));
                    comentari.LinkUsuari = Url.Action("Index", "Usuari", new { Id = reader.GetInt32(reader.GetOrdinal("IdUsuari")) });

                    comentaris.Add(comentari);
                }

                reader.Close();

                return Json(comentaris, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public ActionResult Comentar(int IdDocument, string Comentari)
        {
            using (SqlConnection connection = new SqlConnection(GetConnectionString()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("INSERT INTO Comentaris (IdUsuari, IdDocument, Comentari, Data) VALUES (@IdUsuari, @IdDocument, @Comentari, @Data)", connection);
                cmd.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                cmd.Parameters.AddWithValue("@IdDocument", IdDocument);
                cmd.Parameters.AddWithValue("@Comentari", Comentari);
                cmd.Parameters.AddWithValue("@Data", DateTime.Now);
                int rowsAffected = cmd.ExecuteNonQuery();

                string resposta = "";

                if (rowsAffected == 1)
                {
                    resposta = "OK";
                }
                else
                {
                    resposta = "Error";
                }
                return Json(resposta);
            }
        }

        [HttpGet]
        public ActionResult Pujar()
        {
            using (SqlConnection connection = new SqlConnection(GetConnectionString()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT A.Id, A.Nom, A.Curs, C.Nom AS NomCarrera FROM Assignatures A, Carreres C, Matricules M WHERE M.IdUsuari = @IdUsuari AND M.IdCarrera = A.IdCarrera AND A.IdCarrera = C.Id AND M.Curs = A.Curs ORDER BY A.IdCarrera, A.Curs, A.Nom", connection);
                cmd.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                SqlDataReader reader = cmd.ExecuteReader();

                List<Assignatura> l = new List<Assignatura>();

                while (reader.Read())
                {
                    Assignatura a = new Assignatura();
                    a.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                    a.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    a.Curs = reader.GetInt32(reader.GetOrdinal("Curs"));
                    a.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));

                    l.Add(a);
                }

                return View(l);
            }
        }

        [HttpPost]
        public ActionResult Pujar(string Nom, string Idioma, string Tipus, int IdAssignatura, HttpPostedFileBase Fitxer = null, string KeyAmazon = null, Nullable<bool> ExamenCorregit = null)
        {
            TipusDocument TipusDocument = (TipusDocument)Enum.Parse(typeof(TipusDocument), Tipus);
            string MimeType = "";

            if (Fitxer != null)
            {
                MimeType = Fitxer.ContentType;

                if (!MatchMIMETipus(MimeType, TipusDocument))
                {
                    ViewBag.Error = Lang.GetString(base.lang, "MimeType_no_suportat");

                    if (TipusDocument == TipusDocument.Practica)
                    {
                        ViewBag.Error += Lang.GetString(base.lang, "MimeType_practiques");
                    }
                    else
                    {
                        ViewBag.Error += Lang.GetString(base.lang, "MimeType_no_practiques");
                    }

                    return View();
                }

                char[] separator = new char[1];
                separator[0] = '.';
                string[] parts = Fitxer.FileName.Split(separator);
                string extensio = parts[parts.Length - 1];

                using (IAmazonS3 client = new AmazonS3Client(AmazonEndPoint))
                {
                    PutObjectRequest putRequest = new PutObjectRequest();
                    putRequest.BucketName = "doc_" + IdAssignatura;
                    putRequest.Key = Path.GetRandomFileName().Replace(".", "") + "." + extensio;
                    putRequest.FilePath = Fitxer.FileName; //TODO: Comprovar
                    putRequest.ContentType = MimeType;
                    putRequest.InputStream = Fitxer.InputStream;

                    PutObjectResponse putResponse = client.PutObject(putRequest);
                    
                }                
            }

            using (SqlConnection connection = new SqlConnection(GetConnectionString()))
            {
                SqlCommand cmd = new SqlCommand("INSERT INTO Documents (Nom, Idioma, Tipus, KeyAmazon, MimeType, ExamenCorregit, DataAfegit, Versio, IdUsuari, IdAssignatura) OUTPUT INSERTED.ID VALUES (@Nom, @Idioma, @Tipus, @KeyAmazon, @MimeType, @ExamenCorregit, GETDATE(), 1.0, @IdUsuari, @IdAssignatura)", connection);
                cmd.Parameters.AddWithValue("@Nom", Nom);
                cmd.Parameters.AddWithValue("@Idioma", Idioma);
                cmd.Parameters.AddWithValue("@Tipus", TipusDocument.ToString());
                cmd.Parameters.AddWithValue("@KeyAmazon", KeyAmazon);
                if (MimeType != "")
                {
                    cmd.Parameters.AddWithValue("@MimeType", MimeType);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@MimeType", DBNull.Value);
                }
                if (ExamenCorregit.HasValue)
                {
                    cmd.Parameters.AddWithValue("@ExamenCorregit", ExamenCorregit.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@ExamenCorregit", DBNull.Value);
                }
                cmd.Parameters.AddWithValue("@IdUsuari", IdUsuari);
                cmd.Parameters.AddWithValue("@IdAssignatura", IdAssignatura);

                try
                {
                    int IdDocument = (int)cmd.ExecuteScalar();
                }
                catch (SqlException e)
                {

                    ViewBag.Error = Lang.GetString(base.lang, "Error_pujar_document");
                }
            }

            return View();
        }

        private bool MatchMIMETipus(string mimeType, TipusDocument tipusDocument)
        {
            bool correcte = false;

            if (tipusDocument == TipusDocument.LinkExtern || tipusDocument == TipusDocument.LinkYoutube)
            {
                correcte = true;
            }
            else
            {
                if (mimeType == "application/msword" || //.doc
                    mimeType == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" || //.docx
                    mimeType == "application/vnd.oasis.opendocument.text" ||
                    mimeType == "application/pdf" || //.pdf
                    mimeType == "text/plain" || //.txt
                    mimeType == "application/vnd.ms-powerpoint" || //.ppt
                    mimeType == "application/vnd.openxmlformats-officedocument.presentationml.presentation" || //.pptx
                    ((mimeType == "multipart/x-zip" || mimeType == "application/zip") && tipusDocument == TipusDocument.Practica)) //Les practiques poden estar tambe en format .zip
                {
                    correcte = true;
                }
            }

            return correcte;
        }

    }
}
