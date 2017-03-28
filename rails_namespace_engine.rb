require 'fileutils'

ARGV[0] = '--help' if ARGV.size < 2

def instructions
  insts = <<-INSTS
    These are the instructions.
  INSTS

  insts
end

if ARGV[0] == '--help'
  puts instructions
else
  namespace = ARGV[0]
  engine_name = ARGV[1]
end

# FileUtils.mkdir 'engines'
