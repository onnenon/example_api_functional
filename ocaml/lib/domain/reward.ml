type reward_id = RewardId of int

type t = {
  id : reward_id;
  family_id : User.family_id;
  title : string;
  point_cost : int;
}
