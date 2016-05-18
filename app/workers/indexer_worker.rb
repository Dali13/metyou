class IndexerWorker
  include Sidekiq::Worker
  # sidekiq_options queue: 'elasticsearch', 
  sidekiq_options :retry => 5

  # Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  # Client = Elasticsearch::Client.new host: 'localhost:9200', logger: Logger

  def perform(operation, record_id)
    #logger.debug [operation, "ID: #{record_id}"]

    case operation.to_s
      when "index"
        # record = Post.find(record_id)
        # Client.index  index: 'posts', type: 'post', id: record.id, body: record.as_indexed_json
        Post.find(record_id).__elasticsearch__.index_document
      when "delete"
        # Client.delete index: 'posts', type: 'post', id: record_id
        # Post.find(record_id).__elasticsearch__.delete_document
        Post.__elasticsearch__.client.delete index: 'posts', type: 'post', id: record_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end