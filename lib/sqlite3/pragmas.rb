module SQLite3

  # This module is intended for inclusion solely by the Database class. It
  # defines convenience methods for the various pragmas supported by SQLite3.
  #
  # For a detailed description of these pragmas, see the SQLite3 documentation
  # at http://sqlite.org/pragma.html.
  module Pragmas

    def table_info(table, &block) # :yields: row
      columns, *rows = execute2("PRAGMA table_info(#{table})")

      needs_tweak_default = version_compare(driver.libversion, "3.3.7") > 0

      result = [] unless block_given?
      rows.each do |row|
        new_row = {}
        columns.each_with_index do |name, index|
          new_row[name] = row[index]
        end

        tweak_default(new_row) if needs_tweak_default

        if block_given?
          yield new_row
        else
          result << new_row
        end
      end

      result
    end

    private

    # Compares two version strings
    def version_compare(v1, v2)
      v1 = v1.split(".").map { |i| i.to_i }
      v2 = v2.split(".").map { |i| i.to_i }
      parts = [v1.length, v2.length].max
      v1.push 0 while v1.length < parts
      v2.push 0 while v2.length < parts
      v1.zip(v2).each do |a,b|
        return -1 if a < b
        return  1 if a > b
      end
      return 0
    end

    # Since SQLite 3.3.8, the table_info pragma has returned the default
    # value of the row as a quoted SQL value. This method essentially
    # unquotes those values.
    def tweak_default(hash)
      case hash["dflt_value"]
      when /^null$/i
        hash["dflt_value"] = nil
      when /^'(.*)'$/
        hash["dflt_value"] = $1.gsub(/''/, "'")
      when /^"(.*)"$/
        hash["dflt_value"] = $1.gsub(/""/, '"')
      end
    end
  end

end
