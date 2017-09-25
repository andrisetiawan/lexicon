require 'csv'
require 'json'
require 'smarter_csv'
require 'pry'
require 'redis'

class Importer
  def initialize(file_path)
    @file_path = file_path
    @redis = Redis.new
  end

  def import
    puts "Importing #{@file_path}... to redis."

    n = SmarterCSV.process(@file_path, {chunk_size:100, convert_values_to_numeric: false}) do |chunk|
      chunk.each do |row|
        @redis.sadd('LEXICON::types', row[:type].downcase)
        @redis.sadd('LEXICON::words', row[:word].downcase)
        @redis.set("LEXICON::word.type::#{row[:word].downcase}", row[:type].downcase)
      end
    end

    puts "Import process done."
  end
end


Importer.new('./../kata_dasar_kbbi.csv').import