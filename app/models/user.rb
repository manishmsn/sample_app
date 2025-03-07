require 'digest/sha2'
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password ,:password_confirmation
  
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :dependent => :destroy,
			   :foreign_key => "follower_id"
  has_many :reverse_relationships, :dependent => :destroy,
				   :foreign_key => "followed_id",
				   :class_name => "Relationship"
  has_many :following, :through => :relationships, 
		       :source => :followed
  has_many :followers, :through => :reverse_relationships,
				   :source => :follower
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  #validates :name, :presence => true different way of writing wat is written below
  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  validates :email, :presence => true, :length => { :maximum => 50 }, 
    :format => EMAIL_REGEX, :confirmation => true, :uniqueness => {:case_sensitive => false}
  validates :password, :presence => true, :confirmation => true,
	    :length => {:within => 6..40 }
  
before_save :encrypt_password #this is callback method called before the User object is saved to database

def has_password?(submitted_password)
  encrypted_password == encrypt(submitted_password)
end

def feed
  Micropost.where("user_id = ?", id)
end

def following?(followed)
  relationships.find_by_followed_id(followed)
end

def follow!(followed)
  relationships.create!(:followed_id => followed.id)
end

def unfollow!(followed)
  relationships.find_by_followed_id(followed).destroy
end

class << self
def authenticate(email, submitted_password)
  user = find_by_email(email)
  (user && user.has_password?(submitted_password)) ? user : nil
#   return nil if user.nil?
#   return user if user.has_password?(submitted_password)

  end
  
  def authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
    
  end
end

private

def encrypt_password
  self.salt = make_salt if new_record?
  self.encrypted_password = encrypt(self.password)
end

def encrypt(string)
  secure_hash("#{salt}--#{string}")
end

def make_salt
  secure_hash("#{Time.now.utc}--#{password}")
end

def secure_hash(string)
  Digest::SHA2.hexdigest(string)
end

end




# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean(1)      default(FALSE)
#

