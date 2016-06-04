require 'yaml'
require 'shellwords'
require 'fileutils'

base = ARGV.shift

class String
	def cleanup
		self
	end
	def to_key
		self.gsub(/_/, '-')
	end
	def to_value
		self.shellescape
	end
	def sanitize_comment
		self.gsub(/^\/\* */, '').gsub(/ *\*\/$/, '')
	end
end
class Symbol
	def to_key
		self.to_s.to_key
	end
	def to_value
		self.to_s.to_value
	end
end
class NilClass
	def to_value
		''.shellescape
	end
	def sanitize_comment
		'no comment'
	end
end

class Hash
	def to_params
		self.collect do |key, value|
			case value
			when nil
				"--#{key.to_key}"
			else
				"--#{key.to_key}=#{value.to_value}"
			end
		end.join(" ")
	end
end

def git(command, filename, params = {}, git_params = {})
	puts "Executing: git #{git_params.to_params} #{command} #{params.to_params} #{filename.shellescape}"
	system "git #{git_params.to_params} #{command} #{params.to_params} #{filename.shellescape}"
end

ARGV.each do |file|
	data = YAML.load(File.read(file))

	date = Time.at(data[:timestamp])
	type = data[:type]

	filename = File.join(data[:title].cleanup + "." + type)

	full_filename = File.join(
		[
			base,
			filename
		]
	)

	puts [file, full_filename].join(' -> ')

	text = data[:text]
	text.force_encoding("UTF-8")

	git_params = {
		work_tree: File.join(base, '.'),
		git_dir: File.join(base, '.git'),
	}
	git_commit_params = {
		date: date.to_s,
		author: data[:contributor],
		message: data[:comment].sanitize_comment,
		allow_empty_message: nil,
	}

	FileUtils.mkdir_p(File.dirname(full_filename))
	File.write full_filename, text
	git :add, filename, {}, git_params
	git :commit, filename, git_commit_params, git_params
end
