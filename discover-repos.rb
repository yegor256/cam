#!/usr/bin/env ruby
# The MIT License (MIT)
#
# Copyright (c) 2021 Yegor Bugayenko
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
  o.integer '--total', 'Total number of repos to take from GitHub', required: true
  o.integer '--page', 'Page size in GitHub request', default: 50
  o.string '--path', 'The file name to save the list to', required: true
  o.on '--help' do
    puts o
    exit
  end
end

raise '--total must be larger or equal to --page' if opts[:total] < opts[:page]

github = Octokit::Client.new
names = []
pages = opts[:total] / opts[:page]
puts "Will fetch #{pages} GitHub pages"
(0..pages - 1).each do |p|
  json = github.search_repositories(
    'stars:>=1000 stars:<=10000 size:>200 size:<1000000 language:java is:public mirror:false archived:false',
    per_page: opts[:page],
    page: p
  )
  json[:items].each do |i|
    names << i[:full_name]
  end
  puts "Found #{json[:items].count} repositories in page #{p}"
end
puts "Found #{names.count} total repositories in GitHub"

path = File.expand_path(opts[:path])
FileUtils.mkdir_p(File.dirname(path))
File.write(path, names.join("\n") + "\n")
puts "The list of repos saved into #{path}"
