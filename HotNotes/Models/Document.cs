﻿using System;
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
}