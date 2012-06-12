class Edgetype < ActiveRecord::Base
  attr_accessible :name, :desc
  has_many :edges
  
  # Validations
  validates :name, :presence => true, :uniqueness => true
end
