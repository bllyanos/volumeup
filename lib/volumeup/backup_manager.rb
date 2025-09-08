module VolumeUp
  class BackupManager
    def initialize
      @docker = Docker
    end

    def backup_volume(volume_name, backup_path, custom_name = nil)
      validate_volume_exists(volume_name)
      
      backup_filename = generate_backup_filename(volume_name, custom_name)
      full_backup_path = File.join(backup_path, backup_filename)
      
      puts "Starting backup of volume '#{volume_name}' to '#{full_backup_path}'".colorize(:blue)
      
      begin
        # Create a temporary container to access the volume
        container = create_temp_container(volume_name)
        
        # Create backup using tar
        create_backup(container, full_backup_path)
        
        puts "Backup completed successfully!".colorize(:green)
        puts "Backup file: #{full_backup_path}".colorize(:green)
        
      ensure
        cleanup_temp_container(container) if container
      end
    end

    private

    def validate_volume_exists(volume_name)
      volumes = Docker::Volume.all
      unless volumes.any? { |v| v.info['Name'] == volume_name }
        raise VolumeNotFoundError, "Volume '#{volume_name}' not found"
      end
    end

    def generate_backup_filename(volume_name, custom_name)
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      base_name = custom_name || volume_name
      "#{base_name}_#{timestamp}.tar.gz"
    end

    def create_temp_container(volume_name)
      puts "Creating temporary container...".colorize(:yellow)
      
      # Use a minimal image that has tar
      image = 'alpine:latest'
      
      container = Docker::Container.create(
        'Image' => image,
        'Cmd' => ['sleep', '3600'], # Keep container running
        'Volumes' => { "/backup_volume" => {} },
        'HostConfig' => {
          'Binds' => ["#{volume_name}:/backup_volume:ro"]
        }
      )
      
      container.start
      container
    end

    def create_backup(container, backup_path)
      puts "Creating backup archive...".colorize(:yellow)
      
      # Create the backup directory if it doesn't exist
      FileUtils.mkdir_p(File.dirname(backup_path))
      
      # Execute tar command in the container
      tar_command = "tar -czf /tmp/backup.tar.gz -C /backup_volume ."
      result = container.exec(['sh', '-c', tar_command])
      
      unless result[2] == 0
        raise BackupError, "Failed to create tar archive: #{result[1]}"
      end
      
      # Copy the backup file from container to host
      copy_backup_from_container(container, backup_path)
    end

    def copy_backup_from_container(container, backup_path)
      puts "Copying backup to host...".colorize(:yellow)
      
      # Use docker cp command to copy file from container
      temp_file = "/tmp/volumeup_backup_#{Time.now.to_i}.tar.gz"
      
      # Copy from container to host using docker cp
      system("docker cp #{container.id}:/tmp/backup.tar.gz #{temp_file}")
      
      unless File.exist?(temp_file)
        raise BackupError, "Failed to copy backup file from container"
      end
      
      # Move to final location
      FileUtils.mv(temp_file, backup_path)
      
      # Clean up the temporary tar file in the container
      container.exec(['rm', '/tmp/backup.tar.gz'])
    end

    def cleanup_temp_container(container)
      puts "Cleaning up temporary container...".colorize(:yellow)
      container.stop
      container.remove
    rescue => e
      puts "Warning: Failed to cleanup container: #{e.message}".colorize(:red)
    end
  end
end
