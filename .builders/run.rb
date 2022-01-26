KManager.action :run do
  def on_action
    puts 'run away, run away'
  end
end

KManager.opts.app_name                    = 'RubyGem Generator'
KManager.opts.sleep                       = 2
KManager.opts.reboot_on_kill              = 0
KManager.opts.reboot_sleep                = 4
KManager.opts.exception_style             = :short
KManager.opts.show.time_taken             = true
KManager.opts.show.finished               = true
KManager.opts.show.finished_message       = 'FINISHED :)'

