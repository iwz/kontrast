require "selenium-webdriver"

module Chalcogen
    class SeleniumHandler
        def initialize
            @path = Chalcogen.path

            # Configure profile
            driver_name = Chalcogen.configuration.browser_driver
            profile = Selenium::WebDriver.const_get(driver_name.capitalize)::Profile.new
            Chalcogen.configuration.browser_profile.each do |option, value|
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
            test_host = Chalcogen.configuration.test_domain
            production_host = Chalcogen.configuration.production_domain

            # Open test host tab
            @driver.navigate.to("#{test_host}#{path}")
            @driver2.navigate.to("#{production_host}#{path}")

            # Resize to given width and total height
            @driver.manage.window.resize_to(width, @driver.manage.window.size.height)
            @driver2.manage.window.resize_to(width, @driver2.manage.window.size.height)

            # Create folder for this test
            current_output = FileUtils.mkdir("#{@path}/#{width}_#{name}").join('')

            # Take screenshot
            Chalcogen.configuration.before_screenshot(@driver, @driver2)
            @driver.save_screenshot("#{current_output}/test.png")
            @driver2.save_screenshot("#{current_output}/production.png")
        end
    end
end