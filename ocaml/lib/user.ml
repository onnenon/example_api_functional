type user_id = UserId of int
type family_id = FamilyId of int
type role = Parent | Child of { points : int }
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
