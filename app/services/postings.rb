require "postings/handlers"

module Postings
  #
  # A job posting.
  #
  # +part_time?+ and +remote?+ default to +false+.
  #
  Posting = Struct.new(:title, :description, :url, :part_time, :remote) do
    def part_time?
      @part_time = false if @part_time.nil?
      @part_time
    end

    def remote?
      @remote = false if @remote.nil?
      @remote
    end
  end

  class << self
    ##
    #
    # Find jobs postings for the given id (URL, etc...)
    #
    # === Returns
    #
    # An Array of +Posting+s
    #

    def find(id)
      klass = handlers.find { |handler| handler.supports?(id) }
      raise ArgumentError, "do not know how to find postings for id '#{id}'" unless klass

      klass.new(id).find
    end

    private

    def handlers
      Handlers.constants.each_with_object([]) do |name, list|
        const = Handlers.const_get(name)
        list << const if const.is_a?(Class) && const.respond_to?(:supports?)
      end
    end
  end
end
