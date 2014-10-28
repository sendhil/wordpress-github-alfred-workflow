require 'rubygems'
exit if ARGV.count != 2

command = ARGV[0]
parameter = ARGV[1]

if command == "--open-index"
  system("open #{parameter}")  
elsif command == "--open-pr"
  system("open #{parameter}/pulls")  
elsif command == "--open-issues"
  system("open #{parameter}/issues")  
elsif command =~ /search/
  parameters = parameter.split(" ")
  url = parameters[0]
  search_term = parameters.slice(1, parameters.length-1).join(" ")

  if command == "--search-issues"
    system("open \"#{url}/search?q=#{search_term}&type=Issues\"")
  else
  system("open \"#{url}/search?q=#{search_term}&type=Code\"")
  end
end
