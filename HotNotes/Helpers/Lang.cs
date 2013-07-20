using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace HotNotes.Helpers
{
    public class Lang
    {
        public static string GetString(string lang, string key)
        {
            return (string)HttpContext.GetGlobalResourceObject("language_" + lang, key);
        }

    }
}
