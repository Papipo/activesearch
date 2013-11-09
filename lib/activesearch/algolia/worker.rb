require "sucker_punch"

class ActiveSearch::Algolia::Worker
  include SuckerPunch::Job
  
  def perform(msg)
    begin
      case msg[:task]
      when :reindex
        ::ActiveSearch::Algolia::Client.new.save(msg[:id], msg[:doc])
      when :deindex
        client = ::ActiveSearch::Algolia::Client.new
        client.query("", tags: "original_id:#{msg[:id]}")["hits"].each do |hit|
          client.delete(hit["objectID"])
        end
      end
    rescue Exception => e
      perform(msg.merge!(retries: msg[:retries].to_i + 1)) unless msg[:retries].to_i >= 3
    end
  end
end