class PagesController < ApplicationController

  #layout 'blueprint/print'
  
  def home
    @title = "Home"
    if signed_in?
      @micropost = Micropost.new
      @feed_items = current_user.feed.paginate(:page => params[:page])
    end
  end

  def contact
    @title = "Contact Us"
  end
 
  def about
    @title = "About Us"
  end
  
  def help
    @title = "Help"
  end

end
