#!/usr/bin/env ruby
# frozen_string_literal: true

# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
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

max = 1000

opts = Slop.parse do |o|
  o.string '--token', 'GitHub access token', default: ''
  o.boolean '--dry', 'Make no round-trips to GitHub API (for testing)', default: false
  o.integer '--total', 'Total number of repos to take from GitHub', required: true
  o.integer '--pause', 'How many seconds to sleep between API calls', default: 10
  o.integer '--page-size', 'Number of repos to fetch in one API call', default: 100
  o.integer '--min-stars', 'Minimum GitHub stars in each repo', default: max
  o.integer '--max-stars', 'Maximum GitHub stars in each repo', default: 100_000
  o.integer '--min-size', 'Minimum size of GitHub repo, in Kb', default: 100
  o.string '--csv', 'The file name to save the list to', required: true
  o.string '--tex', 'The file name to save LaTeX summary of the operation', required: true
  o.on '--help' do
    puts o
    exit
  end
end

raise 'Can only retrieve up to 1000 repos' if opts[:total] > max

size = [opts[:page_size], opts[:total]].min

github = Octokit::Client.new
unless opts[:token].empty?
  github = Octokit::Client.new(access_token: opts[:token])
  puts 'Accessing GitHub with personal access token!'
end
found = {}
page = 0
query = [
  "stars:#{opts['min-stars']}..#{opts['max-stars']}",
  "size:>=#{opts['min-size']}",
  'language:java',
  'is:public',
  'mirror:false',
  'archived:false',
  'NOT',
  'android'
].join(' ')
loop do
  if page * size > max
    puts "Can't go to page ##{page}, since it will be over #{max}"
    break
  end
  json = if opts[:dry]
           { items: page > 100 ? [] : [{ full_name: "foo/#{Random.hex(5)}", created_at: Time.now }] }
         else
           github.search_repositories(query, per_page: size, page: page)
         end
  json[:items].each do |i|
    found[i[:full_name]] = {
      full_name: i[:full_name],
      default_branch: i[:default_branch],
      stars: i[:stargazers_count],
      forks: i[:forks_count],
      created_at: i[:created_at].iso8601,
      size: i[:size],
      open_issues_count: i[:open_issues_count]
    }
    puts "Found #{i[:full_name].inspect} GitHub repo ##{found.count} \
(#{i[:forks_count]} forks, #{i[:stargazers_count]} stars)"
  end
  puts "Found #{json[:items].count} repositories in page ##{page}"
  break if found.count >= opts[:total]
  puts "Let's sleep for #{opts[:pause]} seconds to cool off GitHub API \
(already found #{found.count} repos, need #{opts[:total]})..."
  sleep opts[:pause]
  page += 1
end
puts "Found #{found.count} total repositories in GitHub"

if found.count > opts[:total]
  found = found.first(opts[:total])
  puts "We will use only the first #{opts[:total]} repositories"
end

FileUtils.mkdir_p(File.dirname(opts[:tex]))
File.write(
  opts[:tex],
  [
    'The following search criteria have been used:',
    "``at least #{opts['min-stars']},",
    "at most #{opts['max-stars']} stars,",
    "at least #{opts['min-size']}Kb size of Git repo.''",
    "The exact query string for GitHub API was the following: ``\\texttt{#{query}}''.\n"
  ].join(' ')
)

path = File.expand_path(opts[:csv])
FileUtils.mkdir_p(File.dirname(path))
lines = [found.first[1].keys.join(',')] + found.values.map { |m| m.values.join(',') }
lines << ''
File.write(path, lines.join("\n"))
puts "The list of #{found.count} repos saved into #{path}"
