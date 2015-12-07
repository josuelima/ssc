module SSC
  module AWS
    class CLI_Interface
      class << self
        def ec2_instance_status id
          begin
            code = (JSON.parse `aws ec2 describe-instances --instance-id #{id}`)['Reservations'][0]['Instances'][0]['State']['Code']
            AWS::EC2_CONS::STATUS[code]
          rescue
            AWS::EC2_CONS::NOT_AVAILABLE
          end
        end

        def ec2_stop_instances ids
          `aws ec2 stop-instances --instance-ids #{ids.join(' ')}`
        end

        def ec2_start_instances ids
          `aws ec2 start-instances --instance-ids #{ids.join(' ')}`
        end

        def ecs_current_running_task cluster
          ecs_task_name cluster, (JSON.parse `aws ecs list-tasks --cluster #{cluster}`)['taskArns'][0].split('/').last
        end

        def ecs_task_name cluster, task
          (JSON.parse `aws ecs describe-tasks --tasks #{task} --cluster #{cluster}`)['tasks'][0]['taskDefinitionArn'].split('/').last
        end

        def ecs_run_task cluster, task_definition
          `aws ecs run-task --cluster #{cluster} --task-definition #{task_definition}`
        end
      end
    end
  end
end