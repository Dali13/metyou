    if Rails.env.production?
        if ENV["REDISCLOUD_URL"]
        $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
        end
    else
        $redis = Redis.new
    end

#     DATA = JSON.parse(File.read("#{Rails.root}/public/postal_code_fr.json"))

#     DATA["cp_autocomplete"].each.with_index(1) do |f, index|
#       $redis.hset 'postal-data', index, f.to_json
#     end

#     DATA["cp_autocomplete"].each.with_index(1) do |f, index|
#       (2..4).each do |n|
#         prefix = (f['CP'][0..n]).to_s
#         $redis.zadd "postal:#{prefix}", 0, index
#       end
#     end

#     DATA["cp_autocomplete"].each do |f|
#       f["CITY_PAR"] = f['VILLE'].parameterize
#     end

#     DATA["cp_autocomplete"].each.with_index(1) do |f, index|
#       (2..((f["CITY_PAR"].length)-1)).each do |n|
#         prefix = (f['CITY_PAR'][0..n]).to_s.downcase
#         $redis.zadd "city:#{prefix}", 0, index
#       end
#     end
# DATA = nil



# DATA["cp_autocomplete"].each.with_index(1) do |f, index|
#   $redis.hset 'postal-data', index, f.to_json
# end

# DATA["cp_autocomplete"].each.with_index(1) do |f, index|
#   (2..((f["CP"]).length - 1)).each do |n|
#     prefix = f['CP'][0..n]
#     $redis.zadd 'postal-index:#{prefix}', 0, index
#   end
# end  

# ActiveSupport::Dependencies.remove_const(DATA)
# DATA["cp_autocomplete"].each do |f|
#   f["CITY_PAR"] = f['VILLE'].parameterize
# end

# $redis.set('postal', DATA)