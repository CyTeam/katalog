# encoding: UTF-8

class ContainerCountingController < ApplicationController
  # Filter
  has_scope :by_container_type, :as => :container_type
  has_scope :by_location, :as => :location
  has_scope :by_signature, :as => :signature

  def index
    if params[:container_type].present? || params[:location].present? || params[:signature].present?
      @dossiers = apply_scopes(Dossier, params).dossier
    else
      @dossiers = []
    end
  end
end
