class CategoryGroup < ActiveRecord::Base
  has_many :categories, :dependent => :destroy, :order => "name ASC"
  has_many :events, :through => :categories

  validates_presence_of :name, :message => "Namnet får inte vara tomt"
end
