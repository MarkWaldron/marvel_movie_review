class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def search
    if params[:search].present?
      @movies = Movie.search(params[:search])
    else
      @movies = Movie.all
    end
  end

  def index
    @movies = Movie.all.order("created_at DESC")
  end

  def show
    @reviews = Review.where(movie_id: @movie.id).order("created_at DESC")
    if @reviews.blank?
      @avg_review = 0
    else
      @avg_review = @reviews.average(:rating).round(2)
    end
  end

  def new
    @movie = current_user.movies.build
  end

  def edit
    if @movie.user != current_user
      redirect_to root_path, notice: "This is not your movie to edit"
    end
  end

  def update
    if @movie.update(movie_params) && @movie.user == current_user
      redirect_to @movie, notice: "Movie was successfully updated"
    else
      render 'edit'
    end
  end

  def create
    @movie =  current_user.movies.build(movie_params)

    if @movie.save
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def destroy
    if @movie.user == current_user
      @movie.destroy
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:title, :description, :movie_length, :director, :rating, :image )
    end
end
