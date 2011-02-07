class SphinxAdminsController < AuthorizedController
  before_filter :authenticate_user!

  def exceptions
    @sphinx_admins = SphinxAdminException.all
  end

  def word_forms
    @sphinx_admins = SphinxAdminWordForm.all
  end

  def update
    # User :back to redirect to list where we come from
    update!{ :back }
  end

  def create
    # User :back to redirect to list where we come from
    create!{ :back }
  end
end
