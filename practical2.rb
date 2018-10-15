#Aidan Toole
#Dr. Beacham
#Practical 2
#18 September 2018

require 'sinatra'
require 'sinatra/reloader'

$myinfo = "Aidan Toole"
@info = ""

def readFile(filename)
	info = ""
	file = File.open(filename)
	file.each do |line|
		info = info + line
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
	@info = @info + len3.to_s


	'<html><body>' +
	'<b>Menu</b><br>' +
	'<a href="/">Home</a><br>' +
	'<a href="/create">Create</a><br>' +
	'<a href="/about">About</a><br>' +
	'<br><br>' + @info + 
	'</body></html>'
end


#ABOUT section
get '/about' do
	'<html><body>
	<b>Menu</b><br>
	<a href="/">Home</a><br>
	<a href="/create">Create</a><br>
	<a href="/about">About</a><br><br><br>' +
	'<h2>About us</h2>
	<p>This wiki was created by </p>' + $myinfo + '
	<p>Staff ID: XXXXXXXX</p>' +
	'</body></html>'
end

#CREATE section
get '/create' do

	'<html><body>' +
	'<b>Menu</b><br>' +
	'<a href="/">Home</a><br>' +
	'<a href="/create">Create</a><br>' +
	'<a href="/about">About</a><br>' +
	'<a href="/edit">Edit</a><br>' +
	'<br><br>' +
	'<h2>This is your own personal create page!</h2> +
	<section id="add">' + $myinfo + '</section>' +
	'</body></html>'
	# '<html><body>
	# <b>Menu</b><br>
	# <a href="/">Home</a><br>
	# <a href="/create">Create</a><br>
	# <a href="/about">About</a><br><br><br>' +
	# '<h2>This is your own personal create page!</h2>
	# <section id="add">' + $myinfo + '</section>' +
	# '</body></html>'
end


#404 Use case
not_found do
	status 404
	redirect '/'
end 