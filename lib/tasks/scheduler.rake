desc "Rake task to record data"
task :record_data => :environment do
  puts "#{Time.now}"
  puts "Recording data..."
  Log.record
  puts "Success!"
end
