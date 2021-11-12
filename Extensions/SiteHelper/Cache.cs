using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Microsoft.MetadirectoryServices;

namespace SiteHelper
{
    public class Cache
    {
        protected ArrayList _siteCache;

        public Cache()
        {
            _siteCache = new ArrayList();
        }

        public bool IsSiteActive(string siteCode)
        {
            return GetSiteInfo(siteCode).Active;
        }

        public bool IsSiteMOE(string siteCode)
        {
            return GetSiteInfo(siteCode).MOE;
        }

        public string GetSiteForwarderContainer(string siteCode)
        {
            return GetSiteInfo(siteCode).ForwarderContainer;
        }

        public string ProfilePathLoc(string siteCode)
        {
            return GetSiteInfo(siteCode).ProfilePathLoc;
        }

        private Site GetSiteInfo(string siteCode)
        {
            Site _site = new Site(siteCode);
            int ixCached = _siteCache.BinarySearch(_site);
            if (ixCached >= 0)
            {
                _site = (Site)_siteCache[ixCached];
            }
            else
            {
                _site.Active = false;
                _site.MOE = false;
                _site.ForwarderContainer = string.Empty;
                _site.ProfilePathLoc = string.Empty;
                foreach (MVEntry _mvSite in Utils.FindMVEntries("siteCode", siteCode))
                {
                    if (_mvSite.ObjectType.Equals("dbbSite"))
                    {
                        _site.Active = (_mvSite["isActive"].IsPresent && _mvSite["isActive"].BooleanValue);
                        _site.MOE = (_mvSite["isMOE"].IsPresent && _mvSite["isMOE"].BooleanValue);
                        if (_mvSite["forwarderContainer"].IsPresent)
                        {
                            _site.ForwarderContainer = _mvSite["forwarderContainer"].StringValue;
                        }
                        if (_mvSite["profilePathLoc"].IsPresent)
                        {
                            _site.ProfilePathLoc = _mvSite["profilePathLoc"].StringValue;
                        }
                        _siteCache.Add(_site);
                        //_siteCache.Sort();
                    }
                }
            }
            return _site;
        }
    }
}
