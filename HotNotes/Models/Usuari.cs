using System;
using System.Collections.Generic;

namespace HotNotes.Models
{
    public class Usuari
    {
        public int Id;
        public string Username;
        public string Password;
        public string Email;
        public string Nom;
        public string Cognoms;
        public DateTime DataNaixement;
        public char Sexe;
        public bool Activat;
        public int NumDocumentsPujats;
        public bool EmSegueix;
        public bool ElSegueixo;
    }
}
