#!/usr/bin/env ruby

require 'date'
require 'fileutils'

SRC_DIR = '_drafts'.freeze
DST_DIR = '_posts'.freeze

unless Dir.exist?(SRC_DIR)
  abort "Source directory not found: #{SRC_DIR}"
end

unless Dir.exist?(DST_DIR)
  abort "Destination directory not found: #{DST_DIR}"
end

posts = Dir.children(SRC_DIR).select { |name| name.end_with?('.md') }
abort "No Markdown files found in #{SRC_DIR}" if posts.empty?

parsed_posts = posts.map do |filename|
  if filename =~ /^(\d{4}-\d{2}-\d{2})-(.+)$/
    [Date.iso8601(Regexp.last_match(1)), Regexp.last_match(2), filename]
  else
    [File.mtime(File.join(SRC_DIR, filename)).to_date, filename, filename]
  end
end

oldest = parsed_posts.min_by { |date, _, filename| [date, filename] }
oldest_date, slug, filename = oldest
current_date = Date.today.strftime('%Y-%m-%d')
new_filename = if filename =~ /^(\d{4}-\d{2}-\d{2})-(.+)$/
  "#{current_date}-#{Regexp.last_match(2)}"
else
  "#{current_date}-#{filename}"
end

source_path = File.join(SRC_DIR, filename)
destination_path = File.join(DST_DIR, new_filename)

if File.exist?(destination_path)
  base = new_filename.sub(/\.md$/, '')
  suffix = 1
  loop do
    candidate = "#{base}-#{suffix}.md"
    break destination_path = File.join(DST_DIR, candidate) unless File.exist?(File.join(DST_DIR, candidate))
    suffix += 1
  end
end

FileUtils.mv(source_path, destination_path)
puts "Moved #{source_path} -> #{destination_path}"
