# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

before do
  File.open('model/data.json', 'r') do |file|
    file_contents = file.read
    @memos = JSON.parse(file_contents) unless file_contents.empty?
  end
end

helpers do
  def html_escape
    @escaped_title = CGI.escapeHTML(params['title']) if params['title']
    @escaped_content = CGI.escapeHTML(params['content']) if params['content']
  end

  def write_data(memos)
    File.open('model/data.json', 'w') do |file|
      file.write(JSON.dump(memos))
    end
  end
end

get '/' do
  erb :index
end

post '/memos' do
  def store_data
    current_data = File.empty?('model/data.json') ? {} : @memos
    new_memo = prepare_new_memo
    updated_data = create_data(current_data, new_memo)
    write_data(updated_data)
  end

  def prepare_new_memo
    # HTMLエスケープ処理をしてメモを生成、そしてそのメモにタイトルと内容が入力されていなかった場合の対処
    html_escape
    new_memo = { title: @escaped_title, content: @escaped_content }
    handle_empty_fields(new_memo)
  end

  def handle_empty_fields(new_memo)
    # メモ生成時にタイトルと内容が入力されていなかった場合の対処
    if new_memo[:title].empty? && new_memo[:content].empty?
      redirect to('/')
    elsif new_memo[:title].empty?
      new_memo[:title] = '無題'
    end
    new_memo
  end

  def create_data(current_data, new_memo)
    # 生成されたメモに連番のIDを与える
    if current_data.empty?
      current_data[1] = new_memo
    else
      next_id = current_data.keys.map(&:to_i).max + 1
      current_data[next_id] = new_memo
    end
    current_data
  end

  store_data
  redirect to('/')
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @id = params[:id]
  @title = @memos[@id]['title']
  @content = @memos[@id]['content']
  erb :show
end

delete '/memos/:id' do
  id = params[:id]
  @memos.delete(id)
  write_data(@memos)
  redirect to('/')
end

get '/memos/edit/:id' do
  @id = params[:id]
  @title = @memos[@id]['title']
  @content = @memos[@id]['content']
  erb :edit
end

patch '/memos/:id' do
  html_escape
  id = params[:id]
  memo = @memos[id]
  memo['title'] = @escaped_title
  memo['content'] = @escaped_content
  write_data(@memos)
  redirect to('/')
end

get '/*' do
  halt erb(:error)
end
