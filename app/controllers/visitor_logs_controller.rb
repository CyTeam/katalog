class VisitorLogsController < AuthorizedController
  before_filter :authenticate_user!

  def create
    create! { visitor_logs_path }
  end

  def index
    @visitor_logs = VisitorLog.order(created_at: :desc)
  end

  private

  def visitor_log_params
    params.require(:visitor_log).permit(
      :title, :content
    ).merge(user: current_user)
  end
end
