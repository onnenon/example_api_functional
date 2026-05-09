type user_id = UserId of int
type family_id = FamilyId of int
type role = Parent | Child
type date = { year : int; month : int; day : int }

type t = {
  id : user_id;
  family_id : family_id;
  username : string;
  display_name : string;
  avatar : string option;
  birthday : date option;
  role : role;
}

type new_user = {
  family_id : family_id;
  username : string;
  display_name : string;
  avatar : string option;
  birthday : date option;
  role : role;
}

type patch_user = {
  family_id : family_id option;
  username : string option;
  display_name : string option;
  avatar : string option option;
  birthday : date option option;
  role : role option;
}

type user_error =
  | UniqueViolation of string
  | ForeignViolation
  | NotNullViolation of string

let ( let* ) = Result.bind

let date_of_string s =
  match String.split_on_char '-' s with
  | [ y; m; d ] -> (
      try
        Ok
          {
            year = int_of_string y;
            month = int_of_string m;
            day = int_of_string d;
          }
      with Failure _ -> Error "invalid date components")
  | _ -> Error "birthday must be YYYY-MM-DD"

let date_to_string d = Printf.sprintf "%04d-%02d-%02d" d.year d.month d.day
