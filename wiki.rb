#Aidan Toole
#Dr. Beacham
#Practical 5
#10 October 2018
#test push


require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'
require 'data_mapper'
require 'zip'

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


def get_user_details()
	@list2 = User.all :order => :id.desc
	@list2.each do |liste|
		if $credentials
			if liste.username == $credentials[0]
				return liste				
			end
		end
	end
end

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

helpers do
	def protected!
		if authorized?
			return
		end

		redirect '/denied'
	end

	def authorized?
		if $credentials != nil
			@Userz = User.first(:username => $credentials[0])
			if @Userz
				if @Userz.edit == true
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
end

get '/frank-says' do
	redirect to ('/')
end

get '/' do
	info = ""

	len = info.length
	len1 = len
	readFile("wiki.txt")

	@info = info + " " + $myinfo
	
	len = @info.length
	len2 = len - 1
	len3 = len2 - len1
	@words = @info.split.size
	@characters = len3.to_s

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
	@list2 = User.all :order => :id.desc
	@list2.each do |liste|
		if $credentials
			if liste.username == $credentials[0]
				if liste.edit ==  false
					redirect 'denied'
				end
			end
		end
	end
	info = ""
	file = File.open("wiki.txt")
	file.each do |line|
		info = info + line
	end

	file.close
	@info = info

	erb :edit

end

#PUT EDIT
put '/edit' do
	info = "#{params[:message]}"
	@info = info
	
	usr = get_user_details()
	log_file = File.open("log.txt","a")
	log_file.print usr.username," ", Time.now
	log_file.puts ""
	
	file = File.open("wiki.txt", "w")
	file.puts @info
	file.close
	log_file.close
	redirect '/'
end

get '/edit_log' do
editLogs = ""
file = File.open("log.txt")
file.each do |line|
	editLogs = editLogs + line + '<br>'
	end

file.close
@editLogs = editLogs
	erb :edit_log
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

#No Account
get '/noaccount' do
	erb :noAccount
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

put '/user/:uzer' do
	n = User.first(:username => params[:uzer])
	n.edit = params[:edit] ? 1 : 0
	n.save
	redirect '/'
end

get '/user/delete/:uzer' do
	protected!
	n = User.first(:username => params[:uzer])
	if n.username =="Admin"
		erb :denied
	else
		n.destroy
		@list2 = User.all :order => :id.desc
		redirect '/'
	end
end

#Admin
get '/admincontrols' do
	protected!
	#CAn't get this part to work, BUT it runs without protected!
	@list2 = User.all :order => :id.desc
	erb :adminControls
end

#Create Account
get '/createaccount' do
	erb :createAccount
end

#Post Account
post '/createaccount' do
	n = User.new
	n.username = params[:username]
	n.password = params[:password]
	n.date_joined = Time.now 
	n.edit = false
	if n.username == "Admin" and n.password == "password"
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




#Not Found
get '/notfound' do
	erb :notFound
end

#Access Denied
get '/denied' do
	erb :denied
end

get '/reset' do
	FileUtils.cp("wiki_initial.txt","wiki.txt")
	redirect '/'
end

get '/backup' do
	input_filenames = ['wiki.txt']
	
	zipfile_name = "wiki_backup_1.zip"

	if File.exist?("wiki_backup_1.zip")
		if File.exist?("wiki_backup_2.zip")
			if File.exist?("wiki_backup_3.zip")
				FileUtils.rm("wiki_backup_3.zip")
				FileUtils.mv("wiki_backup_2.zip", "wiki_backup_3.zip")
				FileUtils.mv("wiki_backup_1.zip", "wiki_backup_2.zip")
			else 
				FileUtils.mv("wiki_backup_2.zip", "wiki_backup_3.zip")
				FileUtils.mv("wiki_backup_1.zip", "wiki_backup_2.zip")
			end
		else
			FileUtils.mv("wiki_backup_1.zip", "wiki_backup_2.zip")
		end
	end
	Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
	input_filenames.each do |filename|
		# Two arguments:
		# - The name of the file as it will appear in the archive
		# - The original file, including the path to find it
		zipfile.add(filename, File.join(filename))
	end
	
	end

redirect '/'
end

#404 Use case
not_found do
	status 404
	redirect '/notfound'
end 