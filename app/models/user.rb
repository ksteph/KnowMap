class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :first, :last, :role_ids
  has_many :actions
  has_and_belongs_to_many :roles
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
  
  def role?(role)
    roles.map{|r| r.name}.include? role.to_s.titlecase
  end
  
  def to_s
    "#{first} #{last}" == " " ? "#{email}" : "#{first} #{last}"
  end
end
