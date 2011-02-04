class SphinxAdminsController < AuthorizedController
  before_filter :authenticate_user!

  def exceptions
    @sphinx_admins = SphinxAdmin.exceptions
  end

  def word_forms
    @sphinx_admins = SphinxAdmin.word_forms
  end
end