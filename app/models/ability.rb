class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    @user = user || User.new # guest user (not logged in)
    can [:new, :create], User # sign up
    can :read, [Graph, Node, Course]  # view Graphs and Nodes
    can [:learning_path, :node_widget], Node
    can [:syllabus], Course
    can :groups_widget, Graph
    can :assign_roles, User
    
    # a user can edit their own profile
    can [:show, :edit, :update, :profile], User, :id => @user.id
    
    def student
      can [:new, :create, :edit, :update, :destroy], [Graph, Node]
    end
    def instructor
      student
      can [:manage], [Course]
    end
    def admin
      instructor
      can [:change_role], User
    end
    def super_admin
      admin
      can :manage, :all
    end
        
    
    if @user.role == User.Roles.Student
      student
    end
    if @user.role == User.Roles.Instructor
      instructor
    end
    if @user.role == User.Roles.Admin
      admin
    end
    if @user.role == User.Roles.SuperAdmin
      super_admin
    end
  end
end
