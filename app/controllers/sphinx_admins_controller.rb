class SphinxAdminsController < AuthorizedController

  belongs_to :sphinx_admin_word_form, :sphinx_admin_exception, :polymorphic => true

  before_filter :authenticate_user!

  def exceptions
    @sphinx_admins = SphinxAdminException.all
  end

  def word_forms
    @sphinx_admins = SphinxAdminWordForm.all
  end
end