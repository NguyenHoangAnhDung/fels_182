class LessonsController < ApplicationController
  before_action :require_logged_in_user
  before_action :load_lesson, only: [:edit, :update, :show]

  def create
    category = Category.find_by id: params[:category_id]
    @lesson = Lesson.new user: current_user, category: category
    if @lesson.save
      redirect_to category_lesson_path(category, @lesson)
    else
      flash[:danger] = t "alert_create_lesson_fail"
      redirect_to categories_path
    end
  end

  def edit
    @results = @lesson.results
    @results.each do |result|
      if result.answer_id.nil?
        flash.now[:danger] = t "alert_when_learn_lesson"
        @messages = {is_finished: 0}
        break
      else
        @messages = {total_correct_answers: @results.count_correct_answer,
          is_finished: 1}
      end
    end
  end

  def update
    category = Category.find_by id: params[:category_id]
    if @lesson.update_attributes lesson_params
      redirect_to edit_category_lesson_path category, @lesson
    else
      flash[:danger] = t "finish_lesson_fail"
      render category_lesson_path category, @lesson
    end
  end

  def show
  end

  def index
    @lessons = Lesson.filter_by_user(current_user)
      .paginate(page: params[:page]).per_page Settings.page_size
  end

  private
  def lesson_params
    params.require(:lesson).permit results_attributes: [:id, :answer_id]
  end

  def update_lesson_activity
    Activity.create user_id: current_user.id, target_id: @lesson.id,
      action_type: :update_lesson,
      count_correct: @lesson.results.count_correct_answer
  end
end
