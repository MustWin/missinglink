module Missinglink
  class Engine < ::Rails::Engine
    isolate_namespace Missinglink

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
