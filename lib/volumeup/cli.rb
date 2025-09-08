module VolumeUp
  class CLI < Thor
    include Thor::Actions

    desc "backup VOLUME_NAME BACKUP_PATH", "Backup a Docker volume to a file"
    option :name, aliases: :n, desc: "Custom name for the backup file"
    option :verbose, aliases: :v, type: :boolean, desc: "Enable verbose output"
    
    def backup(volume_name, backup_path)
      begin
        manager = BackupManager.new
        manager.backup_volume(volume_name, backup_path, options[:name])
      rescue VolumeUp::Error => e
        say e.message, :red
        exit 1
      rescue => e
        say "Unexpected error: #{e.message}", :red
        exit 1
      end
    end

    desc "restore BACKUP_FILE VOLUME_NAME", "Restore a Docker volume from a backup file"
    option :force, aliases: :f, type: :boolean, desc: "Force restore even if volume exists"
    option :verbose, aliases: :v, type: :boolean, desc: "Enable verbose output"
    
    def restore(backup_file, volume_name)
      begin
        manager = RestoreManager.new
        manager.restore_volume(backup_file, volume_name, options[:force])
      rescue VolumeUp::Error => e
        say e.message, :red
        exit 1
      rescue => e
        say "Unexpected error: #{e.message}", :red
        exit 1
      end
    end

    desc "list", "List manually created Docker volumes"
    option :all, aliases: :a, type: :boolean, desc: "Show all volumes including auto-generated ones"
    option :verbose, aliases: :v, type: :boolean, desc: "Enable verbose output"
    
    def list
      begin
        volumes = Docker::Volume.all
        
        if volumes.empty?
          say "No Docker volumes found", :yellow
          return
        end
        
        # Separate named volumes from auto-generated ones
        named_volumes = []
        auto_volumes = []
        
        volumes.each do |volume|
          info = volume.info
          name = info['Name']
          
          # Check if it's a named volume (not a long hex string)
          if name.length < 65 && !name.match?(/^[a-f0-9]{64}$/)
            named_volumes << volume
          else
            auto_volumes << volume
          end
        end
        
        say "\nDocker Volumes:", :blue
        say "=" * 60, :blue
        
        # Display named volumes (manually created)
        if named_volumes.any?
          say "\n📁 Manually Created Volumes:", :green
          say "-" * 40, :green
          
          named_volumes.each do |volume|
            info = volume.info
            name = info['Name']
            driver = info['Driver']
            
            say "  #{name}", :green
            say "    Driver: #{driver}"
            say ""
          end
          
          say "Total: #{named_volumes.length} manually created volumes", :green
        else
          say "\nNo manually created volumes found", :yellow
        end
        
        # Display auto-generated volumes only if --all flag is used
        if options[:all] && auto_volumes.any?
          say "\n🔧 Auto-generated Volumes (#{auto_volumes.length}):", :yellow
          say "-" * 40, :yellow
          
          auto_volumes.each do |volume|
            info = volume.info
            name = info['Name']
            driver = info['Driver']
            
            # Truncate long names for display
            display_name = name.length > 20 ? "#{name[0..16]}..." : name
            say "  #{display_name}", :yellow
            say "    Driver: #{driver}"
            say ""
          end
          
          say "Total: #{volumes.length} volumes (including #{auto_volumes.length} auto-generated)", :blue
        elsif !options[:all] && auto_volumes.any?
          say "\n💡 Use --all to show #{auto_volumes.length} auto-generated volumes", :blue
        end
        
      rescue => e
        say "Error listing volumes: #{e.message}", :red
        exit 1
      end
    end

    desc "version", "Show version information"
    def version
      say "VolumeUp v#{VolumeUp::VERSION}", :blue
    end

    private

    def self.exit_on_failure?
      true
    end
  end
end
