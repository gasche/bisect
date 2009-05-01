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

let table : (string, (int array)) Hashtbl.t = Hashtbl.create 17

let init fn =
  if not (Hashtbl.mem table fn) then
    Hashtbl.add table fn [| |]

let mark fn pt =
  let enlarge n = if n = 0 then 1 else if n < 1024 then n * 2 else n + 1024 in
  let arr =
    try
      let tmp = Hashtbl.find table fn in
      let len = Array.length tmp in
      if pt >= len then
        let len' = ref len in
        while pt >= !len' do len' := enlarge !len' done;
        let tmp' = Array.make !len' 0 in
        Array.blit tmp 0 tmp' 0 len;
        tmp'
      else
        tmp
    with Not_found ->
      Array.make (succ pt) 0 in
  let curr = arr.(pt) in
  arr.(pt) <- if curr < max_int then (succ curr) else curr;
  Hashtbl.replace table fn arr

let verbose =
  try
    match String.uppercase (Sys.getenv "BISECT_SILENT") with
    | "YES" | "ON" -> ignore
    | _ -> prerr_endline
  with Not_found -> prerr_endline

let file_channel =
  let base_name =
    try
      let env = Sys.getenv "BISECT_FILE" in
      if Filename.is_implicit env then
        Filename.concat Filename.current_dir_name env
      else
        env
    with Not_found ->
      Filename.concat Filename.current_dir_name "bisect" in
  let suffix = ref 0 in
  let next_name () =
    incr suffix;
    Printf.sprintf "%s%04d.out" base_name !suffix in
  let actual_name = ref (next_name ()) in
  while Sys.file_exists !actual_name do
    actual_name := next_name ()
  done;
  try
    Some (open_out_bin !actual_name)
  with _ ->
    verbose " *** Bisect runtime was unable to create file.";
    None

let dump () =
  match file_channel with
  | None -> ()
  | Some channel ->
      let content = Hashtbl.fold (fun k v acc -> (k, v) :: acc) table [] in
      (try
        Common.write_runtime_data channel content;
      with _ ->
        verbose " *** Bisect runtime was unable to write file.");
      close_out_noerr channel

let () = at_exit dump
