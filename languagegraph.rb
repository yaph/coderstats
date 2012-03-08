require 'rubygems'
require 'json'

PATH = File.expand_path(File.dirname(__FILE__))

require PATH + '/db.rb'

user_count = 0
json_file = PATH + '/public/data/languagegraph.json'

# global data structure for the graph data
# example:
# languages = {
#   'Ruby' => {
#     'adjacencies' => {
#       'JavaScript' => { 'count' => 20 },
#       'Pyhton' => { 'count' => 10 }
#     }
#   },...
# }
$languages = {}

# example call: update_lang('Ruby', 'JavaScript')
def update_lang(name, node_to)
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
# restrict to hyperpoliglot users
coll.find({
    'counts.owned.langcount' => { '$gt' => 5 },
    'counts.owned.forkcount' => { '$gt' => 50 },
    'counts.owned.watchercount' => { '$gt' => 50 },
    'gh_type' => 'User'
  }).each do |user|
  next unless user['counts']['owned']['languages']

  user_count += 1
  user_langs = user['counts']['owned']['languages']
  # initially ignore user repo counts for any given language
  langs = user_langs.keys
  if langs
    lang_combs = langs.permutation(2)
    lang_combs.each do |comb|
      update_lang(comb[0], comb[1])
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

#  puts lang, adjacencies.length.to_s, adjacencies
  json.push({
    'id' => lang,
    'name' => lang + ' (' + adjacencies.length.to_s + ')',
    'data' => { '$dim' => Math.log(adjacencies.length) ** 2 }, # scale dim logaritmically
    'adjacencies' => adjacencies
  })
end


# write JSON file overwrite existing
file = File.new(json_file, 'w')
file.puts "var json = " + json.to_json + ";"
file.close
