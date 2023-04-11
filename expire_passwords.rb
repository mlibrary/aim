require_relative "./lib/expire_passwords"
output = PasswordExpirer.new.run
if output[:number_of_errors] == 0
  exit 0
else
  exit 1
end
