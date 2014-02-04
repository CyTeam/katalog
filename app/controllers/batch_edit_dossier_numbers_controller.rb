# encoding: UTF-8

class BatchEditDossierNumbersController < ApplicationController
  # Responders
  respond_to :html, :js, :json

  def index
    # Stay on this action after search
    @search_path = edit_batch_edit_dossier_numbers_path

    @dossiers = Topic.by_level(2)
  end

  def edit
    setup_query

    # Stay on this action after search
    @search_path = edit_batch_edit_dossier_numbers_path

    params[:edit_report] ||= {}
    # Collection setup
    @years = params[:edit_report][:years]
    @years ||= []

    year_amount = (params[:edit_report][:year_amount] || 1).to_i
    padding_years = year_amount - @years.length
    if padding_years > 0
      @years += [Time.now.year - 1] * padding_years
    elsif padding_years < 0
      @years = @years[0..(year_amount-1)]
    end

    @dossiers = apply_scopes(Dossier, params[:edit_report]).by_signature(@query).dossier.paginate :page => params[:page], :per_page => params[:per_page]
  end

  def setup_query
    params[:search] ||= {}
    @query = params[:search][:text].try(:strip) || ''
    @signature_search = /^[0-9.]{1,8}$/.match(@query)
  end
end
