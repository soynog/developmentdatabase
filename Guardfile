require 'active_support/inflector'

opts = {
  all_on_start:   false,
  all_after_pass: false,
  spring:         true
}

guard :minitest, opts do
  watch(%r{^app/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/application_controller\.rb$}) { "test/controllers" }
  watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
  watch(%r{^app/resources/(.+)_resource\.rb$})            { |m| "test/controllers/#{m[1].pluralize}_controller_test.rb" }
  watch(%r{^app/views/(.+)_mailer/.+})                    { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  watch(%r{^app/workers/(.+)\.rb$})                       { |m| "test/unit/workers/#{m[1]}_test.rb" }
  watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/#{m[1]}_test.rb" }
  watch(%r{^lib/tasks/(.+)\.rake$})                       { |m| "test/unit/lib/tasks/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$}) { "test" }
  watch(%r{^test/fixtures/(.+)\.yml$})                     { |m| "test/models/#{m[1].singularize}_test.rb" }
  watch(%r{^config/routes.rb$}) { |m| 'test/routes/route_test.rb' }
end
