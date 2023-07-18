# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "thor"
require "aim/student_workers"
require "aim/hathi_trust"
require "aim/sms"
require "aim/cli"

module AIM
  class Error < StandardError; end
  # Your code goes here...
end
