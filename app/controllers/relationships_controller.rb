class RelationshipsController < ApplicationController
  before_action :require_logged_in_user
  before_action :load_user, only: :index
  def index
    @users = params[:type] == :following.to_s ?
      @user.following : @user.followers
  end

  def create
    @user = User.find params[:followed_id]
    current_user.follow @user
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow @user
  end
end
