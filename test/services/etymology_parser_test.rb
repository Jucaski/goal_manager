require "test_helper"

class EtymologyParserTest < ActiveSupport::TestCase
  test "parses a single JSON object" do
    result = EtymologyParser.parse('{"type": "ideographic", "hint": "A tree 木 with its roots highlighted"}')
    assert_equal({ "type" => "ideographic", "hint" => "A tree 木 with its roots highlighted" }, result)
  end

  test "parses multiple comma-separated JSON objects into an array" do
    raw = '{"type": "pictophonetic", "phonetic": "巴", "semantic": "父", "hint": "father"}, {"type": "pictophonetic", "phonetic": "巴", "semantic": "父", "hint": "father"}'
    result = EtymologyParser.parse(raw)
    assert_instance_of Array, result
    assert_equal 2, result.size
    assert_equal "巴", result[0]["phonetic"]
  end

  test "parses arrays that contain empty objects" do
    raw = '{"type": "pictographic", "hint": "bird"}, {}, {"type": "ideographic", "hint": "sound"}'
    result = EtymologyParser.parse(raw)
    assert_equal 3, result.size
    assert_equal({}, result[1])
  end

  test "handles escaped quotes inside JSON strings" do
    raw = '{"type": "ideographic", "hint": "Two bent lines meaning \\"to divide\\""}'
    result = EtymologyParser.parse(raw)
    assert_equal 'Two bent lines meaning "to divide"', result["hint"]
  end

  test "still parses the legacy Python-dict format" do
    result = EtymologyParser.parse("{'type': 'pictophonetic', 'phonetic': '巴', 'semantic': '父', 'hint': 'father'}")
    assert_equal({ "type" => "pictophonetic", "phonetic" => "巴", "semantic" => "父", "hint" => "father" }, result)
  end

  test "returns nil for blank input" do
    assert_nil EtymologyParser.parse(nil)
    assert_nil EtymologyParser.parse("")
    assert_nil EtymologyParser.parse("   ")
  end
end
