# coding: utf-8

require 'bundler'
Bundler.require

key = YAML.load_file( 'config.yml' )

TweetStream.configure do |config|
	config.consumer_key = key[ "consumer_key" ]
	config.consumer_secret = key[ "consumer_secret" ]
	config.oauth_token = key[ "access_token" ]
	config.oauth_token_secret = key[ "access_token_secret" ]
	config.auth_method = :oauth
end

rest = Twitter::REST::Client.new do |config|
	config.consumer_key = key[ "consumer_key" ]
	config.consumer_secret = key[ "consumer_secret" ]
	config.access_token = key[ "access_token" ]
	config.access_token_secret = key[ "access_token_secret" ]
end

EM.run do
	client = TweetStream::Client.new

	client.track( "@delaytweet" ) do |status|
		sec = status.text.scan( /\d+s/ )
		if sec.count == 1
			sec = sec[0].chop.to_i
		else
			sec = 0
		end
		minute = status.text.scan( /\d+m/ )
		if minute.count == 1
			sec += minute[0].chop.to_i * 60
		end
		
		if sec != 0
			EM::Timer.new( sec ) do
				rest.update( "@#{status.user.screen_name} 時間だよ" )
			end
		end
	end
end
