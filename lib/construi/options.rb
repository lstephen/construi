module Construi
  module Options
    @features = []

    class << self
      attr_accessor :features

      def enable(feature)
        features << feature
      end

      def enabled?(feature)
        features.include? feature
      end
    end
  end
end
