require 'spec_helper'

RSpec.describe VolumeUp do
  it "has a version number" do
    expect(VolumeUp::VERSION).not_to be nil
  end

  it "defines custom error classes" do
    expect(VolumeUp::Error).to be < StandardError
    expect(VolumeUp::VolumeNotFoundError).to be < VolumeUp::Error
    expect(VolumeUp::BackupError).to be < VolumeUp::Error
    expect(VolumeUp::RestoreError).to be < VolumeUp::Error
  end
end
