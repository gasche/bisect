(*
 * This file is part of Bisect.
 * Copyright (C) 2008-2009 Xavier Clerc.
 *
 * Bisect is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Bisect is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

let dtd = [
  "<!ELEMENT bisect-report (summary,file*)>" ;
  "" ;
  "<!ELEMENT file (summary,point*)>" ;
  "<!ATTLIST file path CDATA #REQUIRED>" ;
  "" ;
  "<!ELEMENT summary (element*)>" ;
  "" ;
  "<!ELEMENT element EMPTY>" ;
  "<!ATTLIST element kind CDATA #REQUIRED>" ;
  "<!ATTLIST element count CDATA #REQUIRED>" ;
  "<!ATTLIST element total CDATA #REQUIRED>" ;
  "" ;
  "<!ELEMENT point EMPTY>" ;
  "<!ATTLIST point offset CDATA #REQUIRED>" ;
  "<!ATTLIST point count CDATA #REQUIRED>" ;
  "<!ATTLIST point kind CDATA #REQUIRED>" ;
  ""
]

let xml_header = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>"

let make () =
  object (self)
    method header = xml_header ^ "\n<bisect-report>\n"
    method footer = "</bisect-report>\n"
    method summary s = self#sum "  " s
    method file_header f = Printf.sprintf "  <file path=\"%s\">\n" f
    method file_footer _ = Printf.sprintf "  </file>\n"
    method file_summary s = self#sum "    " s
    method point ofs nb k = Printf.sprintf "    <point offset=\"%d\" count=\"%d\" kind=\"%s\"/>\n" ofs nb (Common.string_of_point_kind k)
    method private sum tabs s =
      let line k x y =
        Printf.sprintf "<element kind=\"%s\" count=\"%d\" total=\"%d\"/>" k x y in
      let lines =
        List.map
          (fun (k, v) ->
            line (Common.string_of_point_kind k) v.ReportStat.count v.ReportStat.total)
          s in
      let x, y = ReportStat.summarize s in
      tabs ^ "<summary>\n  " ^ tabs ^
      (String.concat ("\n  " ^ tabs) lines) ^
      "\n  " ^ tabs ^ (line "total" x y) ^
      "\n" ^ tabs ^ "</summary>\n"
  end
