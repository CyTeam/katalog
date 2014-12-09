# encoding: UTF-8

class ContainerTypesController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, except: [:index, :show]

  def attributes
    %w(title code description)
  end
end
