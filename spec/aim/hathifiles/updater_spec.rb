require "ostruct"

class FakeDeltaUpdate
  def self.new(connection:, hathifile:, output_directory:)
    OpenStruct.new(run: nil)
  end
end

RSpec.describe AIM::Hathifiles::Updater do
  before(:each) do
    @logger = instance_double(Logger, info: nil, error: nil)
    @connection = instance_double(HathifilesDatabase::DB::Connection, update_from_file: nil, rawdb: nil)
    @params = {
      date: "2023-05-02",
      logger: @logger,
      connection: @connection,
      delta_update_class: FakeDeltaUpdate
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#hathifile" do
    it "when date is given returns file_name" do
      expect(subject.hathifile).to eq("hathi_upd_20230502.txt.gz")
    end
    it "when filename is given returns the filename" do
      @params[:file_name] = "hathi_upd_20250105.txt.gz"
      expect(subject.hathifile).to eq("hathi_upd_20250105.txt.gz")
    end
    it "when filename and no date, returns filename" do
      @params[:file_name] = "hathi_upd_20250105.txt.gz"
      @params.delete(:date)
      expect(subject.hathifile).to eq("hathi_upd_20250105.txt.gz")
    end
  end
  it "empties the scratch directory even if there's an error" do
    stub_request(:get, "#{S.ht_host}/files/hathifiles/hathi_upd_20230502.txt.gz")
      .to_timeout
    expect { subject.run }.to raise_error(Faraday::ConnectionFailed)
    expect(Pathname.new(subject.scratch_dir)).not_to exist
  end
end

RSpec.describe AIM::Hathifiles do
  context ".update_for_files" do
    it "calls Updater with filenames in chronological order" do
      updater_stub = class_double(AIM::Hathifiles::Updater, new: double(run: nil))
      newest = "hathi_upd_20241103.txt.gz"
      middle = "hathi_upd_20241102.txt.gz"
      oldest = "hathi_upd_20241101.txt.gz"
      expect(updater_stub).to receive(:new).with({file_name: oldest}).ordered
      expect(updater_stub).to receive(:new).with({file_name: middle}).ordered
      expect(updater_stub).to receive(:new).with({file_name: newest}).ordered
      described_class.update_for_files([newest, oldest, middle], updater_stub)
    end
  end
end
