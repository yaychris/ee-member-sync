class UsersController < ApplicationController
  include EEMemberSync::Controller

  def cookie
    fetch_ee_session
    render :nothing => true
  end

  def param
    fetch_ee_session params[:sess]
    render :nothing => true
  end
end
