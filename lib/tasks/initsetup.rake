require 'rake'
desc 'call in console with rakeloadtweetdb[searchterm]. NOTE: If DB locks, START SOLR. Command: bundle exec rake sunspot:solr:start'

task :loadtweetdb, [:mysearch] => [:environment] do |t, args|
  ENV["RAILS_ENV"] ||= "development"
  require File.dirname(__FILE__) + "/../../config/application"
  Rails.application.require_environment!

  Twitter.configure do |config|
    config.consumer_key       = 'QaMI7yj4FDxMPaFLTylx3w'
    config.consumer_secret    = 'SFeKrXMdONjVwtTAmSqWzsgV67gOBDYiDiij6oMqOw'
    config.oauth_token        = '54643263-c3D4hlanTeUr5u69wV5KtadwYNtvaTBgQAneIoIAD'
    config.oauth_token_secret = 'eHyhAeJ6LzbFaaCuRyyniZTepxiUjmElkk3R7YllCek'
  end

  Twitter.search(args[:mysearch], :count => 100).results.map do |status| 
    begin
      if status.user.lang == "en"
      unless Tweet.exists?(["guid = ? AND text = ?", status[:id].to_s, status.text])
        Tweet.create!({
        :text => status.text,
        :username => status.user.screen_name,
        :created_at => status.created_at,
        :lang => status.user.lang,
        :time_zone => status.user.time_zone,
        :guid => status[:id],
        :query => args[:mysearch],
        :avatar => status.profile_image_url,
        :name => status.user.name,
        :inserted_at => DateTime.now.to_date
        })
        puts "[#{status.user.screen_name}] #{status.text}"
      end # end unless
    end # end if
    rescue
     puts "Couldnt insert tweet. Possibly db lock error"
    end
  end
end
