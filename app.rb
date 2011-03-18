require 'rubygems'
require 'sinatra'
require 'oauth'
require 'json'
require 'haml'
require 'yaml'

enable  :sessions, :logging

MISO_CONSUMER_KEY = ENV['MISO_CONSUMER_KEY']
MISO_CONSUMER_SECRET = ENV['MISO_CONSUMER_SECRET']
MISO_SITE = ENV['MISO_SITE']
MISO_CALLBACK_URL=ENV['MISO_CALLBACK_URL']

# Generate a consumer key and secret by creating a new application at:
# http://gomiso.com/oauth_clients/new


# Helper method to create an OAuth-signed request
def get_json_hash(url)
  JSON.parse(@access_token.get(url).body)
end

# Helper method to create an OAuth consumer, which can generate request and access tokens.
def consumer
  puts MISO_SITE
  @consumer = OAuth::Consumer.new MISO_CONSUMER_KEY, MISO_CONSUMER_SECRET, :site => MISO_SITE
end

# Simple landing page with sign in prompt.
get "/" do
  "Click <a href='/oauth/connect'>here</a> to connect to Miso API through OAuth"
end

# Generates and stores request token and redirects to Miso sign-in page.
get "/oauth/connect" do
  @request_token = consumer.get_request_token :oauth_callback => MISO_CALLBACK_URL
  session[:request_token], session[:request_token_secret] = @request_token.token, @request_token.secret
  redirect @request_token.authorize_url
end

# Upon successful Miso sign-in, request an access token using the original request token.
get "/oauth/callback" do
  @request_token = OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
  @access_token = @request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  session[:access_token], session[:access_secret] = @access_token.token, @access_token.secret
  redirect "/api/test"
end

# Use the access token to access a user's checkins and basic information.
get "/oauth/user" do
  @access_token = OAuth::AccessToken.new(consumer, session[:access_token], session[:access_secret])
  user = get_json_hash("/api/oauth/v1/users/show.json")['user']
  checkin = get_json_hash("/api/oauth/v1/checkins.json?count=1&user_id=#{user['id']}").first['checkin']

  html = "<img src='#{user['profile_image_url']}' /><br/>#{user['full_name']} (#{user['username']})<br/>"
  html << "Last checked into: #{checkin['media_title']}<br/> <img src='#{checkin['media_poster_url']}' />"
end


get "/api/test" do
  @access_token = OAuth::AccessToken.new(consumer, session[:access_token], session[:access_secret])
  haml :tool
end

get %r{\/proxy\/([\w\/\.]+)$} do
  @access_token = OAuth::AccessToken.new(consumer, session[:access_token], session[:access_secret])
  request_pms = request.env["rack.request.query_hash"]
  request_ps  = request.env["rack.request.query_string"]
  endpoint = params[:captures].first.to_s
  url ="/api/#{endpoint}"
  full_url = [url,request_ps].join("?")
  puts request_pms.inspect
  if request_pms["method"] == "GET"
    @access_token.get(full_url).body
  elsif request_pms["method"] == "POST"
    @access_token.post(url, request_pms).body
  elsif request_pms["method"] == "PUT"
    @access_token.put(url, request_pms).body
  elsif request_pms["method"] == "DELETE"
    @access_token.delete(full_url).body
  end
end
