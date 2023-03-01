require "test_helper"

class Tldr::ScreenshotTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tldr::Screenshot::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
