#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'

dry_run = false
verbose = false
limit = 0

OptionParser.new do |opts|
  opts.banner = "Usage: ruby cleanup.rb [options] <paths>"

  opts.on('-n', '--dry-run', "Don't delete anything") do |n|
    dry_run = n
  end

  opts.on('-v', '--verbose', "Be verbose") do |v|
    verbose = v
  end

  opts.on('-l', '--limit LIMIT', "Limit size") do |l|
    l.match(/^(\d+)([kmgt]?)$/i) do |m|
      limit = m[1].to_i
      multipliers = {
        "t" => 1024**4,
        "g" => 1024**3,
        "m" => 1024**2,
        "k" => 1024
      }

      limit *= multipliers[m[2].downcase] unless m[2].empty?
    end
  end
end.parse!

if limit < 1
  puts "Need a --limit"
  exit!
end

def dir_by_date(path)
  paths = {}
  Dir.new(path).each do |sub_path|
    next if sub_path =~ /^..?$/

    full_path = path + File::SEPARATOR + sub_path

    paths[full_path] = File.mtime(full_path).to_i
  end

  paths.sort_by { |path, mtime| mtime }.collect { |name, time| name }
end

def get_size(path)
  return File.size(path) if !FileTest.directory? path

  total = 0

  Dir.new(path).each do |sub_path|
    next if sub_path =~ /^..?$/

    total += get_size(path + File::SEPARATOR + sub_path)
  end

  total
end


ARGV.each do |path|
  path = path.chomp('/')
  puts "#{path} does not exist or is not a directory" unless Dir.exist? path

  total = 0

  dir_by_date(path).reverse().each do |sub_path|
    total += get_size(sub_path)

    if total > limit
      if !dry_run
        puts "Deleting #{sub_path}" if verbose
        system "rm -rf #{sub_path.shellescape}"
      # todo
      else
        puts "Would delete #{sub_path}"
      end
    end
  end
end
