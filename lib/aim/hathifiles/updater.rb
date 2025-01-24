module AIM
  module Hathifiles
    class Updater < Modifier
      def hathifile
        @hathifile || "hathi_upd_#{@date_str}.txt.gz"
      end

      def command
        @connection.update_from_file "#{@scratch_dir}/#{hathifile}"
      end
    end
  end
end
