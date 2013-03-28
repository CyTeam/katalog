# encoding: UTF-8

class ContainerCountingController < ApplicationController
  # Filter
  has_scope :by_container_type, :as => :container_type
  has_scope :by_location, :as => :location

  def index
    if params[:container_type].present? || params[:location].present?
      @dossiers = apply_scopes(Dossier, params).dossier
    else
      @dossiers = nil
    end
  end
end
