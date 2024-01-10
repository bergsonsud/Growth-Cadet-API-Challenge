require 'simplecov'

SimpleCov.start 'rails' do
  minimum_coverage 19
  maximum_coverage_drop 2

  add_filter do |source_file|
    source_file.lines.count < 3
  end

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'

  #ignore folder channels and mailers
  add_filter 'app/channels'
  add_filter 'app/mailers'
  add_filter 'app/jobs'
end
