require 'parslet'

module Vim
  module Flavor
    class LockFileParser
      def self.parse(s)
        Transformer.new.apply(Parser.new().parse(s))[:lockfile]
      end

      class Parser < Parslet::Parser
        root(:lockfile)

        rule(:lockfile) {
          space? >> newline.maybe >>
          (
            (
              flavor >> (newline | eof)
            ).repeat(0).as(:lockfile)
          )
        }

        rule(:flavor) {
          (
            space? >>
            repo_name >> space? >>
            str('(') >> space? >>
            locked_version >> space? >>
            str(')') >> space?
          ).as(:flavor)
        }

        rule(:repo_name) {
          (
            match('\w') >>
            match('[^ \t()]').repeat(0)
          ).as(:repo_name)
        }
        rule(:locked_version) {
          (
            str('v').maybe >>
            match('[\d.]').repeat(1)
          ).as(:locked_version)
        }

        rule(:space) {match('[ \t]').repeat(1)}
        rule(:space?) {space.maybe}
        rule(:newline) {match('[\r\n]').repeat(1)}
        rule(:eof) {any.absent?}
      end

      class Transformer < Parslet::Transform
        rule(
          :flavor => {
            :repo_name => simple(:repo_name),
            :locked_version => simple(:locked_version),
          }
        ) {
          f = Flavor.new()
          f.repo_name = repo_name.to_s
          f.locked_version = Version.create(locked_version.to_s)
          f
        }
      end
    end
  end
end
