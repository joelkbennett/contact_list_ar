class PhoneNumber < ActiveRecord::Base

  validates_presence_of :label, :phone_number
  belongs_to :contact

end