require 'active_model'
require 'active_attr'
require 'girl_friday'

RSpec.configure do |config|
  config.before(:all) { GirlFriday::WorkQueue.immediate! }
end

class ActiveMimic
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming
  include ActiveModel::Serialization
  include ActiveAttr::Attributes
  include ActiveAttr::MassAssignment
  
  attribute :id
  attribute :type
  
  define_model_callbacks :save
  define_model_callbacks :destroy
  
  def self.create(attrs)
    new(attrs).tap(&:save)
  end
  
  def indexable_id
    "#{self.class.to_s}_#{self.id}"
  end
  
  def type
    self.class.to_s
  end
  
  def save
    self.id = self.class.next_id
    run_callbacks :save do
      true
    end
  end
  
  def destroy
    run_callbacks :destroy do
      true
    end
  end
  
  def self.next_id
    @next_id ||= 0
    @next_id += 1
  end
end