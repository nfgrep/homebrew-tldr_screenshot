require 'tmpdir'
require 'rtesseract'
require 'dotenv/load'
require 'openai'

module Tldr
  def initialize
    client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

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
end
