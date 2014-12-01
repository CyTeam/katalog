class TopicsController < AuthorizedController
  include DossiersHelper
  before_action :authenticate_user!, except: [:index, :show, :navigation]

  def update
    @topic = Topic.find(params[:id])
    if params[:update_signature]
      @topic.update_signature(params[:topic][:signature])
    end
    update!
  end

  def index
    redirect_to dossiers_path
  end

  def create
    create! do |format|
      format.html do
        flash[:notice] = t('katalog.created', signature: resource.signature, title: resource.title)
        redirect_to new_resource_url
      end
    end
  end

  def navigation
    show! do |format|
      format.html do
        redirect_to url_for_topic(resource)
      end
    end
  end

  private

  def topic_params
    params.require(:topic).permit(
      :signature, :title, :update_signature
    )
  end
end
