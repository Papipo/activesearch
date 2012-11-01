require 'active_model'
require 'active_attr'

class ActiveMimic
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming
  include ActiveModel::Serialization
  include ActiveAttr::Attributes
  include ActiveAttr::MassAssignment
  
  attribute :id
  
  define_model_callbacks :save
  define_model_callbacks :destroy
  
  def self.create(attrs)
    new(attrs).tap(&:save)
  end
  
  def save
    run_callbacks :save do
      true
    end
  end
  
  def destroy
    run_callbacks :destroy do
      true
    end
  end
end