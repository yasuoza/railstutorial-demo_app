class MicropostsController < ApplicationController
  before_action :set_micropost, only: [:destroy]
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  # GET /microposts
  # GET /microposts.json
  def index
    @microposts = Micropost.all
  end

  # POST /microposts
  # POST /microposts.json
  def create
    @micropost = current_user.microposts.build(micropost_params)

    respond_to do |format|
      if @micropost.save
        format.html {
          flash[:success] = "Micropost created!"
          redirect_to root_path
        }
        format.json { render action: 'show', status: :created, location: @micropost }
      else
        format.html {
          @feed_items = []
          render 'static_pages/home'
        }
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /microposts/1
  # DELETE /microposts/1.json
  def destroy
    @micropost.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_micropost
      @micropost = Micropost.find(params[:id])
    end

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
