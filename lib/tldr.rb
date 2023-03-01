require 'tmpdir'
require 'rtesseract'
require 'openai'

module Tldr
  class << self
    def new
      api_key = ENV['OPENAI_ACCESS_TOKEN'] || load_api_key()
      unless api_key
        puts "Please provide your OpenAI API key:"
        api_key = gets.chomp
        save_api_key(api_key)
      end

      client = OpenAI::Client.new(access_token: api_key)

      Dir.mktmpdir do |dir|
        img_fpath = File.join(dir, 'screenshot')
        `screencapture -i #{img_fpath}`
        captured_string = RTesseract.new(img_fpath).to_s
        response = client.completions(
          parameters: {
            model: "text-davinci-003",
            prompt: "#{captured_string}. In summary: ",
            max_tokens: 256
          }
        )

        puts response["choices"].map { |c| c["text"] }
      end
    end

    def save_api_key(api_key)
      # Save the API key to in a file under ~/.config/tldr-screenshot/api_key
      # Create the directory if it doesn't exist
      config_dir = File.join(Dir.home, '.config', 'tldr-screenshot')
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)

      api_key_fpath = File.join(config_dir, 'api_key')
      puts "Saving API key to #{config_dir}"
      File.write(api_key_fpath, api_key)
    end

    def load_api_key
      # Load the API key from ~/.config/tldr-screenshot/api_key
      config_dir = File.join(Dir.home, '.config', 'tldr-screenshot')
      return nil unless Dir.exist?(config_dir)
      api_key_fpath = File.join(config_dir, 'api_key')
      File.read(api_key_fpath)
    end
  end
end
