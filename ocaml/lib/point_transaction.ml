type transaction_id = TrasactionId of int

type transaction_reason =
  | TaskCompletion of Task.task_id
  | RewardRedeption of Reward.reward_id
  | ManualAdjustment of string

type t = {
  id : transaction_id;
  user_id : User.user_id;
  amount : int;
  raeson : transaction_reason;
  created_at : float;
}
