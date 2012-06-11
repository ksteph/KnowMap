class Edgetype < ActiveRecord::Base
  attr_accessible :desc, :name
  has_many :edges
end
