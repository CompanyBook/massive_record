module Thrift
  class Socket < BaseTransport

    def write(str)
      raise IOError, "closed stream" unless open?
      begin
        if @timeout.nil? or @timeout == 0
          @handle.write(str)
        else
          len = 0
          start = Time.now
          while Time.now - start < @timeout
            rd, wr, = IO.select(nil, [@handle], nil, @timeout)
            if wr and not wr.empty?
              len += @handle.write_nonblock(str[len..-1])
              break if len >= str.length
            end
          end
          if len < str.length
            raise TransportException.new(TransportException::TIMED_OUT, "Socket: Timed out writing #{str.length} bytes to #{@desc}")
          else
            len
          end
        end
      rescue TransportException => e
        # pass this on
        raise e
      rescue StandardError => e
        @handle.close
        @handle = nil
        raise TransportException.new(TransportException::NOT_OPEN, e.message)
      end
    end

    def read(sz)
      raise IOError, "closed stream" unless open?

      begin
        if @timeout.nil? or @timeout == 0
          data = @handle.readpartial(sz)
        else
          data = _read_nonblocking(sz)
        end
      rescue TransportException => e
        # don't let this get caught by the StandardError handler
        raise e
      rescue StandardError => e
        @handle.close unless @handle.closed?
        @handle = nil
        raise TransportException.new(TransportException::NOT_OPEN, e.message)
      end
      if (data.nil? or data.length == 0)
        raise TransportException.new(TransportException::UNKNOWN, "Socket: Could not read #{sz} bytes from #{@desc}")
      end
      data
    end

    def _read_nonblocking(sz)
      # it's possible to interrupt select for something other than the timeout
      # so we need to ensure we've waited long enough, but not too long
      timespent = 0
      start = Time.now
      begin
        data = @handle.read_nonblock(sz)

      rescue IO::WaitReadable
        if timespent < @timeout && IO.select([@handle], nil, nil, @timeout - timespent)
          timespent = Time.now - start
          retry
        else
          raise TransportException.new(TransportException::TIMED_OUT, "Socket: Timed out reading #{sz} bytes from #{@desc}")
        end
      end
      data
    rescue EOFError
      raise Errno::ECONNRESET
    end
  end
end
