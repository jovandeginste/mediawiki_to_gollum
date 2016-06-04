# mediawiki_to_gollum

Scripts to convert a mediawiki xml export to a git repository usable with Gollum, maintaining revision history in the git commits

Every step is a separate script; you can choose which final format you use with Gollum
* Wiki
* Markdown
* reStructuredText
* ... or anything else supported by [pandoc](http://pandoc.org/)

Conversion from `wiki` to other formats is done via `html` as a step in between for layout reasons...

steps:

1. generate `wikidump.xml` (tool bundled with MediaWiki)
2. create users.yaml based on `<username>` tags found in the `wikidump.xml`
3. `xml2wiki.rb`: split the `wikidump.xml` into wiki yaml-files per revision
4. `wiki2html.rb`: convert every wiki yaml into an html yaml file
5. `html2any.rb`: convert every html yaml file into your final format yaml file
6. `any2git.rb`: convert the final format yaml files into a git repo:
   a. create a new repo in `./repo` (eg. use `reset_repo` script)
   b. write actual file in `./repo`
   c. perform a git commit with revision comment and author
   d. repeat b. and c. for every revision of every wiki page
   
Every conversion script takes any number of yaml files as parameters and will parse them in order.
`html2any.rb` takes the format as first parameter, and then the yaml files.
Step 3 is one big conversion and might take a long time depending on the size of your wiki. For steps
4 and 5, order of the yaml files is not important and extremely parallellizable. For step 6, order is
important (chronology!)

See `convert_mw` for a way to convert it...
