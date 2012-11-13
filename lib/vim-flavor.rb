require 'bundler/setup'

module Vim
  module Flavor
    [
      :CLI,
      :VERSION,
    ].each do |name|
      autoload name, "vim-flavor/#{name.to_s().downcase()}"
    end
  end
end
