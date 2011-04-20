# This class holds all the user information's.
class User < ActiveRecord::Base
  # PaperTrail: change log
  has_paper_trail :ignore => [:created_at, :updated_at, :reset_password_token, :remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Login attribute for login with email or password.
  #
  # * Code snippet from: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  attr_accessor :login

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  # Added username and login as accessible attributes for a login with username or email.
  #
  # * Code snippet from: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  attr_accessible :username, :login

  # Authorization roles
  has_and_belongs_to_many :roles, :autosave => true
  scope :by_role, lambda{|role| include(:roles).where(:name => role)}
  attr_accessible :role_texts

  # Validate the presence and uniqueness of the username
  validates_presence_of :username
  validates_uniqueness_of :username

  # Return current role name.
  def role_name
    # Just return _a_ role, no preferences or guarantees...
    roles.last.name
  end

  # Check if user has a role.
  def role?(role)
    !!self.roles.find_by_name(role.to_s)
  end

  # Returns all roles of an user as text.
  def role_texts
    roles.map{|role| role.name}
  end

  # Sets the roles to an user.
  def role_texts=(role_names)
    self.roles = Role.where(:name => role_names)
  end

  def to_s
    email
  end

  # Overwritten for login with username
  #
  # * Code snippet from: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  def self.find_for_database_authentication(conditions)
   login = conditions.delete(:login)
   where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end
end
