require 'rspec'
require './lib/conspire_inspired'
require 'mail'
require 'faker'
require 'securerandom'
I18n.enforce_available_locales = false


describe ConspireInspired do
  it 'parses email data from a path' do
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
    CreateEmail.("user@example.com", "otheruser@example.com", 7*4)

    ci = ConspireInspired.new('spec/data')

    expect(ci.data).to_not be_nil
  end

  after do
    Dir.glob("spec/data/*.eml").each do |file|
      File.delete(file)
    end
  end
end