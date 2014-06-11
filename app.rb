require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

def new_meetup(name, location, description)
  if signed_in?
    Meetup.create(name: name, location: location, description: description)
    flash[:notice] = "Thank you for creating a group! you filthy animal"
  else
    authenticate!
  end
end

def check_if_user_joined(uid, meetup_id)
  Membership.exists?(user_id: uid, meetup_id: meetup_id)
end










def new_membership(uid, meetup_id)
  if signed_in?
    Membership.create(user_id: uid, meetup_id: meetup_id)
    flash[:notice] = "Thank you for joining the group!"
  else
    authenticate!
  end
end

get '/' do
  @meetups = Meetup.all.order(:name)
  erb :index
end

post '/' do
  @name = params[:meetup_name].capitalize
  @location = params[:location]
  @description = params[:description]
  new_meetup(@name, @location, @description)


  id = Meetup.last.id

  redirect "meetups/#{id}"
end



get '/meetups/:id' do
  @meetup = Meetup.find(params[:id])

   # memberships = Membership.all
   # mem_obj_array = memberships.where(meetup_id: @meetup)
   # users = User.all
   # names = []
   # users.each do |users|
   #   mem_obj_array.each do |members|
   #    if users.id == members.user_id
   #      names << users.username
   #   end
   #   end
   # end
   # @names = names
  erb :show
end

post '/meetups' do
  @uid = session[:user_id].to_s
  @meetup_id = params[:join_meetup].to_i
  if check_if_user_joined(@uid, @meetup_id)
    flash[:notice] = "You're already signed up!!!!!!"
  else
  new_membership(@uid, @meetup_id)
end

  redirect "meetups/#{@meetup_id}"
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end











