require 'rubygems'
require 'json'

PATH = File.expand_path(File.dirname(__FILE__))

require PATH + '/db.rb'

user_count = 0
json_file = PATH + '/public/js/languagegraph.json'

# global data structure for the graph data
# example:
# languages = {
#   'Ruby' => {
#     'count' => 24
#     'adjacencies' => {
#       'JavaScript' => { 'count' => 20 },
#       'Pyhton' => { 'count' => 10 }
#     }
#   },...
# }
$languages = {}

# control variable
$lang_counts = {}

# example call: update_lang('Ruby', ['Ruby', 'JavaScript'])
def update_lang(name, pair)
  if $lang_counts.has_key?(name)
    $lang_counts[name] += 1
  else
    $lang_counts[name] = 1
  end

  pair.delete(name)
  node_to = pair[0]
  if $languages.has_key?(name)
    $languages[name]['count'] += 1
    if $languages[name]['adjacencies'].has_key?(node_to)
      $languages[name]['adjacencies'][node_to]['count'] += 1
    else
      $languages[name]['adjacencies'][node_to] = { 'count' => 1 }
    end
  else
    $languages[name] = {
      'count' => 1,
      'adjacencies' => { node_to => { 'count' => 1 } }
    }
  end
end

db = Database.new().connect()
coll = db.collection('stats_users')
coll.find.each do |user|
  next unless user['counts']['owned']['languages']

  user_count += 1
  user_langs = user['counts']['owned']['languages']
  # initially ignore user repo counts for any given language
  langs = user_langs.keys
  if langs
    lang_combs = langs.combination(2)
    lang_combs.each do |comb|
      comb.each { |lang| update_lang(lang, comb) }
    end
  end
end


# sort languages by count desc and consider only the 20 most used languages
# otherwise graph is not useful
$languages = $languages.sort_by { |lang,data| data['count'] }.reverse

# generate JSON structure from graph data appripriate for 
# JavaScript InfoVis Toolkit Weighted Graph Animation with 
# see http://thejit.org/static/v20/Jit/Examples/Hypertree/example2.js
json = []
$languages.each do |lang,data|
  adjacencies = []
  data['adjacencies'].each do |node_to, node_data|
    adjacencies.push({
      'nodeTo' => node_to,
      'data' => { 'weight' => node_data['count'] }
    })
  end

  json.push({
    'id' => lang,
    'name' => lang,
    'data' => { '$dim' => data['count'] / 1.4 }, # scale dim down a bit
    'adjacencies' => adjacencies
  })
end


# write JSON file overwrite existing
file = File.new(json_file, 'w')
file.puts "var json = " + json.to_json + ";"
file.close
