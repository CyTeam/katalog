# encoding: UTF-8

class LocationsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, except: [:index, :show]

  def attributes
    %w(title code address availability preorder)
  end
end
