class MoviesController < ApplicationController
  
  before_action :set_sort_column
  	
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  @all_ratings = Movie.all_ratings
  @ratings_to_show = params[:ratings] || session[:ratings] || @all_ratings
  @sort_column = params[:sort]
  
  @ratings_to_show_hash = params[:ratings] || {}
  @ratings_to_show = @ratings_to_show_hash.keys
  #@ratings_to_show = @ratings_to_show.keys if @ratings_to_show.is_a?(Hash)

  if @ratings_to_show.nil? || @ratings_to_show.empty?
    @movies = Movie.all
  else
    @movies = Movie.with_ratings(@ratings_to_show)
  end

  if @sort_column=='title_header'
    @movies = @movies.order(title: :asc)
  elsif @sort_column == 'release_date_header'
    @movies = @movies.order(release_date: :asc)
  end
end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def generate_ratings_hash
    ratings_hash = {}
    Movie.all_ratings.each { |rating| ratings_hash[rating] = '0'}
    @ratings_to_show.each { |rating| ratings_hash[rating] = '1'}
    ratings_hash
  end

  def set_sort_column
    session[:sort_column] = params[:sort] if params[:sort].present?
    @sort_column = session[:sort_column]
  end

end

class Movie < ActiveRecord::Base
   def self.all_ratings
	   pluck(:rating).uniq # Adjust this list to include all your possible ratings
   end
   def self.with_ratings(ratings_list)
	   if ratings_list.nil? || ratings_list.empty?
		   all
	   else
		   where(rating: ratings_list.map {|r| r.upcase })
	   end
   end
end   




