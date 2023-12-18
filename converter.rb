#!/usr/bin/env ruby

# Le format est comme tel

#  #Q Qui est le présentateur des 12 coups de midi ?.
#  ^ Jean-Luc Reichmann
#  A David Pujadas
#  B Anne-Sophie Lapix
#  C Louis Bodin
#  D Jean-Luc Reichmann

# utilisez le convertisseur comme suit:
# ruby converter.rb input_file
# cela créera un input_file.json
# vous pouvez aussi convertir plusieurs fichiers:
# ruby converter.rb input_file1 input_file2
# ou comme ceci
# ruby converter.rb folder/*

require 'json'
require 'pathname'

def stripAndEncode(str)
  return str.strip!.force_encoding('ISO-8859-1').encode('UTF-8')
end

ARGV.each do |file|
  if File.directory?(file)
    puts "#{file} est un dossier. Ignoré."
    next
  end

  questions = []
  question = {}

  File.open(file, "r") do |fh|
    while(line = fh.gets) != nil
      line = stripAndEncode(line)
      if line.start_with?('#Q ')
        question[:question] = line[3..-1]
        question[:category] = Pathname.new(file).basename
        until (line = fh.gets) == nil || line.start_with?('^ ') do
          line = stripAndEncode(line)
          question[:question] << "\n"
          question[:question] << line
        end
        line = stripAndEncode(line)
      end

      if line.start_with?('^ ')
        question[:answer] = line[2..-1]
      elsif ('A '..'Z ').include?(line[0..1])
        question[:choices] ||= []
        question[:choices] << line[2..-1]
      elsif line.empty?
        questions << question unless question.empty?
        question = {}
      end
    end
  end

  File.write("#{file}.json", questions.to_json)
end

