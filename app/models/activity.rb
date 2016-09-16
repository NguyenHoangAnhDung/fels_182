class Activity < ActiveRecord::Base
  belongs_to :user
  scope :desc_date, -> {order(created_at: :desc)}
  validates :user, presence: true
  enum action_type: [:follow, :unfollow, :create_lesson, :update_lesson]

  def load_activity action_type
    case action_type
      when "follow", "unfollow"
        followed = find_follow
        "#{user.fullname} #{I18n.t action_type} #{followed.fullname}
          #{create_time}"
      when "create_lesson"
        target_lesson = find_lesson
        "#{I18n.t "create_lesson"} \"#{target_lesson.category.name}\"
          #{create_time}"
      when "update_lesson"
        target_lesson = find_lesson
        "#{I18n.t "finish_lesson"} \"#{target_lesson.category.name}\"
          #{I18n.t "with_result"} #{self.count_correct}
          #{I18n.t "Result"} #{Settings.word_per_lesson}
          #{create_time}"
    end
  end

  def create_time
    "(#{created_at.strftime(I18n.t "time.formats.default")})"
  end

  def find_lesson
    user.lessons.find_by id: target_id
  end

  def find_follow
    User.find_by id: target_id
  end
end
