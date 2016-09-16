class Lesson < ActiveRecord::Base
  after_create :create_word_for_specify_lesson
  after_save :update_create_lesson_activity
  belongs_to :user
  belongs_to :category
  has_many :results, dependent: :destroy
  has_many :words, through: :results
  validates :user, presence: true
  validates :category, presence: true
  accepts_nested_attributes_for :results
  scope :filter_by_user, ->(current_id) do
    where(user_id: current_id)
  end
  private
  def create_word_for_specify_lesson
    @words = Word.unlearned.randomize Settings.word_per_lesson
    @words.each do |word|
      self.results.build word_id: word.id
    end
  end

  def update_create_lesson_activity
    lesson = Activity.find_by(target_id: id,
      action_type: Activity.action_types[:create_lesson])
    if lesson.nil?
      Activity.create user_id: user_id, target_id: id,
        action_type: :create_lesson
    else
      Activity.create user_id: user_id, target_id: id,
        action_type: :update_lesson,
        count_correct: self.results.count_correct_answer
    end
  end
end
