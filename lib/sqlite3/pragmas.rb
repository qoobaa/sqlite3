# Copyright (c) 2004, Jamis Buck (jamis@jamisbuck.org)
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.

# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

# * The names of its contributors may not be used to endorse or
#   promote products derived from this software without specific prior
#   written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
