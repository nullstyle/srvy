require 'lru_redux'

module HasKey
  def has_key?(key)
    @data.has_key?(key)
  end
end


LruRedux::Cache.send(:include, HasKey)