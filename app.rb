require 'sinatra'
require 'slim'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

get('/')  do
  slim(:start)
end 

def connect_database(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
end

get("/users/register") do
  slim(:"users/register")
end

post("/users/users/register") do 
  session[:loggedin] = false
  username = params[:username]
  password = params[:password]
  email = params[:email]
  password_confirm = params[:password_confirm]

  if password != password_confirm
    session[:password_matcherrror] = true
  end

  if username == "" or password == "" or email == ""
    session[:failedreg] = true
    redirect("/users/register")
  else 
    session[:userkey] = username
    session[:passkey] = password
    session[:passkey2] = password_confirm
    session[:emailkey] = email

    password_digest = BCrypt::Password.create(password)
    db = connect_database("db/wspdatabase.db")
    db.execute("INSERT INTO User (username, password,role_id,email) VALUES (?,?,?,?)", username, password_digest,0,email)
    redirect("/")
  end
end

  get("/users/login") do
    slim(:"users/login")
  end

  post("/login") do 
    username = params[:username]
    password = params[:password]
    db = connect_database("db/wspdatabase.db")
    db.results_as_hash = true

    result = db.execute("SELECT * FROM User WHERE username = ?",username).first
    if result != nil
      password_table = result["password"]
      id = result["id"]

      if BCrypt::Password.new(password_table) == password
        session[:id] = id
        session[:username] = username
        session[:loggedin] = true
        redirect('/users/show_user')
      else
        session[:failedloggin] = true
        redirect('/users/login')
      end
    
    else
      session[:failedloggin] = true
      redirect('/users/login')
    end

  end

  get ('/posts/new') do
    slim(:"posts/new")
  end

  post ('/posts/new') do
    post_title = params[:post_title]
    post_category = params[:post_category]
    post_text = params[:post_text]

    db = connect_database("db/wspdatabase.db")
    db.results_as_hash = true
    db.execute("INSERT INTO Post (title, text,) VALUES (?,?)", post_title, post_text)
    redirect("/")



  end


  get("/user_logout") do
    session.destroy
    session[:loggedin] = false
    redirect('/')
  end



  get("/users/show_user") do
    slim(:"users/show_user")
  end













  