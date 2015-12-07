module SSC
  class Scheduler

    DEFAULT_DESCRIPTOR = '/data/ssc/instances-descriptor.json'

    def initialize descriptor = nil
      @source    = descriptor || DEFAULT_DESCRIPTOR
      @instances = JSON.parse(File.read @source)
      self
    end

    def start_instances instances, opts = {}
      stopped = instances_by_status AWS::EC2_CONS::STOPPED
      stopped.select! { |_, meta| instances.include? meta['name'] } unless instances.empty?

      # Remove timeouts if run by cron
      remove_timeout! @instances.keys if opts[:cron] == true

      unless stopped.empty?
        # Add timeout if start is temporary
        add_timeout!(stopped.keys, opts[:timeout] * 3600) unless opts[:timeout].nil?

        AWS::CLI_Interface.ec2_start_instances stopped.keys
        restart_ecs_tasks stopped.select { |_, meta| meta.has_key? 'ecs' }
      end
    end

    def stop_instances instances, opts = {}
      running = instances_by_status AWS::EC2_CONS::RUNNING
      running.select! { |_, meta| instances.include? meta['name'] } unless instances.empty?

      # Select only instances with timeout
      running.select! { |_, meta| meta.has_key? 'timeout' } if opts[:cron] == true

      # Don't stop instances with valid timeout
      running.delete_if { |_, meta| meta.has_key? 'timeout' && Time.now < Time.parse(meta['timetout']) }

      unless running.empty?
        save_current_running_tasks! running.select { |_, meta| meta.has_key? 'ecs' }
        remove_timeout! running.keys
        AWS::CLI_Interface.ec2_stop_instances running.keys
      end
    end

    # Print instance status directly to the console
    def instances_status
      @instances.each do |i_id, meta|
        status = AWS::CLI_Interface.ec2_instance_status(i_id)
        output = "#{meta['name']} (#{i_id})".colorize(color: :white, background: :blue) +
                 " : ".colorize(:yellow) +
                 "#{status[:label]}".colorize(color: :white, background: status[:color])
        puts output
      end
    end

    private

    def instances_by_status status
      @instances.select { |i_id, _| AWS::CLI_Interface.ec2_instance_status(i_id) == status }
    end

    # Save the current running task.
    # This way we know which task to start when the instance is started again
    # Applies only for insntances running with ECS
    def save_current_running_tasks! instances
      instances.each do |i_id, meta|
        current_task = AWS::CLI_Interface.ecs_current_running_task meta['ecs']['cluster']
        @instances[i_id]['ecs']['task'] = current_task
      end

      File.write @source, @instances.to_json
    end

    # Add timeout
    def add_timeout! i_ids, timeout
      i_ids.each { |i_id| @instances[i_id]['timeout'] = timeout }
      File.write @source, @instances.to_json
    end

    # Remove timeouts from insntaces to be stopped
    def remove_timeout! i_ids
      i_ids.each { |i_id| @instances[i_id].delete 'timeout' }
      File.write @source, @instances.to_json
    end

    # Run ECS tasks for instances running docker with AWS ECS
    # AWS instance start can take a few minutes, if the instance state is not in running state
    # a few more tries will be done.
    #
    # * The ecs-agent must be running on the instance
    def restart_ecs_tasks instances
      instances.each do |i_id, meta|
        tries = 0
        begin
          tries = tries + 1
          fail 'not running' unless AWS::CLI_Interface.ec2_instance_status(i_id) == AWS::EC2_CONS::RUNNING
          AWS::CLI_Interface.ecs_run_task meta['ecs']['cluster'], meta['ecs']['task']
        rescue
          sleep(50) # wait 50 seconds until try again
          retry if tries < 5
        end
      end
    end
  end
end
