require "net/http"
require "json"
require "socket"

module Etcd
  module Lock

    LockExists       = Class.new(StandardError)
    LockFailed       = Class.new(StandardError)
    LockRemoveFailed = Class.new(StandardError)

    class Coordinator

      def initialize(appname)
        @appname   = appname
        @hostname  = Socket.gethostname || 'unknown'
        @etcd_host = ENV.fetch('ETCD_HOST', 'localhost')
        @etcd_port = ENV.fetch('ETCD_PORT', 4001)
        @lock_nspc = ENV.fetch('ETCD_LOCK_NAMESPACE', 'lock-dev')
      end

      def run(name, opts = {})
        fail "Missing block!" unless block_given?
        obtain_lock name, opts[:ttl]
        yield.tap do
          remove_lock name if opts[:remove]
        end
      end

      private

      def obtain_lock(name, ttl = 10)
        Net::HTTP.start(@etcd_host, @etcd_port) do |http|
          req = Net::HTTP::Put.new("#{lock_path name}?prevExist=false")
          req.set_form_data value: @hostname, ttl: ttl
          response = http.request(req)
          unless response.is_a? Net::HTTPCreated
            if response.content_type == 'application/json'
              rdata = JSON.parse(response.body)
              if rdata['message'] == 'Key already exists'
                raise LockExists.new(name)
              else
                raise LockFailed.new(rdata['message'])
              end
            end
            raise LockFailed.new(response.body)
          end
        end
      rescue => ex
        case ex
        when LockExists, LockFailed
          raise ex
        else
          raise LockFailed.new(ex)
        end
      end

      def remove_lock(name)
        Net::HTTP.start(@etcd_host, @etcd_port) do |http|
          http.delete lock_path(name)
        end
      rescue => ex
        raise LockRemoveFailed.new(ex)
      end

      def lock_path(name)
        "/v2/keys/apps/#{@appname}/#{@lock_nspc}/#{name}"
      end
    end
  end
end
