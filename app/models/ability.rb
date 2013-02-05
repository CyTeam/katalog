# encoding: UTF-8

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
    @user = user
    @user ||= User.new # guest user

    alias_action :index, :to => :list

    common

    # Load the abilities for all roles.
    @user.roles.each {|role| send(role.name) }
  end

  # The abilities of the admin role.
  def admin
    can :manage, :all
  end

  # The abilities of the editor role.
  def editor
    can :manage, [Container, ContainerType, Dossier, DossierNumber, Keyword, Location, Topic, VisitorLog, Report]
  end

  # The abilities for everyone.
  def common
    can [:index, :show, :search, :welcome], [Dossier, Topic], :internal => false
    can :navigation, Topic
    can [:index, :show, :search], [Container, ContainerType, DossierNumber, Keyword, Location]
    can [:index, :show], Report, :public => true
    can :report, Dossier
    can [:new, :create], Reservation
  end
end
