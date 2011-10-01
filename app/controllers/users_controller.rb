class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def self.consumer
    # The readkey and readsecret below are the values you get during registration
    OAuth::Consumer.new("2GKxz71b7gT9Bow1N0nw", "kagE2iPJRo3MQeASPYEtGsD16z4lyxufszIaErj8w",{ :site => 'http://api.twitter.com', :request_endpoint => 'http://api.twitter.com', :sign_in => true})
  end
  
  def create
    @request_token = UsersController.consumer.get_request_token
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    # Send to twitter.com to authorize
    redirect_to @request_token.authorize_url
    return
  end
  
  def callback
    @request_token = OAuth::RequestToken.new(UsersController.consumer, session[:request_token], session[:request_token_secret])
    @at = @request_token.get_access_token
    @asecret = @at.secret
    @atoken = @at.token
    @ctoken = "2GKxz71b7gT9Bow1N0nw"
    @csecret = "kagE2iPJRo3MQeASPYEtGsD16z4lyxufszIaErj8w"
    Twitter.configure do |config|
	  config.consumer_key       = @ctoken
	  config.consumer_secret    = @csecret
	  config.oauth_token        = @atoken
	  config.oauth_token_secret = @asecret
    end

    client = Twitter::Client.new
   # client.update('Test post from the console')


   #@response = UsersController.consumer.request(:get, '/account/verify_credentials.json', @access_token, {:scheme => :query_string})
    
   # case @at
   # when Net::HTTPSuccess
      #user_info = JSON.parse(@response.body) 
     /# unless user_info['screen_name']
        flash[:notice] = "Authentication Failed"
        redirect_to :action => :index
        return
      end#/
      screen_name = client.user.screen_name
      @user = User.new({:screen_name => screen_name, :token => @atoken, :secret => @asecret})
      @user.save!
      redirect_to(@user)
   /# else
      RAILS_DEFAULT_LOGGER.error "failed"
      flash[:notice] = "Failed"
      redirect_to :action => :index
      return
    end#/
  end 
 
  def show
    @user = User.find(params[:id])
    @access_token = OAuth::AccessToken.new(UsersController.consumer, @user.token, @user.secret)
    RAILS_DEFAULT_LOGGER.error "Making OAuth Request"
    @response = UsersController.consumer.request(:get, 'favorites.json', @acess_token, {:scheme => :query_string })
    
    case @response
    when Net::HTTPSuccess
      @favorites = JSON.parse(@response.body)
      respond_to do |format|
        format.html
      end
    else
      RAILS_DEFAULT_LOGGER.error "Failed to get favs"
      flash[:notice] = "Auth Failed"
      redirect_to "users#new"
      return
    end
  end
  
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
