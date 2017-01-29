module Flutterby
  module Deletion
    extend ActiveSupport::Concern

    def initialize(*args)
      @deleted = false
      super
    end

    def deleted?
      @deleted
    end

    def delete!
      emit(:deleted)
      move_to(nil)
      @deleted = true
    end
  end
end
