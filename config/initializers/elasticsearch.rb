# config/initializers/elasticsearch.rb
# ENV['ELASTICSEARCH_ADDRESS_INT'] is the environment variable
# for the elasticsearch server, replace with IP address if not using ENV
# Post.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['IP']