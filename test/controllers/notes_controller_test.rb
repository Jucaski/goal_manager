require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "index shows notes and tags" do
    user = users(:one)
    user.notes.create!(title: "Reading", note_type: "typed", content: "Books I want to read", tags: [ "books" ])

    get notes_url
    assert_response :success
    assert_select "h1", "Notes"
    assert_select "a", text: /#books/
  end

  test "search finds typed notes by content" do
    users(:one).notes.create!(title: "Grocery", note_type: "typed", content: "Buy milk and eggs")

    get notes_url, params: { q: "milk" }
    assert_response :success
    assert_select "a", text: "Grocery"
  end

  test "search finds handwritten notes by recognized text" do
    users(:one).notes.create!(title: "Sketch", note_type: "handwritten", content: nil, ocr_text: "remember the password", drawing_data: [ [ { "x" => 0, "y" => 0 } ] ])

    get notes_url, params: { q: "password" }
    assert_response :success
    assert_select "a", text: "Sketch"
  end

  test "tag filter groups notes by tag" do
    user = users(:one)
    user.notes.create!(title: "Book note", note_type: "typed", content: "a", tags: [ "books" ])
    user.notes.create!(title: "Work note", note_type: "typed", content: "b", tags: [ "work" ])

    get notes_url, params: { tag: "books" }
    assert_response :success
    assert_select "a", text: "Book note"
    assert_select "a", text: "Work note", count: 0
  end

  test "type filter shows only handwritten notes" do
    user = users(:one)
    user.notes.create!(title: "Typed one", note_type: "typed", content: "a")
    user.notes.create!(title: "Drawn one", note_type: "handwritten", content: nil, drawing_data: [ [ { "x" => 0, "y" => 0 } ] ])

    get notes_url, params: { type: "handwritten" }
    assert_response :success
    assert_select "a", text: "Drawn one"
    assert_select "a", text: "Typed one", count: 0
  end

  test "new note shows drawing canvas" do
    get new_note_url
    assert_response :success
    assert_select "canvas[data-drawing-pad-target=canvas]"
    assert_select "script[src*='tesseract']"
  end

  test "create typed note" do
    assert_difference("users(:one).notes.count") do
      post notes_url, params: { note: { title: "Hello", note_type: "typed", content: "World", tags_string: "#books #ideas" } }
    end

    note = users(:one).notes.last
    assert_redirected_to note_url(note)
    assert_equal [ "books", "ideas" ], note.tags
  end

  test "create handwritten note stores drawing and recognized text" do
    assert_difference("users(:one).notes.count") do
      post notes_url, params: {
        note: {
          title: "Sketch", note_type: "handwritten",
          drawing_data: "[{\"x\":1,\"y\":2},{\"x\":3,\"y\":4}]",
          ocr_text: "hello there"
        }
      }
    end

    note = users(:one).notes.last
    assert_equal [ { "x" => 1, "y" => 2 }, { "x" => 3, "y" => 4 } ], note.drawing_data
    assert_equal "hello there", note.ocr_text
  end

  test "handwritten note without drawing is invalid" do
    assert_no_difference("users(:one).notes.count") do
      post notes_url, params: { note: { title: "Empty", note_type: "handwritten", drawing_data: "[]" } }
    end
    assert_response :unprocessable_content
  end

  test "update note" do
    note = users(:one).notes.create!(title: "Old", note_type: "typed", content: "a")

    patch note_url(note), params: { note: { title: "New", content: "b" } }
    assert_redirected_to note_url(note)
    assert_equal "New", note.reload.title
  end

  test "show renders handwritten drawing" do
    note = users(:one).notes.create!(title: "Sketch", note_type: "handwritten", content: nil, drawing_data: [ [ { "x" => 0, "y" => 0 } ] ])

    get note_url(note)
    assert_response :success
    assert_select "canvas[data-drawing-pad-target=canvas]"
    assert_select "[data-drawing-pad-read-only-value=true]"
  end

  test "destroy deletes the note" do
    note = users(:one).notes.create!(title: "Temp", note_type: "typed", content: "a")

    assert_difference("users(:one).notes.count", -1) do
      delete note_url(note)
    end
    assert_redirected_to notes_url
  end
end
