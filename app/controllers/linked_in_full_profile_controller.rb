class LinkedInFullProfileController < ApplicationController

def index
  # Set up LinkedIn specific OAuth API endpoints
  consumer_options = { :site => "https://api.linkedin.com",
                       :authorize_path => "/uas/oauth/requestToken",
                       :request_token_path => "/uas/oauth/accessToken",
                       :access_token_path => "/uas/oauth/authorize" }
  
  consumer_key = "f4g4x7zkfzq7"
  consumer_secret = "Oo0RZbH1aA8GdIFr"
  oaut_token = "7dbf06a0-cb01-4e67-936c-b31ab85d5003"
  oauth_secret = "f001ee6e-d7b5-4d35-bba7-31d4b3b6a64d"
  # get the consumer                         
  consumer = OAuth::Consumer.new(consumer_key, consumer_secret, consumer_options)
  
  access_token = OAuth::AccessToken.new(consumer, oaut_token, oauth_secret)
  # Pick some fields
  profile_base_fields = ['first-name', 'last-name', 'headline', 'industry', 'num-connections'].join(',')

  # Make a request for JSON profile data
  profile_base_json_txt = access_token.get("/v1/people/~:(#{profile_base_fields})", 'x-li-format' => 'json').body
  @profile = JSON.parse(profile_base_json_txt)
  
  connection_base_fields = ['id','auth-token','first-name','last-name','headline','email-address','current-status'].join(',')
  
  connections_json_txt = access_token.get("/v1/people/~:(connections:(#{connection_base_fields}))", 'x-li-format' => 'json').body
  @connections = JSON.parse(connections_json_txt)
  
end

end
