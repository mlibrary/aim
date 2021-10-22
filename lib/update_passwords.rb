require_relative './xkcd.rb'
require 'csv'
require 'ostruct'
require 'byebug'

class XkcdPasswordGenerator
  def camel_case
    generate(words: 4, separator: nil).map{|x|x.capitalize}.join('')
  end
end

class PasswordUpdater
  def initialize(csv_string)
    @users = CSV.parse(csv_string).map{|row| row[0]}
  end
  def run(generator = XkcdPasswordGenerator.new(parse('./lib/dictionary.csv',delimiter: ',')))
    updated_users = []
    not_updated_users = []
    @users.each do |user|
      password = generator.camel_case
      response = update_password(user, password)
      if response.code == 200
        updated_users.push([user,password])
      else
        not_updated_users.push([user,password])
      end
    end
    CSV.open('updated_users.csv', 'w') do |csv|
      updated_users.each do |user|
        csv << user
      end
    end
    CSV.open('not_updated_users.csv', 'w') do |csv|
      not_updated_users.each do |user|
        csv << user
      end
    end
  end
  private
  def update_password(user, password)
    ::OpenStruct.new(code: 200)
  end
end

PasswordUpdater.new("user1\nuser2\nuser3").run
