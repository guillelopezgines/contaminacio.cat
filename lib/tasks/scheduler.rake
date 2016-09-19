desc "Rake task to record data"
task :record_data => :environment do
  puts "#{Time.now}"
  puts "Recording data..."
  Location.record_all
  puts "Success!"
  puts "Removing old data..."
  Log.destroy_old_ones
  puts "Done!"
end
