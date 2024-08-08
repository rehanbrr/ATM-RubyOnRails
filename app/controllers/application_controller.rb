class ApplicationController < ActionController::Base
  before_action :validate_page_param
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: 'not_found', status: :not_found
  end

  def validate_page_param
    params[:page] = params[:page].to_i < 1 ? 1 : params[:page]
  end
end
