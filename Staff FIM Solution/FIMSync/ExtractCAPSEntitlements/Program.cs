using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ExtractCAPSEntitlements
{
    class Program
    {
        static void Main(string[] args)
        {
            if (!args.Length.Equals(2))
            {
                Console.WriteLine("Usage: ExtractCAPSEntitlements <AVP inputFilename (incl. full path)> <XML outputFilename (path derived from input file)>");
            }
            else
            {
                ProcessAVPFile worker = new ProcessAVPFile(args[0].ToString(), args[1].ToString());
            }
        }
    }
}
