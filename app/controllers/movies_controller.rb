class MoviesController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join]
  def index
    @movies = Movie.all
  end

  def new
    @movie = Movie.new
  end

  def show
    @movie = Movie.find(params[:id])
    @reviews = @movie.reviews.order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
  end

  def edit
    @movie = Movie.find(params[:id])
    if current_user != @movie.user
      redirect_to root_path, alert: "你没有权限修改影片"
    end
  end


  def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user
    if @movie.save
       current_user.join!(@movie)
       redirect_to movies_path
    else
       render :new
    end
  end

  def update
    @movie = Movie.find(params[:id])
    if current_user != @movie.user
      redirect_to root_path, alert: "你没有权限修改影片"
    end
    if @movie.update(movie_params)
       redirect_to movies_path, notice: "更新成功"
    else
       render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    if current_user != @movie.user
      redirect_to root_path, alert: "你没有权限删除影片"
    end
    @movie.destroy
    flash[:alert] = "已删除电影"
    redirect_to movies_path
  end

  def join
    @movie = Movie.find(params[:id])

     if !current_user.is_member_of?(@movie)
       current_user.join!(@movie)
       flash[:notice] = "成功关注该电影！"
     else
       flash[:warning] = "你看不到这句话的，呵呵"
     end

     redirect_to movie_path(@movie)
   end

   def quit
     @movie = Movie.find(params[:id])

     if current_user.is_member_of?(@movie)
       current_user.quit!(@movie)
       flash[:alert] = "不再关注该电影！"
     else
       flash[:warning] = "本来可以不要这句的，不过我觉得留着好点"
     end

     redirect_to movie_path(@movie)
   end

private

   def movie_params
   params.require(:movie).permit(:title, :description)
   end
end
