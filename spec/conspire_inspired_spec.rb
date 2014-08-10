require 'rspec'
require './lib/conspire_inspired'
require 'mail'
require 'faker'
require 'securerandom'
I18n.enforce_available_locales = false

CreateEmail = ->(sender, recipient, days_ago, in_reply_to = nil) {
  id = SecureRandom.uuid
  message = Mail.new do
    in_reply_to in_reply_to if in_reply_to
    to recipient
    from sender
    date Date.today - days_ago
    subject Faker::Lorem.sentence
    body Faker::Lorem.paragraphs.join("\n\n")
    message_id "<#{id}@example.com>"
  end
  File.open("./spec/data/#{id}.eml", "w") { |f| f.puts message.to_s }
  message.message_id
}

describe ConspireInspired do
  it 'parses email data from a path' do
    CreateEmail.("user@example.com", "otheruser@example.com", 7*4)

    ci = ConspireInspired.new('spec/data')

    expect(ci.emails).to_not be_nil
  end

  it 'finds current friends' do
    MakeCurrentFriends = ->(sender, recipient) {
      original = CreateEmail.(sender, recipient, 7*6)
      CreateEmail.(recipient, sender, 7*5, original)

      CreateEmail.(sender, recipient, 7*4)

      original = CreateEmail.(sender, recipient, 7*3)
      CreateEmail.(recipient, sender, 12, original)
    }
    MakeCurrentFriends.call("user@example.com", "otheruser@example.com")


    ci = ConspireInspired.new('spec/data')
    actual = ci.relationships("user@example.com")

    expected = {"otheruser@example.com" => "Current Friend"}

    expect(actual).to eq expected
  end

  it 'finds old friends' do
    MakeOldFriends = ->(sender, recipient) {
      [18, 20, 22, 24, 26, 28, 30, 32].each do |weeks_ago|
        original = CreateEmail.(sender, recipient, 7*weeks_ago)
        CreateEmail.(recipient, sender, 7*(weeks_ago - 1), original)
      end

      [15, 17].each do |weeks_ago|
        CreateEmail.(sender, recipient, 7*weeks_ago)
      end

      [16, 18].each do |weeks_ago|
        CreateEmail.(sender, recipient, 7*weeks_ago)
      end
    }
    MakeOldFriends.call("user@example.com", "otheruser@example.com")


    ci = ConspireInspired.new('spec/data')
    actual = ci.relationships("user@example.com")

    expected = {"otheruser@example.com" => "Old Friend"}

    expect(actual).to eq expected
  end

  after do
    Dir.glob("spec/data/*.eml").each do |file|
      File.delete(file)
    end
  end
end