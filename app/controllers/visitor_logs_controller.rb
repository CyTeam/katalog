class VisitorLogsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def attributes
    ['title', 'user', 'created_at']
  end

  def create
    @visitor_log = VisitorLog.new(params[:visitor_log])
    @visitor_log.user = current_user
    
    create!
  end
end