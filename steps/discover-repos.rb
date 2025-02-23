#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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

def process_year(year, github, context)
  query = build_query(year, context[:opts])
  puts "Querying for repositories created in #{year}..."
  loop_through_pages(query, github, context)
  puts "Completed querying for year #{year}. Found #{context[:found].count} repositories so far."
end

def build_query(year, opts)
  [
    "stars:#{opts['min-stars']}..#{opts['max-stars']}",
    "size:>=#{opts['min-size']}",
    'language:java',
    "created:#{year}-01-01..#{year}-12-31",
    'is:public',
    'mirror:false',
    'archived:false', 'template:false', 'NOT', 'android'
  ].join(' ')
end

def loop_through_pages(query, github, context)
  page = 0
  loop do
    break if context[:found].count >= context[:opts][:total]
    json = fetch_repositories(query, github, page, context)
    break if json[:items].empty?
    process_repositories(json[:items], context)
    page += 1
    cooldown(context)
  end
end

def fetch_repositories(query, github, page, context)
  if context[:opts][:dry]
    mock_reps(page, context[:size], context[:licenses])
  else
    github.search_repositories(query, per_page: context[:size], page: page)
  end
end

def process_repositories(repositories, context)
  repositories.each do |repo_data|
    process_repo(repo_data, context[:found], context[:licenses])
  end
end

def process_repo(repo_data, found, licenses)
  return if repo_already_processed?(repo_data, found)
  return if license_invalid?(repo_data, licenses)
  add_repo_to_found(repo_data, found)
  print_repo_info(repo_data, found)
end

def repo_already_processed?(repo_data, found)
  found.key?(repo_data[:full_name])
end

def license_invalid?(repo_data, licenses)
  no_license = repo_data[:license].nil? || !licenses.include?(repo_data[:license][:key])
  puts "Repo #{repo_data[:full_name]} doesn't contain required license. Skipping" if no_license
  no_license
end

def add_repo_to_found(repo_data, found)
  found[repo_data[:full_name]] = {
    full_name: repo_data[:full_name],
    default_branch: repo_data[:default_branch],
    created_at: repo_data[:created_at].iso8601,
    open_issues_count: repo_data[:open_issues_count],
    description: "\"#{repo_data[:description]}\"",
    topics: Array(repo_data[:topics]).join(' '),
    stars: repo_data[:stargazers_count], forks: repo_data[:forks_count], size: repo_data[:size]
  }
end

def print_repo_info(repo, found)
  puts "Found #{repo[:full_name].inspect} GitHub repo ##{found.count} \
(#{repo[:forks_count]} forks, #{repo[:stargazers_count]} stars) with license: #{repo[:license][:key]}"
end

def cooldown(context)
  puts "Let's sleep for #{context[:opts][:pause]} seconds to cool off GitHub API \
(already found #{context[:found].count} repos, need #{context[:opts][:total]})..."
  sleep context[:opts][:pause]
end

current_year = opts[:start_year]
years = (2008..current_year).to_a.reverse
final_query = ''

puts 'Not searching GitHub API, using mock repos' if opts[:dry]
years.each do |year|
  break if found.count >= opts[:total]
  context = {
    found: found,
    opts: opts,
    licenses: licenses,
    size: size
  }
  process_year(year, github, context)
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
