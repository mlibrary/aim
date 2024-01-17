module AIM
  class CLI
    class HathiTrust < Thor
      desc "set_digitizer", "sets digitizer for digifeeds items"
      long_desc <<~DESC
        Triggers the "Change Physical items information job" on the digifeeds
        set so that Statistics Note 1 has the value "umich". This will tell Google
        that Umich is the digitizer of the item. 
      DESC
      def set_digitizer
        start_time = Time.now.to_i
        AIM::HathiTrust::DigitizerSetter.configure
        AIM::HathiTrust::DigitizerSetter.new.run
        AIM::HathiTrust::DigitizerSetter.send_metrics(start_time)
      end
    end
  end
end

module AIM
  class CLI
    desc "hathi_trust SUBCOMMAND", "commands related to the HathiTrust and Google Books project"
    subcommand "hathi_trust", HathiTrust
  end
end
