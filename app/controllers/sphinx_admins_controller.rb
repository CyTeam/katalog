# encoding: UTF-8

class SphinxAdminsController < AuthorizedController
  before_filter :authenticate_user!

  def exceptions
    @model = SphinxAdminException
    @sphinx_admins = SphinxAdminException.all
  end

  def word_forms
    @model = SphinxAdminWordForm
    @sphinx_admins = SphinxAdminWordForm.all
  end

  def create
    if params['SphinxAdminException']
      SphinxAdminException.list = params['SphinxAdminException']['list']
      flash[:notice] = t('katalog.sphinx_admin.exception.done')
    end
    if params['SphinxAdminWordForm']
      SphinxAdminWordForm.list = params['SphinxAdminWordForm']['list']
      flash[:notice] = t('katalog.sphinx_admin.word_form.done')
    end

    # User :back to redirect to list where we come from
    redirect_to :back
  end
end
