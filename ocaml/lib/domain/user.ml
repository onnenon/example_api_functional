open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type user_id = UserId of int
type family_id = FamilyId of int
type role = Parent | Child
type date = { year : int; month : int; day : int }

let user_id_of_yojson = function
  | `Int n -> UserId n
  | json ->
      Ppx_yojson_conv_lib.Yojson_conv.of_yojson_error
        "expected integer for user_id" json

let yojson_of_user_id (UserId n) = `Int n
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

let family_id_of_yojson = function
  | `Int n -> FamilyId n
  | json ->
      Ppx_yojson_conv_lib.Yojson_conv.of_yojson_error
        "expected integer for family_id" json

let yojson_of_family_id (FamilyId n) = `Int n

let role_of_yojson = function
  | `String "parent" -> Parent
  | `String "child" -> Child
  | json ->
      Ppx_yojson_conv_lib.Yojson_conv.of_yojson_error
        "role must be 'parent' or 'child'" json

let yojson_of_role = function
  | Parent -> `String "parent"
  | Child -> `String "child"

let date_of_yojson = function
  | `String s -> (
      match date_of_string s with Ok d -> d | Error msg -> failwith msg)
  | json ->
      Ppx_yojson_conv_lib.Yojson_conv.of_yojson_error "expected date string"
        json

let yojson_of_date d = `String (date_to_string d)

type t = {
  id : user_id;
  family_id : family_id;
  username : string;
  display_name : string;
  avatar : string option;
  birthday : date option;
  role : role;
}
[@@deriving yojson_of]

type new_user = {
  family_id : family_id;
  username : string;
  display_name : string;
  avatar : string option; [@yojson.option]
  birthday : date option; [@yojson.option]
  role : role;
}
[@@deriving of_yojson]

type patch_user = {
  family_id : family_id option; [@yojson.option]
  username : string option; [@yojson.option]
  display_name : string option; [@yojson.option]
  avatar : string option option; [@yojson.option]
  birthday : date option option; [@yojson.option]
  role : role option; [@yojson.option]
}
[@@deriving of_yojson]

type user_error =
  | UniqueViolation of string
  | ForeignViolation
  | NotNullViolation of string
