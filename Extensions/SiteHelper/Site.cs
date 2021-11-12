using System;
using System.Collections.Generic;
using System.Text;

namespace SiteHelper
{
    class Site : System.IComparable
    {
        protected string _code;
        protected bool _isMOE;
        protected bool _isActive;
        protected string _forwarderContainer;
        protected string _profilePathLoc;

        public int CompareTo(object obj)
        {
            if (obj is Site)
            {
                Site otherSite = (Site)obj;
                return this.Code.CompareTo(otherSite.Code);
            }
            else
            {
                throw new ArgumentException("Object is not a Site");
            }
        }

        public string Code
        {
            get { return _code; }
            set { _code = value; }
        }

        public bool Active
        {
            get { return _isActive; }
            set { _isActive = value; }
        }

        public bool MOE
        {
            get { return _isMOE; }
            set { _isMOE = value; }
        }

        public string ForwarderContainer
        {
            get { return _forwarderContainer; }
            set { _forwarderContainer = value; }
        }

        public string ProfilePathLoc
        {
            get { return _profilePathLoc; }
            set { _profilePathLoc = value; }
        }

        public Site()
        {
        }

        public Site(String code)
        {
            _code = code;
        }
    }
}
