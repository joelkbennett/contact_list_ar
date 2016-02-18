class Contact < ActiveRecord::Base

  validates_presence_of :name, :email
  has_many :phone_numbers

end