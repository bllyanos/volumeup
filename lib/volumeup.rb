require 'thor'
require 'docker'
require 'colorize'
require 'tty-progressbar'
require 'fileutils'
require 'time'

require_relative 'volumeup/version'
require_relative 'volumeup/backup_manager'
require_relative 'volumeup/restore_manager'
require_relative 'volumeup/cli'

module VolumeUp
  class Error < StandardError; end
  class VolumeNotFoundError < Error; end
  class BackupError < Error; end
  class RestoreError < Error; end
end
