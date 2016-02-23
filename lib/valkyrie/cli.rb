require "valkyrie/database"
require "valkyrie/progress_bar"

class Valkyrie::CLI

  def self.start(*args)
    url1 = args.shift
    url2 = args.shift
    table_from = args.shift
    table_to = args.shift

    unless url1 && url2
      puts "valkyrie FROM TO *optional(TABLE_FROM TABLE_TO)"
      exit 1
    end

    db1 = Valkyrie::Database.new(url1)
    db2 = Valkyrie::Database.new(url2)

    progress = nil

    if table_to.nil? && table_from.nil?
      db1.transfer_to(db2) do |type, data|
        case type
        when :tables      then puts "Transferring #{data} tables:"
        when :table       then progress = Valkyrie::ProgressBar.new(data.first, data.last, $stdout)
        when :row         then progress.inc(data)
        when :end         then progress.finish
        end
      end
    else
      db1.transfer_table_to(table_from.to_sym, table_to.to_sym, db2) do |type, data|
        case type
        when :table       then progress = Valkyrie::ProgressBar.new(data.first, data.last, $stdout)
        when :row         then progress.inc(data)
        when :end         then progress.finish
        end
      end
    end
  rescue Interrupt
    puts
    puts "ERROR: Transfer aborted by user"
  end

end
