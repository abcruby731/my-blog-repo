# myapp.rb
require "sinatra"
require "sinatra/activerecord"

set :database, "sqlite3:blog.db"

class Post < ActiveRecord::Base
    validates :title, presence: true, length: { minimum: 3 }
    validates :body, presence: true
end

class Myapp < Sinatra::Base
    register Sinatra::ActiveRecordExtension
end

helpers do
    def title
        if @title
            "#{@title} -- My Blog"
        else
            "My Blog"
        end
    end
    def pretty_date(time)
        time.strftime("%d %b %y")
    end
    def post_show_page?
        request.path_info =~ /\/posts\/\d+$/
    end
    def delete_post_button(post_id)
        erb:delete_post_button, locals: { post_id: post_id}
    end
end

get '/' do
    @posts = Post.order("created_at DESC")
    erb :"posts/index"
end

get '/posts/new' do
    @title = "New Post"
    @post = Post.new
    erb :"posts/new"
end

post '/posts' do
    @post = Post.new(params[:post])
    if @post.save
        redirect "posts/#{@post.id}"
    else
        erb :"posts/new"
    end
end

get '/posts/:id' do
    @post = Post.find(params[:id])
    @title = @post.title
    erb :"posts/show"
end

get '/posts/:id/edit' do
    @post = Post.find(params[:id])
    @title = "Edit Form"
    erb :"posts/edit"
end

put '/posts/:id' do
    @post = Post.find(params[:id])
    if
    @post.update_attributes(params[:post])
        redirect '/posts/#{@post.id}'
    else
        erb:'posts/edit'
    end
end

delete '/posts/:id' do
    @post = Post.find(params[:id]).destory
    redirect '/'
end

get '/about' do
    @title = "About Me"
    erb :"pages/about"
end
get "/upload" do
  erb :"posts/upload"
end
 
post '/save_image' do
  
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
 
  File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  
  erb :"posts/show_image"
end
