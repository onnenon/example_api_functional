type task_id = TaskId of int
type task_status = Pending | Completed | Approved | Rejected

type t = {
  id : task_id;
  family_id : User.family_id;
  assigned_to : User.user_id;
  title : string;
  point_value : int;
  status : task_status;
}
