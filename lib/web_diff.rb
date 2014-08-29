# Dependencies
require "fog"

# Load classes
require "web_diff/configuration"
require "web_diff/selenium_handler"
require "web_diff/image_handler"
require "web_diff/gallery_creator"
require "web_diff/runner"

require "web_diff/version"

module WebDiff
    class << self
        @@path = nil

        def root
            File.expand_path('../..', __FILE__)
        end

        def path
            return @@path if @@path

            if WebDiff.configuration.remote
                @@path = WebDiff.configuration.remote_path
            elsif Dir.exists?("/tmp/shots")
                @@path = FileUtils.mkdir("/tmp/shots/#{Time.now.to_i}").join('')
            else
                FileUtils.mkdir("/tmp/shots")
                @@path = FileUtils.mkdir("/tmp/shots/#{Time.now.to_i}").join('')
            end

            return @@path
        end

        def fog
            return Fog::Storage.new({
                :provider                 => 'AWS',
                :aws_access_key_id        => WebDiff.configuration.aws_key,
                :aws_secret_access_key    => WebDiff.configuration.aws_secret
            })
        end

        def run
            beginning_time = Time.now

            begin
                # Call "before" hook
                WebDiff.configuration.before_run

                runner = Runner.new
                runner.run
            ensure
                # Call "after" hook
                WebDiff.configuration.after_run
            end

            end_time = Time.now
            puts "Time elapsed: #{(end_time - beginning_time)} seconds"
        end

        def make_gallery(path = nil)
            puts "Creating gallery..."
            begin
                # Call "before" hook
                WebDiff.configuration.before_gallery

                if WebDiff.configuration.remote
                    gallery_creator = GalleryCreator.new
                    gallery_creator.create_gallery(WebDiff.configuration.remote_path)
                else
                    gallery_creator = GalleryCreator.new
                    gallery_creator.create_gallery(path)
                end
            ensure
                # Call "after" hook
                WebDiff.configuration.after_gallery
            end
        end
    end
end

# Load tasks
Dir[WebDiff.root + '/lib/tasks/*.rake'].each { |ext| load ext } if defined?(Rake)
