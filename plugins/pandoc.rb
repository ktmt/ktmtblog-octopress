require 'open3'
module Jekyll
# Just return html5
class MarkdownConverter
def convert(content)
    flags  = @config['pandoc']['flags']
    output = ''
    Open3::popen3("pandoc -t html5 #{flags}") do |stdin, stdout, stderr|
        stdin.puts content
        stdin.close
        output = stdout.read.strip
    end
    output
    end
end
end
