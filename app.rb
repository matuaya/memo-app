# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'pg'

conn = PG.connect(dbname: 'memo_app')
conn.exec('CREATE TABLE IF NOT EXISTS memos(id serial PRIMARY KEY, title text, content text)')

helpers do
  def html_escape(string)
    CGI.escapeHTML(string)
  end
end

get '/' do
  result = conn.exec('SELECT * FROM memos ORDER BY id')
  @memos = result.map { |table_row| table_row }
  erb :index
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  if [title, content].all?(&:empty?)
    redirect to('/')
  elsif title.empty?
    title = '無題'
  end
  sql = 'INSERT INTO memos(title, content) VALUES ($1, $2)'
  conn.exec_params(sql, [title, content])
  redirect to('/')
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  memo = conn.exec("SELECT * FROM memos WHERE id = '#{params[:id]}'")
  @memo = memo[0]

  return erb :error if !@memo

  erb :show
end

delete '/memos/:id' do
  conn.exec("DELETE FROM memos WHERE id = #{params[:id]}")

  redirect to('/')
end

get '/memos/edit/:id' do
  memo = conn.exec("SELECT * FROM memos WHERE id = '#{params[:id]}'")
  @memo = memo[0]

  return erb :error if !@memo

  erb :edit
end

patch '/memos/:id' do
  sql = "UPDATE memos SET(title, content) = ($1, $2) WHERE id = '#{params[:id]}'"
  conn.exec_params(sql, [params[:title], params[:content]])

  redirect to('/')
end

not_found do
  erb :error
end
