desc "Rake task to record data"
task :record_data => :environment do
  puts "#{Time.now}"
  puts "Recording data..."
  Location.stations.record_all
  puts "Success!"
  puts "Removing old data..."
  Log.destroy_old_ones
  puts "Done!"

  if Rails.env.production?  
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "0CoIUMZ2trqPqDN7MJOf33gFU"
      config.consumer_secret     = "NSvVNkgy2R7vBkWmGDXyWBivd3UzNl4Q1z2N1FgUu8r7OoLDXo"
      config.access_token        = "794134648154714112-iD7knJyZrQNeUnvGBpgJNITHutlMXqV"
      config.access_token_secret = "DeDK1UtXb0tZoam5qJrB8gUAkLdWE3v5NpVj2q816YTtT"
    end
    if tweet = Location.barcelona_tweet_update
      client.update(tweet)
    end
  end

end
