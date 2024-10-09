#!/usr/bin/env ruby
# frozen_string_literal: true

# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

$stdout.sync = true

require 'fileutils'
require 'slop'
require 'octokit'
require 'date'

opts = Slop.parse do |o|
  o.string '--token', 'GitHub access token', default: ''
  o.boolean '--dry', 'Make no round-trips to GitHub API (for testing)', default: false
  o.integer '--total', 'Total number of repos to take from GitHub', required: true
  o.integer '--pause', 'How many seconds to sleep between API calls', default: 10
  o.integer '--page-size', 'Number of repos to fetch in one API call', default: 100
  o.integer '--min-stars', 'Minimum GitHub stars in each repo', default: 1000
  o.integer '--max-stars', 'Maximum GitHub stars in each repo', default: 100_000
  o.integer '--min-size', 'Minimum size of GitHub repo, in Kb', default: 100
  o.integer '--start-year', 'The starting year for querying repositories', default: Date.today.year
  o.string '--csv', 'The file name to save the list to', required: true
  o.string '--tex', 'The file name to save LaTeX summary of the operation', required: true
  o.on '--help' do
    puts o
    exit
  end
end

puts "Trying to find #{opts[:total]} repos in GitHub"
size = [opts[:page_size], opts[:total]].min
puts "Taking up to #{size} repos per one GitHub API request"
licenses = [
  'mit',
  'apache-2.0',
  '0bsd'
]

github = Octokit::Client.new
unless opts[:token].empty?
  github = Octokit::Client.new(access_token: opts[:token])
  puts 'Accessing GitHub with personal access token!'
end
found = {}
def mock_array(size, licenses)
  Array.new(size) do
    {
      full_name: "foo/#{Random.hex(5)}",
      created_at: Time.now,
      license: { key: licenses.sample(1)[0] }
    }
  end
end

def mock_reps(page, size, licenses)
  {
    items: if page > 100 then []
    else
      mock_array(size, licenses)
    end
  }
end

def process_repo(i, found, licenses, opts)
  return if found.key?(i[:full_name])
  no_license = i[:license].nil? || !licenses.include?(i[:license][:key])
  puts "Repo #{i[:full_name]} doesn't contain required license. Skipping" if no_license
  return if no_license
  found[i[:full_name]] = {
    full_name: i[:full_name],
    default_branch: i[:default_branch],
    stars: i[:stargazers_count],
    forks: i[:forks_count],
    created_at: i[:created_at].iso8601,
    size: i[:size],
    open_issues_count: i[:open_issues_count],
    description: "\"#{i[:description]}\"",
    topics: Array(i[:topics]).join(' ')
  }
  puts "Found #{i[:full_name].inspect} GitHub repo ##{found.count} \
(#{i[:forks_count]} forks, #{i[:stargazers_count]} stars) with license: #{i[:license][:key]}"
end

def process_year(year, github, found, opts, size, licenses)
  page = 0
  query = [
    "stars:#{opts['min-stars']}..#{opts['max-stars']}",
    "size:>=#{opts['min-size']}",
    'language:java',
    "created:#{year}-01-01..#{year}-12-31",
    'is:public',
    'mirror:false',
    'archived:false',
    'template:false',
    'NOT',
    'android'
  ].join(' ')
  puts "Querying for repositories created in #{year}..."
  loop do
    break if found.count >= opts[:total]
    json = if opts[:dry]
      mock_reps(page, size, licenses)
    else
      github.search_repositories(query, per_page: size, page: page)
    end
    break if json[:items].empty?

    json[:items].each do |i|
      process_repo(i, found, licenses, opts)
    end
    page += 1
    cooldown(opts, found)
  end
  puts "Completed querying for year #{year}. Found #{found.count} repositories so far."
end

current_year = opts[:start_year]
years = (2008..current_year).to_a.reverse
final_query = ''

def cooldown(opts, found)
  puts "Let's sleep for #{opts[:pause]} seconds to cool off GitHub API \
(already found #{found.count} repos, need #{opts[:total]})..."
  sleep opts[:pause]
end

puts 'Not searching GitHub API, using mock repos' if opts[:dry]
years.each do |year|
  break if found.count >= opts[:total]
  process_year(year, github, found, opts, size, licenses)
end
puts "Found #{found.count} total repositories in GitHub"

if found.count > opts[:total]
  found = found.first(opts[:total]).to_h
  puts "We will use only the first #{opts[:total]} repositories"
end

FileUtils.mkdir_p(File.dirname(opts[:tex]))
File.write(
  opts[:tex],
  [
    'The following search criteria have been used:',
    '\begin{enumerate}',
    "\\item At least #{opts['min-stars']} stars,",
    "\\item At most #{opts['max-stars']} stars,",
    'and',
    "\\item At least #{opts['min-size']} Kb size of Git repo.",
    '\end{enumerate}',
    'The exact query string for',
    ' GitHub API\footnote{\url{https://docs.github.com/en/rest}}',
    ' was the following:',
    '\begin{ffcode}',
    final_query.gsub(' ', "\n"),
    '\end{ffcode}'
  ].join("\n")
)

path = File.expand_path(opts[:csv])
FileUtils.mkdir_p(File.dirname(path))
lines = [found.first[1].keys.join(',')] + found.values.map { |m| m.values.join(',') }
lines << ''
File.write(path, lines.join("\n"))
puts "The list of #{found.count} repos saved into #{path}"
