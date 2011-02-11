class User < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:reset_password_token, :remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  # Authorization roles
  has_and_belongs_to_many :roles, :autosave => true
  scope :by_role, lambda{|role| include(:roles).where(:name => role)}
  attr_accessible :role_texts

  # Return current role name.
  def role_name
    # Just return _a_ role, no preferences or guarantees...
    roles.last.name
  end
  
  def role?(role)
    !!self.roles.find_by_name(role.to_s)
  end

  def role_texts
    roles.map{|role| role.name}
  end
  
  def role_texts=(role_names)
    self.roles = Role.where(:name => role_names)
  end

  # Helpers
  def to_s
    email
  end
end
