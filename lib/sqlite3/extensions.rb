module SQLite3
  module Extensions
    def enable_load_extension(onoff=true)
      must_support_extensions!
      result = @driver.enable_load_extension(@handle, onoff)
      Error.check(result, self)
    end

    def disable_load_extension
      must_support_extensions!
      result = @driver.enable_load_extension(@handle, false)
      Error.check(result, self)
    end

    def load_extension(name, entry_point=nil)
      must_support_extensions!
      result, message = @driver.load_extension(@handle, name, entry_point)
      Error.check(result, self, message)
    end

    private

    def must_support_extensions!
      raise SQLite3::Exception, "extensions API not supported" unless @driver.extension_support?
    end
  end
end
