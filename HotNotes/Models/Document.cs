using System;
using System.Collections.Generic;

namespace HotNotes.Models
{
    public class Document
    {
        public int Id;
        public string Nom;
        public string Idioma;
        public TipusDocument Tipus;
        public string KeyAmazon;
        public string Ruta;
        public string MimeType;
        public Nullable<bool> ExamenCorregit;
        public DateTime DataAfegit;
        public Nullable<DateTime> DataModificat;
        public Nullable<double> Versio;
        public string NomAutor;
        public string LinkPerfilAutor;

        public static List<TipusDocument> TipusDocuments
        {
            get
            {
                List<TipusDocument> l = new List<TipusDocument>();
                l.Add(TipusDocument.Apunts);
                l.Add(TipusDocument.Treball);
                l.Add(TipusDocument.Examen);
                l.Add(TipusDocument.Article);
                l.Add(TipusDocument.PFC);
                l.Add(TipusDocument.Paper);
                l.Add(TipusDocument.Practica);
                l.Add(TipusDocument.LinkExtern);
                l.Add(TipusDocument.LinkYoutube);

                return l;
            }
        }
    }

    public enum TipusDocument
    {
        Apunts,
        Treball,
        Examen,
        Article,
        PFC,
        Paper,
        Practica,
        LinkExtern,
        LinkYoutube
    }

    public class DocumentLlistat
    {
        public int Id;
        public string Nom;
        public TipusDocument Tipus;
        public string TipusString;
        public DateTime DataAfegit;
        public string DataAfegitString;
        public int IdUsuari;
        public string Username;
        public int IdAssignatura;
        public string NomAssignatura;
        public string NomCarrera;
        public double Valoracio;
        //Placeholders per construir els links MVC parametritzats a les crides AJAX
        public string LinkDocument;
        public string LinkUsuari;
        public string LinkAssignatura;

        public string ToString()
        {
            return Nom;
        }
    }

    public class DocumentLlistatComparer : IEqualityComparer<DocumentLlistat>
    {
        public bool Equals(DocumentLlistat a, DocumentLlistat b)
        {
            return a.Id == b.Id;
        }

        public int GetHashCode(DocumentLlistat item)
        {
            return StringComparer.InvariantCultureIgnoreCase.GetHashCode(item.Id);
        }
    }
}