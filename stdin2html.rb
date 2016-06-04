require 'wikicloth'

string = STDIN.read

string = string.gsub(/([^ ]){/, '\1&#123;')
	.gsub(/\[\[([^\]]*)\]([^\]])/, '&#91;&#91;\1&#93;\2')
	.gsub(/(<pre>(?!<\/pre>).*)(<pre>)/m,'\1</pre>\2')
	.gsub(/(<\/?pre>)(.)/, '\1' + "\n" + '\2')
	.gsub(/<\/?p>/, '')
	.gsub(/<(http:[^>]*)>/, '\1')
	.gsub(/(.)(<\/?pre>)/, '\1' + "\n" + '\2')
	.gsub(/<!--/, '&lt;!--')

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
		s.gsub(/</, '&#60;')
			.gsub(/>/, '&#62;')
			.gsub(/\[/, '&#91;')
			.gsub(/\]/, '&#93;')
			.gsub(/{/, '&#123;')
			.gsub(/}/, '&#125;')
	else
		s
	end
}.join("\n")

puts string

partials = string.split(/(?=^=.*[^=].*=$)/)

output = partials.map do |partial|
	WikiCloth::Parser.new(:data => partial).to_html
end.join
puts output
