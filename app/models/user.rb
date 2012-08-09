class User < ActiveRecord::Base
  # define Roles
  cattr_accessor :Roles
  self.Roles = Class.new
  self.Roles.instance_eval do
    def Student
      "student"
    end
    def Instructor
      "instructor"
    end
    def Admin
      "admin"
    end
    def SuperAdmin
      "superadmin"
    end
    def all
      [self.Student, self.Instructor, self.Admin, self.SuperAdmin]
    end
  end
  
  attr_accessible :email, :password, :password_confirmation, :first, :last, :track, :as => :new
  attr_accessible :email, :first, :last, :track, :as => :update
  attr_accessible :role, :as => :change_role
  
  has_many :actions
  has_many :course_memberships
  has_many :courses, :through => :course_memberships 
  
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def to_s
    "#{first} #{last}" == " " ? "#{email}" : "#{first} #{last}"
  end
end
