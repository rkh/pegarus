module Pegarus
  module Machine
    def self.execute(program, subject)
      state = State.new subject
      _, fail = Instructions[:fail]

      total = program.size
      while state.ip < total
        break if state.failure?

        width, code = Instructions[program[state.ip]]
        case width
        when 1
          code[state]
        when 2
          code[state, program[state.ip+1]]
        when 3
          code[state, program[state.ip+1], program[state.ip+2]]
        end

        if state.failure?
          fail[state]
        else
          state.ip += width
        end
      end

      return state.failure? ? nil : state.index
    end
  end
end
