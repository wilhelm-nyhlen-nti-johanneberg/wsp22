require 'sinatra'
require 'slim'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions



def connect_database(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
end

get("/views/register") do
  slim(:"views/register")
end

post("/views/register") do 
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    db = SQLite3::Database.new("db/wspdatabase.db")
    db.execute("INSERT INTO User (user_name, password) VALUES (?,?)", username, password)
    redirect("/")
  else 
    p "Passwords did not match. Please try again."

  end

end



get('/')  do
    slim(:posts)
end 


  