require 'rally_api'
require "pp"
require_relative "00-config.rb"

boilerplate_text = "" #"this is some boilerplate text"

start_time = Time.now

@rally = RallyAPI::RallyRestJson.new(@config)

test_query = RallyAPI::RallyQuery.new()

# types = %{:defect, :project, :workspace, :user, :typedefinition,:story,:hierarchicalrequirement,:test_case }
test_query.type       = :portfolioitem
test_query.fetch      = "FormattedID,Name,Parent,c_ExternalID" # the fields we want - trying to minimize the transfer

#setup default workspace/project based on the config
test_query.workspace ||= @rally.find_workspace(@config[:workspace])
test_query.project ||= @rally.find_project(test_query.workspace,@config[:project])

test_query.page_size  = 2000       #optional - default is 200
test_query.limit = 200000          #optional - default is 99999
test_query.project_scope_up   = false
test_query.project_scope_down = true
test_query.order = "FormattedID Asc" # totally optional...

test_query.query_string = "(Parent.FormattedID = \"E21\")"

results = @rally.find(test_query)

puts "Found [#{results.total_result_count.to_s}]"

field_updates = {}   # applying the same values multiple times, put outside loop
field_updates["c_ExternalID"] = boilerplate_text

results.each_with_index do |r,index|
  #r.read
  #puts "#{index+1}:#{r.FormattedID}(#{r.Parent}) - #{r.Name}"
  puts "#{index+1}. Updating #{r.FormattedID}"
  r.update(field_updates)
end

puts "Count = #{results.total_result_count.to_s}"
puts "Elapsed: #{'%4.1f' % ((Time.now - start_time)/60)} minutes"