require 'active_model'
require 'active_attr'
require 'sucker_punch'
require 'sucker_punch/testing/inline'

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
    self.id ||= self.class.next_id 
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
  
  def self.localized_attribute(name)
    attribute "#{name}_translations", type: Hash
    
    define_method name do
      send("#{name}_translations") && send("#{name}_translations")[I18n.locale.to_s]
    end
    
    define_method "#{name}=" do |value|
      send("#{name}_translations=", {}) if send("#{name}_translations").nil?
      send("#{name}_translations").merge!(I18n.locale.to_s => value)
    end
  end
end