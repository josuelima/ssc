require 'optparse'

module SSC
  class Console
    def initialize args
      Logging.log "Starging SSC with #{args}"
      parse args
    end

    private

    def parse args
      exec = {}

      opt_parser = OptionParser.new do |opts|
        # Stop all instances on descriptor file
        # ssc --stop
        #
        # Stop specific instance
        # ssc --stop s-database-1
        #
        # Stop list of insnateces
        # ssc --stop s-database-1,s-database-2,s-enterprise-1
        opts.on('--stop [INSTANCES]', Array, 'Stop instances') do |instances|
          exec[:command]   = :stop
          exec[:instances] = instances || []
        end

        # To be used along with --stopped or --start
        # Stop: Stop instances with timeout expired
        # Start: Remove timeout from instances
        #
        # ssc --stop --cron
        # ssc --start --cron
        opts.on('--cron', 'Stop timedout instances/Start: Remove timeout from instances') do
          exec[:cron] = true
        end

        # Start all instances on descriptor file
        # ssc --start
        #
        # Start specific instance
        # ssc --start s-database-1
        #
        # Start list of insnateces
        # ssc --start s-database-1,s-database-2,s-enterprise-1
        opts.on('--start [INSTANCES]', Array, 'Start instances') do |instances|
          exec[:command]   = :start
          exec[:instances] = instances || []
        end

        # To be used along with --start
        # Will temporary start a stopped instance
        #
        # ssc --start s-enterprise-1 --for 1
        opts.on('--for HOURS', Integer, 'Temporary start instances') do |time|
          exec[:for] = time
        end

        # List status of all instances on descriptor file
        # ssc --status
        opts.on('--status', 'Stop all instance(s)') do
          exec[:command] = :status
        end
      end

      opt_parser.parse! args

      if exec[:command] == :stop
        Logging.log 'Stopping instances'.colorize(:blue)
        Scheduler.new.stop_instances exec[:instances], {cron: exec[:cron]}
      elsif exec[:command] == :start
        Logging.log 'Starting instances'.colorize(:blue)
        Scheduler.new.start_instances exec[:instances], {cron: exec[:cron], timeout: exec[:for]}
      elsif exec[:command] == :status
        Scheduler.new.instances_status
      else
        puts 'No valid option provided'
      end

      Logging.log 'Process complete'.colorize(:green)
    end
  end
end
