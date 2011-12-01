require 'rubygems'
require 'oauth'
require 'yaml'
require 'json'

# Convert this to a YAML file for your rails app, and load your configuration in an 
# environment-specific way, eg YAML.load_file('config/oauth.yml')[Rails.env]
config = YAML.load(<<EOS
linkedin-example:
  api_host: https://api.linkedin.com
  request_token_path: /uas/oauth/requestToken
  access_token_path: /uas/oauth/accessToken
  authorize_path: /uas/oauth/authorize
  consumer_key: 'f4g4x7zkfzq7'
  consumer_secret: 'Oo0RZbH1aA8GdIFr'
EOS
)

oauth_options = config['linkedin-example']

# Set up LinkedIn specific OAuth API endpoints
consumer_options = { :site => oauth_options['api_host'],
                     :authorize_path => oauth_options['authorize_path'],
                     :request_token_path => oauth_options['request_token_path'],
                     :access_token_path => oauth_options['access_token_path'] }

consumer = OAuth::Consumer.new(oauth_options['consumer_key'], oauth_options['consumer_secret'], consumer_options)

# Pass the access token and secret on the command line to re-run without having to request the access token every time
if ARGV[0] && ARGV[1] 
  # Go straight to the access token (no need to do the oauth-dance if you've already got it)
  access_token = OAuth::AccessToken.new(consumer, ARGV[0], ARGV[1])
else
  # Fetch a new access token and secret from the command line
  request_token = consumer.get_request_token
  puts "Copy and paste the following URL in your browser:"
  puts "\t#{request_token.authorize_url}"
  puts "When you sign in, copy and paste the oauth verifier here:"
  verifier = $stdin.gets.strip
  access_token = request_token.get_access_token(:oauth_verifier => verifier)

  # Print out the token and secret so the script can be used like linkedin_oauth.rb [access-token] [access-token-secret]
  puts "Access Token: #{access_token.token}"
  puts "Access Token Secret: #{access_token.secret}"
end

# Pick some fields
fields = ['first-name', 'last-name', 'headline', 'industry', 'num-connections'].join(',')
# Make a request for JSON data
json_txt = access_token.get("/v1/people/~:(#{fields})", 'x-li-format' => 'json').body
profile = JSON.parse(json_txt)
puts "Profile data:"
puts JSON.pretty_generate(profile)

