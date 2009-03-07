require 'rufus/tokyo'
require 'tinder'

module LighthouseNotifier
  module Config
    def self.[](project_id)
      @connection["project-#{project_id}"] || {}
    end

    def self.[]=(project_id, params)
      @connection["project-#{project_id}"] = params
    end

    def self.connect(path, options = {})
      @connection = Rufus::Tokyo::Table.new(path, options = {})
    end

    def self.each
      @connection.keys(:prefix => 'project-').each do |k|
        yield k.sub(/^project-/, '')
      end
    end
  end

  module Campfire
    def self.ping(options, data, msg)
      cf = Tinder::Campfire.new options[:domain], :ssl => options[:ssl]
      cf.login options[:login], options[:password]
      room   = options[:room] && cf.rooms.detect { |r| r.name == options[:room] }
      room ||= cf.rooms[0]
      room.speak msg
      nil
    end
  end
end