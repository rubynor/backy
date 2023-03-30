require "thor"

module Backy
  class CLI < Thor
    desc "backup", "Perform a backup operation using the current configuration settings"
    def backup
      puts "Backup"
    end

    desc "restore FILE_NAME", "Restore the database from the latest backup or a specified backup file"
    def restore(file_name)
      puts "Restore #{file_name}"
    end

    desc "push", "Push the local backup to a remote storage location"
    def push
      puts "Push"
    end

    desc "upload FILE_NAME", "Upload a specified backup file to the remote storage"
    def upload(file_name)
      puts "Upload #{file_name}"
    end

    desc "download FILE_NAME", "Download a specified backup file from the remote storage to the local system"
    def download(file_name)
      puts "Download #{file_name}"
    end

    desc "list", "Display a list of available backups, both locally and in remote storage"
    def list
      puts "List of backups"
    end
  end
end
