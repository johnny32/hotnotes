//System
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.SqlClient;

//Json.NET
//using Newtonsoft.Json;

namespace HotNotes.Controllers
{
    public class ComentariController : BaseController
    {
        public ActionResult ComentarisDocument(int IdDocument)
        {
            using (SqlConnection connection = new SqlConnection(GetConnection()))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("SELECT D.Comentari AS Comentari, D.Data AS Data, D.IdUsuari AS IdUsuari, U.Nom AS NomUsuari FROM Documents D, Usuaris U WHERE IdDocument = @IdDocument AND D.IdUsuari = U.Id ORDER BY Data ASC", connection);
                cmd.Parameters.AddWithValue("@IdDocument", IdDocument);
                SqlDataReader reader = cmd.ExecuteReader();

                List<string> comentaris = new List<string>();

                while (reader.Read())
                {
                    string comentari = "{'Comentari': '" + reader.GetString(reader.GetOrdinal("Comentari")) + "', ";
                    comentari += "'Data': '" + reader.GetDateTime(reader.GetOrdinal("Data")).ToShortDateString() + "', ";
                    comentari += "'NomUsuari': '" + reader.GetString(reader.GetOrdinal("NomUsuari")) + "', ";
                    comentari += "'UrlUsuari': '" + Url.Action("Index", "Usuari", new { IdUsuari = reader.GetInt32(reader.GetOrdinal("IdUsuari")) }) + "'}";

                    comentaris.Add(comentari);
                }

                return Json("[" + string.Join(",", comentaris.ToArray()) + "]");
            }
        }

    }
}
