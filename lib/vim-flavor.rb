require 'bundler/setup'

module Vim
  module Flavor
    [
      :CLI,
      :Facade,
      :StringExtension,
      :VERSION,
    ].each do |name|
      autoload name, "vim-flavor/#{name.to_s().downcase()}"
    end

    class ::String
      include StringExtension
    end
  end
end
