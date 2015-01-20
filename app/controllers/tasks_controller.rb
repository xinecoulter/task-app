class TasksController < ApplicationController
  def new
    @task = Task.new
  end

  def create
    Task.make(current_user.id, task_params)
    redirect_to root_path
  end

private

  def task_params
    params.require(:task).permit(:name, :description, :last_completed_at, :interval)
  end
end
