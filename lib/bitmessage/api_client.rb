require 'xmlrpc/client'
require 'json'
require 'base64'

module Bitmessage
  class ApiClient
    class Address
      attr_accessor :label, :address, :stream, :enabled

      def initialize hash, label_encoded = false
        self.label = label_encoded ? Base64.decode64(hash['label']) : hash['label']
        self.address = hash['address']
        self.stream = hash['stream'] if hash.keys.include?('stream')
        self.enabled = hash['enabled']
      end

      def to_s
        "#{self.label} (#{self.address})"
      end
    end

    class Message
      ENCODING_IGNORE = 0
      ENCODING_TRIVIAL = 1
      ENCODING_SIMPLE = 2

      FOLDER_UNKNOWN = :unknown
      FOLDER_INBOX = :inbox
      FOLDER_OUTBOX = :outbox

      # common attributes
      attr_accessor :msgid, :to, :from, :subject, :message, :encoding, :folder
      # inbox attributes
      attr_accessor :read, :received_at
      # outbox attributes
      attr_accessor :last_action_at, :status, :ack_data

      def initialize hash
        self.folder = FOLDER_UNKNOWN
        self.msgid = hash['msgid']
        self.to = hash['toAddress']
        self.from = hash['fromAddress']
        self.subject = Base64.decode64(hash['subject'])
        self.message = Base64.decode64(hash['message'])
        self.encoding = hash['encodingType'].to_i

        if hash.keys.include?('receivedTime')
          self.folder = FOLDER_INBOX
          self.received_at = Time.at(hash['receivedTime'].to_i)
          self.read = hash['read'] == 0 ? false : true
        elsif hash.keys.include?('ackData')
          self.folder = FOLDER_OUTBOX
          self.last_action_at = Time.at(hash['lastActionTime'].to_i)
          self.status = hash['status']
          self.ack_data = hash['ackData']
        end
      end

      def to_s
        self.msgid
      end
    end

    def initialize uri
      @client = XMLRPC::Client.new_from_uri(uri)
    end

    # Returns the sum of the integers. Used as a simple test of the API.
    def add a, b
      @client.call('add', a, b)
    end

    # Returns 'first_word-second_word'. Used as a simple test of the API.
    def hello_world first_word, second_word
      @client.call('helloWorld', first_word, second_word)
    end

    # Displays the message in the status bar on the GUI
    def status_bar text
      @client.call('statusBar', text)
    end

    # Lists all addresses
    def list_addresses
      json = JSON.parse(@client.call('listAddresses'))

      json['addresses'].map do |j|
        Address.new j
      end
    end

    # Creates one address using the random number generator.
    def create_random_address label, eighteen_byte_ripe = false, total_difficulty = 1, small_message_difficulty = 1
      @client.call(
        'createRandomAddress',
        Base64.encode64(label),
        eighteen_byte_ripe,
        total_difficulty,
        small_message_difficulty)
    end

    # Does not include trashed messages.
    def get_all_inbox_messages
      json = JSON.parse(@client.call('getAllInboxMessages'))
      json['inboxMessages'].map do |j|
        Message.new j
      end
    end
    
    def get_inbox_message_by_id msgid
      hash = JSON.parse(@client.call('getInboxMessageById', msgid))
      Message.new hash['inboxMessage'].first
    end

    def get_all_sent_messages
      json = JSON.parse(@client.call('getAllSentMessages'))
      json['sentMessages'].map do |j|
        Message.new j
      end
    end

    def get_sent_message_by_id msgid
      hash = JSON.parse(@client.call('getSentMessageById', msgid))
      Message.new hash['sentMessage'].first
    end

    def get_sent_message_by_ack_data ack_data
      hash = JSON.parse(@client.call('getSentMessageByAckData', ack_data))
      Message.new hash['sentMessage'].first
    end

    def get_sent_messages_by_sender sender
      json = JSON.parse(@client.call('getSentMessagesBySender', sender))
      json['sentMessages'].map do |j|
        Message.new j
      end
    end

    def trash_message msgid
      @client.call('trashMessage', msgid)
    end

    def send_message to, from, subject, message, encoding = Message::ENCODING_SIMPLE
      @client.call('sendMessage', to, from, Base64.encode64(subject), Base64.encode64(message), encoding)
    end

    def get_status ack_data
      @client.call('getStatus', ack_data)
    end

    def send_broadcast from, subject, message, encoding = Message::ENCODING_SIMPLE
      @client.call('sendBroadcast', from, Base64.encode64(subject), Base64.encode64(message), encoding)
    end

    def add_subscription address, label = ""
      @client.call('addSubscription', address, Base64.encode64(label))
    end

    def delete_subscription address
      @client.call('deleteSubscription', address)
    end

    def list_subscriptions
      hash = JSON.parse(@client.call('listSubscriptions'))

      hash['subscriptions'].map do |s|
        Address.new s, true
      end
    end
  end
end
