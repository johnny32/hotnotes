//System
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
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT Nom, Idioma, Tipus, KeyAmazon, Ruta, MimeType, ExamenCorregit, DataAfegit, DataModificat, Versio, IdUsuari FROM Documents WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", Id);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    Document d = new Document();
                    d.Id = Id;
                    d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    d.Idioma = reader.GetString(reader.GetOrdinal("Idioma"));
                    d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));

                    if (reader.IsDBNull(reader.GetOrdinal("KeyAmazon")))
                    {
                        d.KeyAmazon = null;
                    }
                    else
                    {
                        d.KeyAmazon = reader.GetString(reader.GetOrdinal("KeyAmazon"));
                    }

                    if (reader.IsDBNull(reader.GetOrdinal("Ruta")))
                    {
                        d.Ruta = null;
                    }
                    else
                    {
                        d.Ruta = reader.GetString(reader.GetOrdinal("Ruta"));
                    }

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

                    //Carregar PDFs a la variable Ruta per a poder-los mostrar incrustats
                    if (d.MimeType == "application/pdf" && d.KeyAmazon != null)
                    {
                        using (IAmazonS3 client = new AmazonS3Client(AmazonEndPoint))
                        {
                            GetObjectRequest getRequest = new GetObjectRequest();
                            getRequest.BucketName = "hotnotes";
                            getRequest.Key = d.KeyAmazon;

                            using (GetObjectResponse response = client.GetObject(getRequest))
                            {
                                MemoryStream ms = new MemoryStream();
                                response.ResponseStream.CopyTo(ms);

                                char[] separator = new char[1];
                                separator[0] = '.';
                                string[] parts = response.Key.Split(separator);
                                string extensio = parts[parts.Length - 1];

                                string tmpPath = Path.Combine(Path.GetTempPath(), d.Nom + "." + extensio);

                                using (FileStream stream = new FileStream(tmpPath, FileMode.Create, FileAccess.Write))
                                {
                                    stream.Write(ms.ToArray(), 0, ms.ToArray().Length);
                                }

                                d.Ruta = tmpPath;
                            }
                        }
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

        public ActionResult GetComentaris(int IdDocument)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
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
            using (SqlConnection connection = new SqlConnection(ConnectionString))
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
            return View(GetLlistaAssignatures());
        }

        [HttpPost]
        public ActionResult Pujar(string Nom, string Idioma, string Tipus, int IdAssignatura, string Ruta = null, HttpPostedFileBase Fitxer = null, Nullable<bool> ExamenCorregit = null)
        {
            TipusDocument TipusDocument = (TipusDocument)Enum.Parse(typeof(TipusDocument), Tipus);
            string MimeType = "";
            string KeyAmazon = "";

            if (Fitxer == null && Ruta == null)
            {
                ViewBag.Error = Lang.GetString(base.lang, "Falta_ruta_o_fitxer");
                return View(GetLlistaAssignatures());
            }

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

                    return View(GetLlistaAssignatures());
                }

                char[] separator = new char[1];
                separator[0] = '.';
                string[] parts = Fitxer.FileName.Split(separator);
                string extensio = parts[parts.Length - 1];

                KeyAmazon = Path.GetRandomFileName().Replace(".", "") + "." + extensio;
                using (IAmazonS3 client = new AmazonS3Client(AmazonEndPoint))
                {
                    try
                    {
                        PutObjectRequest putRequest = new PutObjectRequest();
                        putRequest.BucketName = "hotnotes";
                        putRequest.Key = KeyAmazon;
                        putRequest.ContentType = MimeType;
                        putRequest.InputStream = Fitxer.InputStream;

                        PutObjectResponse putResponse = client.PutObject(putRequest);

                        if (putResponse.HttpStatusCode != System.Net.HttpStatusCode.OK)
                        {
                            Log.Error("Error pujjant arxiu a S3. HttpStatusCode: " + putResponse.HttpStatusCode.ToString());
                            ViewBag.Error = Lang.GetString(lang, "Error_Amazon_S3");
                            return View(GetLlistaAssignatures());
                        }
                    }
                    catch (AmazonS3Exception ex)
                    {
                        Log.Error("Error pujant arxiu a S3", ex);
                        ViewBag.Error = Lang.GetString(lang, "Error_Amazon_S3");
                        return View(GetLlistaAssignatures());
                    }
                }
            }

            if (TipusDocument == Models.TipusDocument.LinkYoutube && Ruta != null)
            {
                //Fix per inserir els videos de youtube a la pagina de Veure
                Ruta = Ruta.Replace("http:", "");
                if (!Ruta.Contains("embed/"))
                {
                    Ruta = Ruta.Replace("youtube.com/", "youtube.com/embed/");
                }
            }

            int IdDocument = -1;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("INSERT INTO Documents (Nom, Idioma, Tipus, KeyAmazon, MimeType, Ruta, ExamenCorregit, DataAfegit, Versio, IdUsuari, IdAssignatura) OUTPUT INSERTED.ID VALUES (@Nom, @Idioma, @Tipus, @KeyAmazon, @MimeType, @Ruta, @ExamenCorregit, GETDATE(), 1.0, @IdUsuari, @IdAssignatura)", connection);
                cmd.Parameters.AddWithValue("@Nom", Nom);
                cmd.Parameters.AddWithValue("@Idioma", Idioma);
                cmd.Parameters.AddWithValue("@Tipus", TipusDocument.ToString());
                if (KeyAmazon != "")
                {
                    cmd.Parameters.AddWithValue("@KeyAmazon", KeyAmazon);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@KeyAmazon", DBNull.Value);
                }
                if (MimeType != "")
                {
                    cmd.Parameters.AddWithValue("@MimeType", MimeType);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@MimeType", DBNull.Value);
                }
                if (Ruta != "")
                {
                    cmd.Parameters.AddWithValue("@Ruta", Ruta);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@Ruta", DBNull.Value);
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
                    connection.Open();
                    IdDocument = (int)cmd.ExecuteScalar();
                }
                catch (Exception e)
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Error_pujar_document");
                    return View(GetLlistaAssignatures());
                }
                finally
                {
                    connection.Close();
                }
            }

            return RedirectToAction("Veure", "Document", new { Id = IdDocument });
        }

        [HttpGet]
        public ActionResult Descarregar(int Id)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("SELECT Nom, MimeType, KeyAmazon FROM Documents WHERE Id = @Id", connection);
                cmd.Parameters.AddWithValue("@Id", Id);

                connection.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    string Nom = reader.GetString(reader.GetOrdinal("Nom"));
                    string MimeType = reader.GetString(reader.GetOrdinal("MimeType"));
                    string KeyAmazon = reader.GetString(reader.GetOrdinal("KeyAmazon"));

                    using (IAmazonS3 client = new AmazonS3Client(AmazonEndPoint))
                    {
                        GetObjectRequest getRequest = new GetObjectRequest();
                        getRequest.BucketName = "hotnotes";
                        getRequest.Key = KeyAmazon;

                        using (GetObjectResponse response = client.GetObject(getRequest))
                        {
                            MemoryStream ms = new MemoryStream();
                            response.ResponseStream.CopyTo(ms);

                            char[] separator = new char[1];
                            separator[0] = '.';
                            string[] parts = response.Key.Split(separator);
                            string extensio = parts[parts.Length - 1];

                            return File(ms.ToArray(), MimeType, Nom + "." + extensio);
                        }
                    }
                }
            }
            return View();
        }

        //Retorna tots els documents que pertanyen a una assignatura
        public ActionResult Assignatura(int Id)
        {
            ViewBag.IdAssignatura = Id;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand("SELECT Nom FROM Assignatures WHERE Id = @Id", connection);
                command.Parameters.AddWithValue("@Id", Id);
                SqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    ViewBag.NomAssignatura = reader.GetString(reader.GetOrdinal("Nom"));

                    reader.Close();

                    command = new SqlCommand("SELECT d.Id, d.Nom, d.Tipus, d.IdUsuari, d.DataAfegit, u.Username FROM Documents d, Usuaris u WHERE d.IdUsuari = u.Id AND d.IdAssignatura = @IdAssignatura ORDER BY DataAfegit DESC", connection);
                    command.Parameters.AddWithValue("@IdAssignatura", Id);
                    reader = command.ExecuteReader();

                    List<Document> resultat = new List<Document>();

                    while (reader.Read())
                    {
                        Document d = new Document();
                        d.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                        d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                        d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));
                        d.DataAfegit = reader.GetDateTime(reader.GetOrdinal("DataAfegit"));
                        d.NomAutor = reader.GetString(reader.GetOrdinal("Username"));
                        d.LinkPerfilAutor = Url.Action("Index", "Usuari", new { Id = reader.GetInt32(reader.GetOrdinal("IdUsuari")) });

                        resultat.Add(d);
                    }

                    return View(resultat);
                }
                else
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Error_id_assignatura");
                    return View();
                }
            }
        }

        //Retorna tots els documents que pertanyen a un usuari
        public ActionResult Usuari(int Id)
        {
            ViewBag.IdUsuari = Id;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand("SELECT Nom FROM Usuaris WHERE Id = @Id", connection);
                command.Parameters.AddWithValue("@Id", Id);
                SqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    ViewBag.NomUsuari = reader.GetString(reader.GetOrdinal("Nom"));

                    reader.Close();
                    command = new SqlCommand("SELECT d.Id, d.Nom, d.Tipus, d.IdAssignatura, a.Nom AS NomAssignatura, c.Nom AS NomCarrera FROM Documents d, Assignatures a, Carreres c WHERE d.IdAssignatura = a.Id AND a.IdCarrera = c.Id AND d.IdUsuari = @IdUsuari ORDER BY DataAfegit DESC", connection);
                    command.Parameters.AddWithValue("@IdUsuari", Id);
                    reader = command.ExecuteReader();

                    List<DocumentLlistatUsuari> resultat = new List<DocumentLlistatUsuari>();

                    while (reader.Read())
                    {
                        DocumentLlistatUsuari d = new DocumentLlistatUsuari();
                        d.Id = reader.GetInt32(reader.GetOrdinal("Id"));
                        d.Nom = reader.GetString(reader.GetOrdinal("Nom"));
                        d.Tipus = (TipusDocument)Enum.Parse(typeof(TipusDocument), reader.GetString(reader.GetOrdinal("Tipus")));
                        d.IdAssignatura = reader.GetInt32(reader.GetOrdinal("IdAssignatura"));
                        d.NomAssignatura = reader.GetString(reader.GetOrdinal("NomAssignatura"));
                        d.NomCarrera = reader.GetString(reader.GetOrdinal("NomCarrera"));

                        resultat.Add(d);
                    }

                    return View(resultat);
                }
                else
                {
                    ViewBag.Error = Lang.GetString(base.lang, "Error_id_usuari");
                    return View();
                }
                
            }
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

        private List<Assignatura> GetLlistaAssignatures()
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
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

                return l;
            }
        }

    }
}
