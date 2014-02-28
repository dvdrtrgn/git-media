require 'git-media/transport'
require 'socket'



class String
    def is_i?
       !!(self =~ /^[-+]?[0-9]+$/)
    end
end

module GitMedia
  module Transport
    class HashStash < Base

      def initialize(host, port)
        @host = host.chomp
        @port = port.chomp.to_i
      end

      def exist?(sha)
        begin
          s = TCPSocket.open(@host, @port)
          s.puts 'HAS'
          s.puts sha
          r = s.gets.chomp
          s.close
          return r == 'YES'
        rescue
          return false
        end
        
      end



      def get_file(sha, to_file)
  
        begin
          s = TCPSocket.open(@host, @port)

          s.puts 'GET'
          s.puts sha

          size = s.gets.chomp

          if !size.is_i?
            STDERR.puts "File missing on stash: "+sha[0..8]
            s.close
            return false
          end


          file = File.open(to_file, 'w')
          file.binmode
          while !s.eof
            file.write s.read
          end
          file.close

          s.close
          return true
        rescue Exception => e
          STDERR.puts e.message
          return false
        end

      end


      def put_file(sha, from_file)
        begin
          s = TCPSocket.open(@host, @port)
          s.puts 'SET'
        
          length = File.size(from_file)

          s.puts length.to_s
       
          file = File.open(from_file, 'r')
          file.binmode
          while !file.eof
            s.write file.read
          end 
          file.close

          s.close
          return true

        rescue Exception => e
          STDERR.puts e.message
          return false
        end

      end


    end
  end
end