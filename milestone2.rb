def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
def parse_dns(dns_raw)
  records = {}

  dns_raw.
    map { |line| line.strip }.
    reject { |line| line.empty? }.
    reject { |line| line[0] == "#" }.

    each do |line|
      data = line.split ","
      records[data[1].strip] = { :type => data[0].strip, :value => data[2].strip }
    end

  return records
end

def resolve(records, lookup_chain, domain)
  lookup_result = records[domain]

  if lookup_result == nil
    lookup_chain = ["Not found anything for #{domain}"]
  else
    lookup_chain.push lookup_result[:value]
    lookup_chain = resolve(records, lookup_chain, lookup_result[:value]) if lookup_result[:type] == "CNAME"
  end

  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
