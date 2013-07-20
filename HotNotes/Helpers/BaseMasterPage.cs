using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace HotNotes.Helpers
{
    public class BaseMasterPage : System.Web.Mvc.ViewMasterPage
    {
        //
        // GET: /BaseMasterPage/

        public string lang { get; set; }
    }
}
