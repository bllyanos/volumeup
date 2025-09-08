module VolumeUp
  class RestoreManager
    def initialize
      @docker = Docker
    end

    def restore_volume(backup_file, volume_name, force = false)
      validate_backup_file(backup_file)
      validate_volume_does_not_exist(volume_name) unless force
      
      puts "Starting restore of volume '#{volume_name}' from '#{backup_file}'".colorize(:blue)
      
      begin
        # Create the target volume
        create_volume(volume_name)
        
        # Create a temporary container to restore the volume
        container = create_temp_container(volume_name)
        
        # Restore the backup
        restore_backup(container, backup_file)
        
        puts "Restore completed successfully!".colorize(:green)
        puts "Volume '#{volume_name}' has been restored".colorize(:green)
        
      ensure
        cleanup_temp_container(container) if container
      end
    end

    private

    def validate_backup_file(backup_file)
      unless File.exist?(backup_file)
        raise RestoreError, "Backup file '#{backup_file}' not found"
      end
      
      unless File.readable?(backup_file)
        raise RestoreError, "Backup file '#{backup_file}' is not readable"
      end
    end

    def validate_volume_does_not_exist(volume_name)
      volumes = Docker::Volume.all
      if volumes.any? { |v| v.info['Name'] == volume_name }
        raise RestoreError, "Volume '#{volume_name}' already exists. Use --force to overwrite."
      end
    end

    def create_volume(volume_name)
      puts "Creating volume '#{volume_name}'...".colorize(:yellow)
      
      begin
        Docker::Volume.create(volume_name)
      rescue => e
        raise RestoreError, "Failed to create volume: #{e.message}"
      end
    end

    def create_temp_container(volume_name)
      puts "Creating temporary container...".colorize(:yellow)
      
      # Use a minimal image that has tar
      image = 'alpine:latest'
      
      container = Docker::Container.create(
        'Image' => image,
        'Cmd' => ['sleep', '3600'], # Keep container running
        'Volumes' => { "/restore_volume" => {} },
        'HostConfig' => {
          'Binds' => ["#{volume_name}:/restore_volume"]
        }
      )
      
      container.start
      container
    end

    def restore_backup(container, backup_file)
      puts "Restoring backup archive...".colorize(:yellow)
      
      # Copy the backup file to the container
      copy_backup_to_container(container, backup_file)
      
      # Extract the backup
      extract_backup(container)
    end

    def copy_backup_to_container(container, backup_file)
      puts "Copying backup to container...".colorize(:yellow)
      
      # Use docker cp command to copy file to container
      system("docker cp #{backup_file} #{container.id}:/tmp/backup.tar.gz")
      
      # Verify the file was copied
      result = container.exec(['test', '-f', '/tmp/backup.tar.gz'])
      unless result[2] == 0
        raise RestoreError, "Failed to copy backup file to container"
      end
    end

    def extract_backup(container)
      puts "Extracting backup...".colorize(:yellow)
      
      # Clear the target directory and extract
      extract_command = "rm -rf /restore_volume/* && tar -xzf /tmp/backup.tar.gz -C /restore_volume"
      result = container.exec(['sh', '-c', extract_command])
      
      unless result[2] == 0
        raise RestoreError, "Failed to extract backup: #{result[1]}"
      end
      
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
