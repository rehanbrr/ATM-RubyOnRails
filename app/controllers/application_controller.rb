class ApplicationController < ActionController::Base
  before_action :validate_page_param

  def validate_page_param
    params[:page] = params[:page].to_i < 1 ? 1 : params[:page]
  end
end
