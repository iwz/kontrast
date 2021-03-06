describe Kontrast::TestSuite do
    context "with a spec description and a test suite" do
        before :each do
            # Reset tests & specs
            Kontrast.get_spec_builder.clear!
            if !Kontrast.page_test_suite.nil?
                Kontrast.page_test_suite.clear!
            end

            Kontrast.describe("test") do |spec|
                spec.before_screenshot do |test_driver, production_driver, test|
                    puts "before"
                end
                spec.after_screenshot do |test_driver, production_driver, test|
                    puts "after"
                end
            end

            Kontrast.configure do |config|
                config.pages(1280) do |page|
                    page.test "/"
                    page.something_else "/foo"
                end
                config.pages(320) do |page|
                    page.test "/"
                end
            end
        end

        it "can bind specs to tests" do
            test_320 = Kontrast.page_test_suite.tests.find { |t| t.width == 320 }
            test_1280 = Kontrast.page_test_suite.tests.find { |t| t.width == 1280 }
            test_foo = Kontrast.page_test_suite.tests.find { |t| t.name == "something_else" }

            Kontrast.page_test_suite.bind_specs

            test_spec = Kontrast.get_spec_builder.specs.first
            expect(test_320.spec).to eql(test_spec)
            expect(test_1280.spec).to eql(test_spec)
            expect(test_foo.spec).to be_nil
        end
    end

    it "can add new tests to the suite" do
        suite = Kontrast::TestSuite.new
        t = Kontrast::Test.new(1280, "foo", "/")
        suite << t
        expect(suite.tests).to include(t)
    end

    it "can't add non-tests to the suite" do
        suite = Kontrast::TestSuite.new
        t = "foo"
        expect { suite << t }.to raise_error(Kontrast::TestSuiteException)
    end
end
