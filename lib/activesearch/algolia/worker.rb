require "sucker_punch"

class ActiveSearch::Algolia::Worker
  include SuckerPunch::Job
  
  def perform(msg)
    begin
      case msg[:task]
      when :reindex
        ::ActiveSearch::Algolia::Client.new.save(msg[:id], msg[:doc])
      when :deindex
        ::ActiveSearch::Algolia::Client.new.delete(msg[:id])
      end
    rescue Exception => e
      perform(msg.merge!(retries: msg[:retries].to_i + 1)) unless msg[:retries].to_i >= 3
    end
  end
end