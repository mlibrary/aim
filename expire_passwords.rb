require_relative './lib/expire_passwords'
require 'optparse'


path = ''
OptionParser.new do |opts|
  opts.on("--path PATH") do |x|
    path = x
  end
end.parse!

if File.exists?(path)
  begin
    users = YAML.load_file(path)
  rescue
    abort "#{path} has invalid yaml" 
  else
    abort "file doesn't have array of users" unless users.class.to_s == 'Array'
    output = PasswordExpirer.new(users).run
    if output[:number_of_errors] == 0 
      exit 0
    else
       exit 1
    end
  end
else
  abort "#{path} doesn't exist"
end




