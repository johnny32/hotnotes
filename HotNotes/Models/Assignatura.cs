using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace HotNotes.Models
{
    public class Assignatura
    {
        public int Id;
        public string Nom;
        public int Curs;
        public Carrera Carrera;
        public int NumDocs;

        public string ToString()
        {
            return Nom;
        }
    }
}