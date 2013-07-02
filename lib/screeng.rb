require 'fileutils'
require 'trollop'
require 'time'
require 'json'
require 'digest/md5'

require 'screeng/version'
require 'screeng/screen_group'
require 'screeng/runner'
require 'screeng/parser'
require 'screeng/writer'

module Screeng
  class Error < StandardError; end
end
