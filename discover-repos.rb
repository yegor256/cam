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

total=ARGV[0].to_i
dir=ARGV[1]

require 'fileutils'
require 'octokit'

github = Octokit::Client.new
names = []
(0..((total + 1) / 10)).each do |p|
  json = github.search_repositories(
    'stars:>=1000 size:>200 language:java is:public mirror:false archived:false',
    per_page: 10,
    page: p
  )
  json[:items].each do |i|
    names << i[:full_name]
  end
end
puts "Found #{names.count} repositories in GitHub"

names.each do |n|
  d = File.join(dir, n)
  if File.exist?(d)
    puts "#{n} is already here"
  else
    FileUtils.mkdir_p(d)
    puts "#{n} created"
  end
end

Dir.glob('*/*', base: dir).each do |n|
  d = File.join(dir, n)
  unless names.include?(n)
    FileUtils.rm_rf(d)
    puts "#{d} deleted"
  end
end

Dir.glob('*', base: dir).each do |n|
  d = File.join(dir, n)
  if Dir.empty?(d)
    FileUtils.rm_rf(d)
    puts "#{d} deleted"
  end
end
