# encoding: UTF-8

class TopicsController < AuthorizedController
  include DossiersHelper
  # Authentication
  before_filter :authenticate_user!, except: [:index, :show, :navigation]

  protected

  def collection
    @topics ||= end_of_association_chain.paginate(page: params[:page])
  end

  # Actions

  public

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
end
