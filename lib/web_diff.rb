# Load classes
require "web_diff/configuration"
require "web_diff/selenium_handler"
require "web_diff/image_handler"
require "web_diff/gallery_creator"
require "web_diff/runner"

require "web_diff/version"

module WebDiff
    class << self
        def root
            File.expand_path('../..', __FILE__)
        end

        def run
            beginning_time = Time.now

            # Call "before" hook
            WebDiff.configuration.before_run

            begin
                runner = Runner.new
                runner.run
            ensure
                # Call "after" hook
                WebDiff.configuration.after_run
            end

            end_time = Time.now
            puts "Time elapsed: #{(end_time - beginning_time)} seconds"
        end
    end
end

# Load tasks
Dir[WebDiff.root + '/lib/tasks/*.rake'].each { |ext| load ext } if defined?(Rake)
