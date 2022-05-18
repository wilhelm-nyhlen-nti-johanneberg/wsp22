require 'sinatra'
require 'slim'
require 'byebug'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

#include Model

def connect_database(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
end


get('/')  do
  db = connect_database("db/wspdatabase.db")
  posts_data = db.execute("SELECT * FROM Post")
  slim(:"start",locals:{posts:posts_data})
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

  if (username == "" || password == "" || email == "")
    session[:failedreg] = true
    redirect("/users/register")
  
  elsif (password != password_confirm)
    session[:password_matcherrror] = true
    redirect("/users/register")

  else 
    session[:userkey] = username
    session[:passkey] = password
    session[:passkey2] = password_confirm
    session[:emailkey] = email

    password_digest = BCrypt::Password.create(password)
    db = connect_database("db/wspdatabase.db")
    username_check = db.execute("SELECT 1 FROM User WHERE username = ?;",username).first
    
    if (username_check == nil)
      db.execute("INSERT INTO User (username, password,role_id,email) VALUES (?,?,?,?)", username, password_digest,0,email)
      session[:sucessreg] = true
    elsif 
      session[:username_taken] = true
    end
    
    redirect("/users/register")
      
  end
end

  get("/users/login") do
    slim(:"users/login")
  end

  post("/login") do 
    username = params[:username]
    password = params[:password]
    db = connect_database("db/wspdatabase.db")

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

  get('/posts/new') do
    slim(:"posts/new")
  end

  post('/posts/new') do
    post_title = params[:post_title]
    category_id = params[:post_category]
    post_text = params[:post_text]
    username = session[:username]

    db = connect_database("db/wspdatabase.db")
    user_id = db.execute("SELECT id FROM User WHERE username = ?",username).first["id"]
    db.execute("INSERT INTO Post (title,post_text,user_id,category_id) VALUES (?,?,?,?)", post_title,post_text,user_id,category_id)
    redirect("/posts/new")
  end


  get("/user_logout") do
    session.destroy
    session[:loggedin] = false
    redirect('/')
  end


  get("/users/show_user") do
    if session[:loggedin] == true
      username = session[:username]
      db = connect_database("db/wspdatabase.db")
      user_desc = db.execute("SELECT description FROM User WHERE username = ?",username).first["description"]
      user_id = db.execute("SELECT id FROM USER WHERE username = ?", username).first["id"]
      user_posts = db.execute("SELECT * FROM Post WHERE user_id = ?",user_id)
      slim(:"users/show_user", locals:{user_desc:user_desc,user_posts:user_posts})
    else
      slim(:"users/show_user", locals:{user_desc:user_desc})
    end 
  end

  post("/users/show_user") do
    newuser_desc = params[:newuser_desc]
    username = session[:username]
    db = connect_database("db/wspdatabase.db")
    db.execute("UPDATE User SET description = ? WHERE username = ?;)", newuser_desc, username)
    redirect('/users/show_user')
  end



  post("/post/:id/delete") do
    post_id = params[:id]
    username = session[:username]
    db = connect_database("db/wspdatabase.db")
    db.execute("DELETE FROM Post WHERE id = ?", post_id)
    redirect('/users/show_user')

  end




  get('/posts/index') do
    db = connect_database("db/wspdatabase.db")
    posts_data = db.execute("SELECT * FROM Post INNER JOIN User ON Post.user_id = User.id") 
    slim(:"posts/index",locals:{posts:posts_data})
  end


  /post/#{el["id"]}/delete













  