#!/usr/bin/env ruby
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

STDOUT.sync = true

require 'fileutils'
require 'slop'
require 'octokit'

opts = Slop.parse do |o|
  o.string '--token', 'GitHub access token', default: ''
  o.integer '--total', 'Total number of repos to take from GitHub', required: true
  o.integer '--min-stars', 'Minimum GitHub stars in each repo', default: 1000
  o.integer '--max-stars', 'Maximum GitHub stars in each repo', default: 10000
  o.integer '--min-size', 'Minimum size of GitHub repo, in Kb', default: 200
  o.string '--path', 'The file name to save the list to', required: true
  o.string '--tex', 'The file name to save LaTeX summary of the operation', required: true
  o.on '--help' do
    puts o
    exit
  end
end

size = [100, opts[:total]].min

github = Octokit::Client.new
unless opts[:token].empty?
  github = Octokit::Client.new(access_token: opts[:token])
  puts 'Accessing GitHub with personal access token!'
end
names = []
pages = (opts[:total] + size - 1) / size
puts "Will fetch #{pages} GitHub pages"
(0..pages - 1).each do |p|
  json = github.search_repositories(
    [
      "stars:>=#{opts['min-stars']}",
      "stars:<=#{opts['max-stars']}",
      "size:>=#{opts['min-size']}",
      'language:java',
      'is:public',
      'mirror:false',
      'archived:false'
    ].join(' '),
    per_page: size,
    page: p
  )
  json[:items].each do |i|
    names << i[:full_name]
  end
  puts "Found #{json[:items].count} repositories in page #{p}"
  if p > 0
    puts 'Let\'s sleep for a few seconds to cool off GitHub API...'
    sleep 10.seconds
  end
end
puts "Found #{names.count} total repositories in GitHub"
if (names.count > opts[:total])
  names = names.first(opts[:total])
  puts "We will use only the first #{opts[:total]} repositories"
end

File.write(
  opts[:tex],
  'The following search criteria have been used: ' + [
    "at least #{opts['min-stars']} and at most #{opts['max-stars']} stars",
    "at least #{opts['min-size']}Kb and at most #{opts['max-size']}Kb size of Git repo"
  ].join(', ') + ".\n"
)

path = File.expand_path(opts[:path])
FileUtils.mkdir_p(File.dirname(path))
File.write(path, names.join("\n") + "\n")
puts "The list of #{names.count} repos saved into #{path}"
