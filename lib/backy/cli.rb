require "thor"

module Backy
  class CLI < Thor
    desc "backup", "Perform a backup operation using the current configuration settings"
    def backup
      result = Backy::PgDump.new.call
      puts "Backup created: #{result}"
    end

    desc "restore FILE_NAME", "Restore the database from the latest backup or a specified backup file"
    def restore(file_name)
      Backy::PgRestore.new(file_name: file_name).call
      puts "Database restored from #{file_name}"
    end

    desc "push", "Push the local backup to a remote storage location"
    def push
      latest_backup = Backy::List.new.select(&:local?).last
      return puts "No local backups found" unless latest_backup

      Backy::S3Save.new(file_name: latest_backup.dump_file).call
      puts "Backup pushed to remote storage: #{latest_backup.dump_file}"
    end

    desc "upload FILE_NAME", "Upload a specified backup file to the remote storage"
    def upload(file_name)
      Backy::S3Save.new(file_name: file_name).call
      puts "Backup uploaded to remote storage: #{file_name}"
    end

    desc "download FILE_NAME", "Download a specified backup file from the remote storage to the local system"
    def download(file_name)
      Backy::S3Load.new(file_name: file_name).call
      puts "Backup downloaded from remote storage: #{file_name}"
    end

    desc "list", "Display a list of available backups, both locally and in remote storage"
    def list
      backups = Backy::List.new.call

      backups.each do |backup|
        location = []
        location << "Local" if backup.local?
        location << "Remote" if backup.remote?
        puts "#{backup.dump_file} (#{location.join(", ")})"
      end
    end
  end
end
