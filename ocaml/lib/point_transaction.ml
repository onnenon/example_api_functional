type transaction_id = TransactionId of int

type transaction_reason =
  | TaskCompletion of Task.task_id
  | RewardRedemption of Reward.reward_id
  | ManualAdjustment of string

type t = {
  id : transaction_id;
  user_id : User.user_id;
  amount : int;
  reason : transaction_reason;
  created_at : Ptime.t;
}
