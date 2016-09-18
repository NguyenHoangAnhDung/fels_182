class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save {email.downcase!}
  has_many :lessons, dependent: :destroy
  has_many :activities , dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 100},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}
  validates :fullname, presence: true, length: {maximum: 50}
  validates :password, length: {minimum: 6}
  has_secure_password

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def follow user
    active_relationships.create followed_id: user.id
  end

  def unfollow user
    active_relationships.find_by(followed_id: user.id).destroy
  end

  def following? user
    following.include? user
  end

  def is? user
    self == user
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new remember_digest == remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end

  def is_user? user
    self == user
  end
end
