module Pegarus
  module Machine
    class Compiler
      attr_reader :g

      def initialize
        @g = Generator.new
      end

      def compile(pattern)
        pattern.visit self
        pattern.instance_variable_set :@program, g.program

        class << pattern
          class_eval <<-eval
            def match(subject)
              Pegarus::Machine.execute @program, subject
            end
          eval
        end
      end

      def always(pattern)
        g.fail
      end

      def any(pattern)
        g.any pattern.count
      end

      def character(pattern)
        pattern.string.each_char { |b| g.char b }
      end

      def choice(pattern)
        fail = g.new_label
        pass = g.new_label

        g.choice fail
        pattern.first.visit self
        g.commit pass

        fail.set!
        pattern.second.visit self

        pass.set!
      end

      def concatenation(pattern)
        pattern.first.visit self
        pattern.second.visit self
      end

      def difference(pattern)
        g.fail
      end

      def grammar(pattern)
        start = pattern.get_variable pattern.start
        start.visit self
        g.jump g.end_label

        until g.rules.empty?
          rule = g.rules.shift
          label = g.label_for rule

          label.set!
          rule.pattern.visit self
          g.return
        end

        g.end_label.set!
        g.end
      end

      def if(pattern)
        fail = g.new_label
        pass = g.new_label

        g.choice fail
        pattern.pattern.visit self
        g.back_commit pass

        fail.set!
        g.fail

        pass.set!
      end

      def never(pattern)
        g.fail
      end

      def product(pattern)
        pattern.count.times do
          pattern.pattern.visit self
        end

        top = g.new_label
        cont = g.new_label

        g.choice cont
        top.set!
        pattern.pattern.visit self
        g.partial_commit top
        cont.set!
      end

      def set(pattern)
        g.charset pattern.set
      end

      def unless(pattern)
        lbl = g.new_label
        g.choice lbl
        pattern.pattern.visit self
        g.fail_twice
        lbl.set!
      end

      def variable(pattern)
        label = g.label_for pattern
        g.call label
      end
    end
  end
end
