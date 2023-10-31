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
  def html_escape(string)
    CGI.escapeHTML(string)
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

def store_data
  current_data = File.empty?('model/data.json') ? {} : @memos
  new_memo = prepare_new_memo
  updated_data = create_data(current_data, new_memo)
  write_data(updated_data)
end

def prepare_new_memo
  new_memo = { title: params[:title], content: params[:content] }
  handle_empty_fields(new_memo)
end

def handle_empty_fields(new_memo)
  # メモ生成時にタイトルと内容が入力されていなかった場合の対処
  if [:title, :content].all? { new_memo[_1].empty? }
    redirect to('/')
  elsif new_memo[:title].empty?
    new_memo[:title] = '無題'
  end
  new_memo
end

def create_data(current_data, new_memo)
  # 生成されたメモに連番のIDを与える
  next_id = current_data.keys.map(&:to_i).max + 1 if current_data.any?
  id = next_id || 1
  current_data[id] = new_memo
  current_data
end

post '/memos' do
  store_data
  redirect to('/')
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @id = params[:id]
  @memo = @memos[@id]
  return erb :error if !@memo

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
  @memo = @memos[@id]
  return erb :error if !@memo

  erb :edit
end

patch '/memos/:id' do
  id = params[:id]
  memo = @memos[id]
  memo['title'] = params[:title]
  memo['content'] = params[:content]
  write_data(@memos)
  redirect to('/')
end

not_found do
  erb :error
end
