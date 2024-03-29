class User < ActiveRecord::Base
  attr_accessible :name, :oauth_expires_at, :oauth_token, :provider, :uid

  def self.from_omniauth(auth)
  	where(auth.slice(:provider, :uid)).first_or_initialize.tap  do |user|
  		user.provider = auth.provider
  		user.uid = auth.uid
  		user.name = auth.info.name
  		user.oauth_token = auth.credentials.token
  		user.oauth_expires_at = Time.at(auth.credentials.expires_at)
  		user.save!
  	end
  end

  def facebook
  	@facebook ||= Koala::Facebook::API.new(oauth_token)
 	  block_given? ? yield(@facebook) : @facebook
		rescue Koala::Facebook::APIError => e
  		logger.info e.to_s
  		nil # or consider a custom null object
	end


  def post_wall(message="Having a great time with my buddies!")
  	facebook { |fb| fb.put_wall_post message }
  end

  #Default check-in to University of Champagne, IL
  def check_in (idstring='163536409904')
  facebook { |fb| fb.put_wall_post("Having a great time!", :place => idstring)}
  end
end
