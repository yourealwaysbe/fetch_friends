#!/usr/bin/ruby

require 'mail'

if ARGV.length != 1 or
   ARGV[0] == '-h'
   ARGV[1] == '--help'
    puts "Usage: fetch_friends.rb <command>"
    puts "Where"
    puts "    <command> is a command taking three arguments"
    puts ""
    puts "        command <name> <surname> <email>"
    exit
end

$command = ARGV[0]

$NAME_RE="[A-Z.\-]+"
$NAMES_RE="[ A-Z.\-]+"
$GARBAGE_RE="[0-9\s()]*"

$ADDRESS_FIELDS = ['to', 'from', 'cc']

def default_ask(tin, query, default)
    puts "#{query} [#{default}]: "
    ans = tin.gets.chomp
    if ans == ""
        return default
    else
        return ans
    end
end

class Entry < Struct.new(:name, :surname, :email)
    def to_s
        return "#{name} +++ #{surname} +++ #{email}"
    end
end


def run_command(entry)
    puts "Running #{$command} on #{entry}"
    system "#{$command}", "#{entry.name}", "#{entry.surname}", "#{entry.email}"
end

$addies = []

def add_entry(name, surname, email)
    name = name ? name : ""
    surname = surname ? surname : ""
    $addies << Entry.new(name.capitalize,
                         surname.split.map(&:capitalize).join(' '),
                         email)
end

def guess_info_from_email(email)
    if email =~ /(#{$NAME_RE})\.(#{$NAME_RE})@.*/i
        return $1, $2
    else
        return nil, nil
    end
end


m = Mail.new(STDIN.read.encode(Encoding::ASCII, :invalid => :replace, :undef => :replace))

$ADDRESS_FIELDS.each do |field|
    if not m.header[field]
        next
    end

    begin
        m.header[field].addrs.each do |addy|
            if addy.display_name =~ /^(#{$NAME_RE})\s+(#{$NAMES_RE})#{$GARBAGE_RE}$/i
                add_entry($1, $2, addy.address)
            elsif addy.display_name =~ /^(#{$NAMES_RE}),\s+(#{$NAME_RE})#{$GARBAGE_RE}$/i
                add_entry($2, $1, addy.address)
            elsif addy.display_name =~ /^(#{$NAMES_RE})#{$GARBAGE_RE}$/i
                add_entry($1, "", addy.address)
            else
                name, surname = guess_info_from_email(addy.address)
                add_entry(name, surname, addy.address)
            end
        end
    rescue NoMethodError
        # ignore
    end
end

if $addies.length == 0
    exit
end

fd = IO.sysopen('/dev/tty', 'r')
tin = IO.new(fd, 'r')

$addies.each_with_index do |entry, i|
    puts "#{i}: #{entry}"
end

puts "Which to add? ('y[e]' all, 'n' none, or '1[e] 4[e] 5-7[e]', optional 'e' to edit)"
ans = tin.gets.chomp.upcase

additions = []
edits = []

case ans
when 'Y'
    additions = (0..$addies.length-1).to_a
when 'YE'
    edits = (0..$addies.length-1).to_a
when /^\s*([0-9]+(-[0-9]+)?e?\s+)*[0-9]+(-[0-9]+)?e?\s*$/i
    ans.split.each do |option|
        if option =~ /^[0-9]+$/
            additions << option.to_i
        elsif option =~ /^([0-9]+)e$/i
            edits << $1.to_i
        elsif option =~ /^([0-9]+)-([0-9]+)$/
            additions.concat(($1.to_i..$2.to_i).to_a)
        elsif option =~ /^([0-9]+)-([0-9]+)e$/i
            edits.concat(($1.to_i..$2.to_i).to_a)
        end
    end
else
    exit
end

additions.each do |i|
    run_command($addies[i])
end

if edits.length > 0
    puts "Enter blank to accept default."
end

edits.each do |i|
    entry = $addies[i]
    entry.name = default_ask(tin, "Name", entry.name)
    entry.surname = default_ask(tin, "Surname", entry.surname)
    entry.email = default_ask(tin, "Email", entry.email)
    run_command(entry)
end



