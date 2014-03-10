module Vim
  module Flavor
    class BranchVersion
      attr_reader :branch
      attr_reader :revision

      def initialize(branch, revision)
        @branch = branch
        @revision = revision
      end

      def ==(other)
        self.class === other and
          self.branch == other.branch and
          self.revision == other.revision
      end

      def to_s()
        "#{revision} at #{branch}"
      end

      def to_revision()
        return revision if revision
        throw "Internal error: A revision of a branch #{branch} is not known"
      end
    end
  end
end
