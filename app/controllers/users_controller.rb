class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def self.consumer
    # The readkey and readsecret below are the values you get during registration
    OAuth::Consumer.new("2GKxz71b7gT9Bow1N0nw", "kagE2iPJRo3MQeASPYEtGsD16z4lyxufszIaErj8w",{ :site=>"http://twitter.com" })
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
    @accesstoken = @request_token.get_access_token
    @response = UsersController.consumer.request(:get, '/account/verify_credentials.json', @access_token, {:scheme => :query_string})
    
    case @response
    when Net::HTTPSuccess
      user_info = JSON.parse(@response.body) 
      unless user_info['screen_name']
        flash[:notice] = "Authentication Failed"
        redirect_to :action => :index
        return
      end
      @user = User.new({:screen_name => user_info['screen_name'], :token => @access_token.token, :secret => @access_token.secret})
      @user.save!
      redirect_to(@user)
    else
      RAILS_DEFAULT_LOGGER.error "failed"
      flash[:notice] = "Failed"
      redirect_to :action => :index
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
