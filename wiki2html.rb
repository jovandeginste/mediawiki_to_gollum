require 'yaml'
require 'fileutils'
require 'pandoc-ruby'
require 'wikicloth'

class String
	def cleanup
		self.gsub(/[^[:alnum:]\/]+/, '-')
	end
	def wiki_to_html(title)
		string = self
		string = string.
			gsub(/(.){/, '\1&#123;').
			gsub(/\[\[([^\]]*)\]([^\]])/, '&#91;&#91;\1&#93;\2').
			gsub(/(<pre>(?!<\/pre>).*)(<pre>)/m,'\1</pre>\2').
			gsub(/(<\/?pre>)(.)/, '\1' + "\n" + '\2').
			gsub(/<\/?p>/, "\n").
			gsub(/<(http:[^>]+)>/, '\1').
			gsub(/(.)(<\/?pre>)/, '\1' + "\n" + '\2').
			gsub(/<!--/, '&lt;!--')

		string = string.split(/(<\/pre>)/m).map{|s|
			if s.match('<pre>')
				a, b = s.split('<pre>')
				b ?  a + b.split("\n").map{|l| "  #{l}"}.join("\n") : a
			elsif s.match('</pre>')
				s.gsub('</pre>', '')
			else
				s
			end
		}.join

		string = string.split("\n").map{|s|
			if s.match(/^  /)
				s.gsub(/</, '&#60;').
					gsub(/>/, '&#62;').
					gsub(/\[/, '&#91;').
					gsub(/\]/, '&#93;').
					gsub(/{/, '&#123;').
					gsub(/}/, '&#125;')
			else
				s
			end
		}.join("\n")

		partials = string.split(/(?=^=.*[^=].*=$)/)

		r = partials.map do |partial|
			WikiCloth::Parser.new(:data => partial).to_html
		end.join
		r.
			gsub(/<span .*>([^<]*)<\/span>/, '\1').
			gsub(/&amp;amp;amp;/, '&amp;').
			gsub(/(href=["'])\//, '\1' + File.basename(title) + '/')
	end
end

ARGV.each do |file|
	begin
		data = YAML.load(File.read(file))

		date = Time.at(data[:timestamp])
		page_id = data[:page_id]
		revision_id = data[:revision_id]
		title = data[:title]

		year = date.year.to_s
		month = date.month.to_s.rjust(2, '0')
		day = date.day.to_s.rjust(2, '0')

		filename = date.to_time.strftime("%F_%H-%M-%S") + "_p#{page_id}_r#{revision_id}.yaml"

		full_filename = File.join(['yaml', 'html', year, month, day, filename])

		puts [file, full_filename].join(' -> ')

		text = data[:text]
		text.force_encoding("UTF-8")
		text = text.wiki_to_html(title)
		data[:text] = text

		FileUtils.mkdir_p(File.dirname(full_filename))
		File.write full_filename, data.to_yaml
	rescue
	end
end
