using System;

namespace HotNotes.Models
{
    public class Document
    {
        public int Id;
        public string Nom;
        public string Idioma;
        public TipusDocument Tipus;
        public string KeyAmazon;
        public string MimeType;
        public Nullable<bool> ExamenCorregit;
        public DateTime DataAfegit;
        public Nullable<DateTime> DataModificat;
        public Nullable<double> Versio;
        public string NomAutor;
        public string LinkPerfilAutor;
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
}