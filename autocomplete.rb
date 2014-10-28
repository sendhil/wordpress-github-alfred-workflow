require 'net/http'
require 'json'
require 'nokogiri'
require 'fileutils'
require 'date'

def cache_data(data)
  FileUtils.mkdir_p "cached_data"
  File.write("./cached_data/github_repos", JSON.dump(data))
end

def retrieve_cached_data
  return nil unless File.exist?("./cached_data/github_repos")
  data = File.read("./cached_data/github_repos")
  parsed_data = JSON.parse(data)
  return nil if parsed_data.length == 0

  parsed_data
end

def is_cache_fresh?
  time = File.mtime("./cached_data/github_repos")
  
  (Date.parse(time.to_s) + 7) > Date.today
end

def retrieve_repos_from_github
  uri = URI.parse("https://api.github.com/orgs/wordpress-mobile/repos?per_page=100")
  response = Net::HTTP.get_response(uri)
  repos = JSON.parse(response.body)

  repos
end

def filter_repos_by_name(repos, repo_name)
  repos.select { |repo| repo["name"] =~ Regexp.new("#{repo_name}", Regexp::IGNORECASE) }
end

def sort_repos(repos)
  repos.sort { |l,r| l["name"] <=> r["name"] }
end

def generate_xml_for_alfred(repos, search_term = nil)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.send(:items) do
      repos.each do |repo|
        arg = search_term == nil ? repo["html_url"] : "#{repo['html_url']} #{search_term}"
        xml.item(:uid => repo["full_name"], :arg => arg, :autocomplete => repo["name"]) do
          xml.send(:title, repo["name"])
          xml.send(:subtitle, repo["description"])
        end
      end
    end
  end
  puts builder.to_xml
end

repo_name = nil
search_term = nil
if ARGV.length >= 2
  query = ARGV[1]
  query_values = query.split(" ")
  repo_name = query_values[0]
  search_term = query_values.slice(1, query_values.length - 1).join(" ") if query_values.length > 1
else
  repo_name = ARGV[0]
end

repos = retrieve_cached_data

# Reset Cache Every Week
if repos != nil
  repos = nil unless is_cache_fresh?
end

if repos == nil
  repos = retrieve_repos_from_github
  cache_data(repos)
end

if ARGV.length == 0
  repos = sort_repos(repos)
else
  repos = filter_repos_by_name(repos, repo_name)
end

generate_xml_for_alfred(repos, search_term)




