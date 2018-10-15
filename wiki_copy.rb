#Aidan Toole
#Dr. Beacham
#Practical 2
#18 September 2018

require 'sinatra'
require 'sinatra/reloader'

require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db") 

class User 
	include DataMapper::Resource 
	property :id, Serial
	property :username, Text, :required => true
	property :password, Text, :required => true 
	property :date_joined, DateTime 
	property :edit, Boolean, :required=> true, :default => false 
end 

DataMapper.finalize.auto_upgrade!

$myinfo = "Aidan Toole"
@info = ""

def readFile(filename)
	info = ""
	file = File.open(filename)
	file.each do |line|
		info = info + line
		#what is going on here exactly??
	end
	file.close
	$myinfo = info
end


get '/frank-says' do
	redirect to ('/')
end

get '/' do
	info = "Hello There!"

	len = info.length
	len1 = len
	readFile("wiki.txt")

	@info = info + " " + $myinfo

	len = @info.length
	len2 = len - 1
	len3 = len2 - len1

	@words = len3.to_s

	#This doesn't work though. Trying to figure out what the logic is for this stuff ^^^
	# @info = @info + len3.to_s

	erb :Home

end


#ABOUT section
get '/about' do
	erb :about
end

#CREATE section
get '/create' do

	erb :create
end

#Edit Section
get '/edit' do
	info = ""
	file = File.open("wiki.txt")
	file.each do |line|
		info = info + line
	end

	file.close
	@info = info

	erb :edit

end

#Login
get '/login' do
	erb :login
end

#Wrong Account
post '/login' do
	$credentials = [params[:username],params[:password]]
	@Users = User.first(:username => $credentials[0]) 
	#what's this stuff do?
	
	if @Users 
		if @Users.password == $credentials[1]
	 		redirect '/' 
	 	else
	 		$credentials = [' ',' ']
			redirect '/wrongaccount'
	end

	else
		$credentials = [' ',' ']
		redirect '/wrongaccount'
	end
end

#Wrong Account
get '/wrongaccount' do 
	erb :wrongAccount 
end 

#User Stuff
get '/user/:uzer' do
	@Userz = User.first(:username => params[:uzer])

	if @Userz != nil
		erb :profile
	else
		redirect '/noAccount'
	end
end

#Create Account
get '/createaccount' do
	erb :createAccount
end

get '/admincontrols' do
	erb :adminControls
end

#Post Account
post '/createaccount' do
	n = User.new
	n.username = params[:username]
	n.password = params[:password]
	n.date_joined = Time.now 

	if n.username == "Admin" and n.password == "Password"
		n.edit = true
	end
	
	n.save
	redirect '/' 
end

#Logout
get '/logout' do
	$credentials = [' ',' ']
	redirect '/'
end


#PUT EDIT
put '/edit' do
	info = "#{params[:message]}"
	@info = info
	file = File.open("wiki.txt", "w")
	file.puts @info
	file.close
	redirect '/'
end


#404 Use case
not_found do
	status 404
	redirect '/'
end 