module ActsAsUniversallyUnique 
  module ClassMethods 
    def acts_as_universally_unique(options = {})
      cattr_accessor :uuid_attribute, :uuid_format
      self.uuid_attribute = options[:column] || :uuid
      self.uuid_format = options[:format] || :compact
      before_validation_on_create :set_uuid
    end 
  end 

  module InstanceMethods
    def set_uuid
      # our default format is :compact, but the UUID gem defines a :default 
      # value so we map :expanded to the UUID gem's :default format 
      write_attribute(
        self.uuid_attribute, 
        UUID.new.generate(
          self.uuid_format == :expanded ? :default : self.uuid_format
        )
      )
    end
    def uuid
      read_attribute(self.uuid_attribute)
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      include InstanceMethods
    end
  end
end
ActiveRecord::Base.send :include, ActsAsUniversallyUnique
