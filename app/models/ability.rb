# Defines abilities
#
# This class defines the abilities available to User Roles.
# Will be used by CanCan.
class Ability
  # Aspects
  include CanCan::Ability
 
  # Available roles
  def self.roles
    Role.all.map{|r| r.name }
  end
  
  # Prepare roles to show in select inputs etc.
  def self.roles_for_collection
    self.roles.map{|role| [I18n.translate(role, :scope => 'cancan.roles'), role]}
  end
  
  # Main role/ability definitions.
  def initialize(user)
    @user ||= User.new # guest user
 
    alias_action :index, :to => :list
    
    @user.roles.each {|role| send(role) }
    visitor
  end
  
  def admin
    can :manage, :all
  end
  
  def editor
    can :manage, [Container, ContainerType, Dossier, DossierNumber, Keyword, Location, Topic, VisitorLog, Report]
  end
  
  def visitor
    can [:index, :show, :search], [Dossier, Topic], :internal => false
    can :sub_topics, Topic
    can [:index, :show, :search], [Container, ContainerType, DossierNumber, Keyword, Location]
    can [:index, :show], Report, :public => true
    can :report, Dossier
    can [:new, :create], Reservation 
  end
end
