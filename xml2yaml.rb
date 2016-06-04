require 'xmlsimple'
require 'yaml'
require 'fileutils'

file = ARGV.shift || 'wikidump.xml'
userfile = 'users.yaml'

users = YAML.load(File.read(userfile))
puts "Got info for #{users.size} users."


puts "Parsing file '#{file}' ..."
hash = XmlSimple.xml_in(file)
puts "Done. Writing revisions..."

class NilClass
	def first
		nil
	end
end

hash['page'].each do |page|
	title = page['title'].first
	page_id = page['id'].first

	page['revision'].each do |revision|
		revision_id = revision['id'].first
		contributor = revision['contributor'].first['username'].first
		date = DateTime.parse(revision['timestamp'].first)
		text = revision['text'].first['content'] || ""
		text.force_encoding("UTF-8")
		comment = revision['comment'].first

		if u = users[contributor]
			contributor = "#{u['name']} <#{u['mail']}>"
		else
			contributor = "#{contributor} <unknown@mail.address>"
		end

		data = {
			page_id: page_id,
			revision_id: revision_id,
			title: title,
			comment: comment,
			contributor: contributor,
			timestamp: date.to_time.to_i,
			type: 'wiki',
			text: text,
		}

		year = date.year.to_s
		month = date.month.to_s.rjust(2, '0')
		day = date.day.to_s.rjust(2, '0')

		filename = date.to_time.strftime("%F_%H-%M-%S") + "_p#{page_id}_r#{revision_id}.yaml"

		full_filename = File.join(['yaml', 'wiki', year, month, day, filename])

		FileUtils.mkdir_p(File.dirname(full_filename))
		File.write full_filename, data.to_yaml
	end
end
