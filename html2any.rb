require 'yaml'
require 'fileutils'
require 'pandoc-ruby'

type = ARGV.shift

class String
	def html_to(type)
		case type
		when 'md'
			result = PandocRuby.convert(self, :from => :html, :to => :markdown_github)
			header = /\[\[edit\]\(\?section\=(?:.*)\)\] /
		when 'rst'
			result = PandocRuby.convert(self, :from => :html, :to => :rst)
			header = /\[`edit <\?section\=(?:[^\]]*)\] /
		else
			result = PandocRuby.convert(self, :from => :html, :to => type.to_sym)
			header = nil
		end
		result.gsub(header, '')
	end
end

ARGV.each do |file|
		data = YAML.load(File.read(file))

		date = Time.at(data[:timestamp])
		page_id = data[:page_id]
		revision_id = data[:revision_id]
		data[:type] = type

		year = date.year.to_s
		month = date.month.to_s.rjust(2, '0')
		day = date.day.to_s.rjust(2, '0')

		filename = date.to_time.strftime("%F_%H-%M-%S") + "_p#{page_id}_r#{revision_id}.yaml"

		full_filename = File.join(
			[
				'yaml',
				type,
				year,
				month,
				day,
				filename,
			]
		)

		puts [file, full_filename].join(' -> ')

		text = data[:text]
		text.force_encoding("UTF-8")
		text = text.html_to(type)
		data[:text] = text

		FileUtils.mkdir_p(File.dirname(full_filename))
		File.write full_filename, data.to_yaml
end
