module Search
  class Cluster
    SEARCH_CLASSES = [
      # Remove these now because we're not using them and got too many shards
      # Search::ChatChannelMembership,
      # Search::Listing,
      Search::FeedContent,
      Search::Tag,
      Search::User,
    ].freeze

    class << self
      def recreate_indexes
        delete_indexes
        setup_indexes
      end

      def setup_indexes
        update_settings
        create_indexes
        update_indexes
        add_aliases
        update_mappings
      end

      def update_settings
        Search::Client.cluster.put_settings(body: default_settings)
      rescue StandardError
        handle_exception
      end

      def create_indexes
        SEARCH_CLASSES.each do |search_class|
          next if search_class.index_exists?

          search_class.create_index
        end
      end

      def update_indexes
        SEARCH_CLASSES.each(&:update_index)
      end

      def add_aliases
        SEARCH_CLASSES.each(&:add_alias)
      end

      def update_mappings
        SEARCH_CLASSES.each(&:update_mappings)
      end

      def delete_indexes
        return if Rails.env.production?

        SEARCH_CLASSES.each do |search_class|
          next unless Search::Client.indices.exists(index: search_class::INDEX_NAME)

          search_class.delete_index
        end
      end

      private

      def default_settings
        {
          persistent: {
            action: {
              auto_create_index: false
            }
          }
        }
      end

      def handle_exception
        Rails.logger.info("Error updating ElasticSearch cluster")
      end
    end
  end
end
