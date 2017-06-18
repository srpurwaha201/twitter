require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')
set :bind, '0.0.0.0'

class User
	include DataMapper::Resource

	property :id,	Serial
	property :email, String
	property :password,	String

end

class Tweet
	include DataMapper::Resource

	property :id,	Serial
	property :tweet,	String
	property :user_id,	Numeric

end

class Like
	include DataMapper::Resource

	property :id,	Serial
	property :user_id,	Numeric
	property :tweet_id, Numeric

end

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	else
		tweets = Tweet.all(:order => [ :id.desc ])
		erb :index, locals: {id: session[:user_id], tweets: tweets}
	end
end

get '/signin' do
	erb :signin
end

get '/signup' do
	erb :signup
end

get '/signout' do 
	session[:user_id] = nil
	return redirect '/'
end

post '/signin' do
	email = params["email"]
	password = params["password"]
	user = User.all(email: email).first
	if user.nil?
		return redirect '/signup'
	elsif user.password == password
		session[:user_id] = user.id
		return redirect '/'
	else
		return redirect '/signup'
	end
end

post '/signup' do
	email = params["email"]
	password = params["password"]
=begin
	if User.all(email: email).nil?
=end
	if User.all(email: email).first.nil?
		user = User.new
		user.email = email
		user.password = password
		user.save
		session[:user_id] = user.id
		return redirect '/'
	else
		return redirect '/signup'
	end
end

post '/addTweet' do
	new_tweet = Tweet.new
	new_tweet.tweet = params["tweet"]
	new_tweet.user_id = session[:user_id]
	new_tweet.save
	return redirect '/'
end

post '/togglelike' do
	tweet_id = params["tweet_id"]
	user_id = session[:user_id]
	like = Like.all(user_id: user_id, tweet_id: tweet_id).first
	if like
		like.destroy
	else
		like = Like.new
		like.tweet_id = tweet_id
		like.user_id = user_id
		like.save
	end
	return redirect '/'
end




