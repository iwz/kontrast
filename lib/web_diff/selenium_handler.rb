require "selenium-webdriver"

module WebDiff
    class SeleniumHandler
        def initialize(path, config)
            @path, @config = path, config

            # Configure profile
            driver_name = @config['browser']['driver']
            profile = Selenium::WebDriver.const_get(driver_name.capitalize)::Profile.new
            @config['browser']['profile'].each do |option, value|
                profile[option] = value
            end

            # Get drivers with profile
            @driver = Selenium::WebDriver.for(driver_name.to_sym, profile: profile)
            @driver2 = Selenium::WebDriver.for(driver_name.to_sym, profile: profile)
        end

        def cleanup
            # Make sure windows are closed
            @driver.quit
            @driver2.quit
        end

        def run_comparison(width, path, name)
            # Get domains
            test_host = @config['domains']['test']
            production_host = @config['domains']['production']

            # Open test host tab
            @driver.navigate.to("#{test_host}#{path}")
            @driver2.navigate.to("#{production_host}#{path}")

            # Resize to given width and total height
            @driver.manage.window.resize_to(width, @driver.manage.window.size.height)
            @driver2.manage.window.resize_to(width, @driver2.manage.window.size.height)

            # Create folder for this test
            current_output = FileUtils.mkdir("#{@path}/#{width}_#{name}").join('')

            # Take screenshot
            sleep 1
            @driver.save_screenshot("#{current_output}/test.png")
            @driver2.save_screenshot("#{current_output}/production.png")
        end
    end
end