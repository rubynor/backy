require "thor"

module Backy
  class CLI < Thor
    desc "backup", "Perform a backup operation using the current configuration settings"
    def backup
      result = Backy::PgDump.new.call
      puts "Backup created: #{result}"
    end

    desc "push", "Push the local dump to a remote storage location"
    def push
      file_name = Backy::List.new.select(&:local?).last
      Backy::S3Save.new(file_name: file_name).call
      File.delete(file_name) if File.exist?(file_name)
      puts "Backup pushed to remote storage: #{file_name}"
    end

    desc "upload FILE_NAME", "Upload a specified backup file to the remote storage"
    def upload(file_name)
      if file_name.nil? || !File.exist?(file_name)
        puts "Please set DUMP_FILE env variable to the existing local file to save to S3"
        exit
      end

      Backy::S3Save.new(file_name: file_name).call
      puts "Backup uploaded to remote storage: #{file_name}"
    end

    desc "download FILE_NAME", "Download a specified backup file from the remote storage to the local system"
    def download(file_name)
      if file_name.nil? || File.exist?(file_name)
        puts "Please set DUMP_FILE env variable to the missing remote file to download"
        exit
      end

      Backy::S3Load.new(file_name: file_name).call
      puts "Backup downloaded from remote storage: #{file_name}"
    end

    desc "list", "Display a list of available backups, both locally and in remote storage"
    def list
      list = Backy::List.call
      list.each do |list_item|
        puts "#{list_item.local? ? "local" : "     "} #{list_item.remote? ? "remote" : "      "} : #{list_item.dump_file}"
      end

      if list.any?
        puts
        puts "To restore run backy:restore setting DUMP_FILE."
        puts "Example:"
        puts "  backy restore DUMP_FILE=#{list.last.dump_file}"
      end
    end

    desc "restore FILE_NAME", "Restore the database from the latest backup or a specified backup file"
    def restore(template_file_name)
      file_name = Backy::List.call.reverse.find { |list_item| list_item.dump_file.starts_with?(template_file_name) }&.dump_file if template_file_name.present?

      if file_name.nil?
        puts "Please set DUMP_FILE env variable to the local/S3 file (or prefix) to restore from."
        exit
      end

      Backy::PgRestore.new(file_name: load_from_s3_if_missing(file_name)).call
      puts "Database restored from #{file_name}"
    end

    no_commands do
      def load_from_s3_if_missing(file_name)
        Backy::S3Load.new(file_name: file_name).call
      end
    end
  end
end
