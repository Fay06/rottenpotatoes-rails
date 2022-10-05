class MoviesController < ApplicationController
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if session[:ratings] == nil || session[:sort_by] == nil
      hash = Hash[@all_ratings.collect {|key| [key, '1']}]
      session[:ratings] = hash if session[:ratings] == nil
      session[:sort_by] = '' if session[:sort_by] == nil
      redirect_to movies_path(:ratings => hash, :sort_by => '') and return
    end  

    if params[:ratings] == nil and session[:ratings] == nil
      @movies = Movie.all
      @ratings_to_show = []
    elsif params[:ratings] == nil and session[:ratings] != nil
      @movies = Movie.where(rating: session[:ratings])
      @ratings_to_show = session[:ratings]
      params[:ratings] = @ratings_to_show
    else
      @movies = Movie.where(rating: params[:ratings].keys)
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    end

    if params[:sort_by] != nil
      @movies = @movies.order(params[:sort_by])
    end
    session[:sort_by] = params[:sort_by]
    if params[:sort_by] == 'title'
      @title_header = 'hilite bg-warning'       
    elsif params[:sort_by] == 'release_date'
      @release_date_header = 'hilite bg-warning'
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
end
