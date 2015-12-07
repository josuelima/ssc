module SSC
  module AWS
    module EC2_CONS
      STATUS = {
        0  => {label: 'Pending',       color: :orange},
        16 => {label: 'Running',       color: :green},
        32 => {label: 'Shtting Down',  color: :red},
        48 => {label: 'Terminated',    color: :red},
        64 => {label: 'Stopping' ,     color: :red},
        80 => {label: 'Stopped',       color: :red},
        90 => {label: 'Not Available', color: :red}
      }

      PENDING       = STATUS[0]
      RUNNING       = STATUS[16]
      SHUTTING_DOWN = STATUS[32]
      TERMINATED    = STATUS[48]
      STOPPING      = STATUS[64]
      STOPPED       = STATUS[80]
      NOT_AVAILABLE = STATUS[90]
    end
  end
end
