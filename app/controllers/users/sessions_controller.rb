class Users::SessionsController < Devise::SessionsController

  def index
    @users = User.all

    respond_to do |format|
      format.html { super }
      format.json { render :json => @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.json { render :json => @user }
    end
  end

  def new
    @user = User.new
    
    respond_to do |format|
      format.json { render :json => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    respond_to do |format|
      format.html { super }
      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        render :status => 200, :json => { :error => "Success" }
      }
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.json { head :ok }
      else
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    super
  end

end
