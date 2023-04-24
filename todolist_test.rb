require 'simplecov'
require 'minitest/autorun'
require "minitest/reporters"


SimpleCov.start
Minitest::Reporters.use!

require_relative 'todolist'

class TodoListTest < MiniTest::Test

  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  # Your tests go here. Remember they must start with "test_"
  def test_to_a
    assert_equal(@list.to_a, @todos)
  end
  
  def test_size
    assert_equal(@list.size, 3)
  end
  
  def test_first
    assert_equal(@list.first, @todo1)
  end
  
  def test_last
    assert_equal(@list.last, @todo3)
  end
  
  def test_shift
    first_val = @list.shift
    assert_equal(@list.to_a, [@todo2, @todo3])
    assert_equal(first_val, @todo1)
  end
  
  def test_pop
    last_val = @list.pop
    assert_equal(@list.to_a, [@todo1, @todo2])
    assert_equal(last_val, @todo3)
  end
  
  def test_done?
    assert_equal(@list.done?, false)
    @todos.each { |todo| todo.done! }
    assert_equal(@list.done?, true)
  end
  
  def test_type_error_raised_on_invalid_add
    assert_raises(TypeError) { @list.add("ok") }
    assert_raises(TypeError) { @list << 5 }
  end
  
  def test_shovel
    @list << @todo3
    assert_equal([@todo1, @todo2, @todo3, @todo3], @list.to_a)
  end
  
  def test_add
    @list.add(@todo3)
    assert_equal([@todo1, @todo2, @todo3, @todo3], @list.to_a)
  end
  
  def test_item_at
    assert_raises(IndexError) { @list.item_at(4) } # out of bounds positive
    assert_raises(IndexError) { @list.item_at(-4) } # out of bounds negative
    assert_equal(@todo1, @list.item_at(0)) # retrieve positive
    assert_equal(@todo3, @list.item_at(-1)) # retrieve negative
  end
  
  def test_mark_done_at
    assert_raises(IndexError) { @list.mark_done_at(4) } # out of bounds positive
    assert_raises(IndexError) { @list.mark_done_at(-4) } # out of bounds negative
    @list.mark_done_at(0)
    @list.mark_done_at(-1)
    assert(@todo1.done?)
    refute(@todo2.done?)
    assert(@todo3.done?)
  end
  
  def test_mark_undone_at
    assert_raises(IndexError) { @list.mark_undone_at(4) } # out of bounds positive
    assert_raises(IndexError) { @list.mark_undone_at(-4) } # out of bounds negative
    @list.done!
    assert(@list.done?)
    @list.mark_undone_at(0)
    @list.mark_undone_at(-1)
    assert_equal(false, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end
  
  def test_done!
    @list.done!
    assert(@todos.all?(&:done?))
  end
  
  def test_remove_at
    assert_raises(IndexError) { @list.remove_at(4) } # out of bounds positive
    assert_raises(IndexError) { @list.remove_at(-4) } # out of bounds negative
    first = @list.remove_at(0)
    last = @list.remove_at(-1)
    assert_equal(@todo1, first)
    assert_equal(@todo3, last)
    assert_equal([@todo2], @list.to_a)
  end
  
  def test_to_s
    expected = <<~EXPECTEDSTRING.chomp
      ---- Today's Todos ----
      [ ] Buy milk
      [ ] Clean room
      [ ] Go to gym
      EXPECTEDSTRING
    assert_equal(expected, @list.to_s)
  end
  
  def test_to_s_one_todo_done
    @list.mark_done_at(1)
    expected = <<~EXPECTEDSTRING.chomp
      ---- Today's Todos ----
      [ ] Buy milk
      [X] Clean room
      [ ] Go to gym
      EXPECTEDSTRING
    assert_equal(expected, @list.to_s)
  end
  
  def test_to_s_all_todos_done
    @list.done!
    expected = <<~EXPECTEDSTRING.chomp
      ---- Today's Todos ----
      [X] Buy milk
      [X] Clean room
      [X] Go to gym
      EXPECTEDSTRING
    assert_equal(expected, @list.to_s)
  end
  
  def test_each
    expected = <<~EXPECTEDSTRING
      Buy milk
      Clean room
      Go to gym
    EXPECTEDSTRING
    assert_output(expected, nil) { @list.each { |todo| puts todo.title } }
  end
  
  def test_each_returns_caller
    assert_equal(@list, @list.each {})
  end
  
  def test_select
    selected_list = @list.select { |todo| todo.title < 'G'}
    assert_equal(selected_list.title, @list.title)
    assert_equal(selected_list.to_a, [@todo1, @todo2])
  end
  
  def test_find_by_title
    assert_equal(@todo3, @list.find_by_title("Go to gym"))
    assert_nil(@list.find_by_title("Go to space"))
  end
  
  def test_all_done
    assert_equal([], @list.all_done.to_a) # testing if no todos are done
    @todo2.done!
    list = TodoList.new(@list.title)
    list << @todo2
    assert_equal(list.to_s, @list.all_done.to_s) 
  end
  
  def test_all_not_done
    @todo1.done!
    @todo2.done!
    list = TodoList.new(@list.title)
    list << @todo3
    assert_equal(list.to_s, @list.all_not_done.to_s)
    @todo3.done!
    assert_equal([], @list.all_not_done.to_a) # testing if no todos are undone
  end
  
  def test_mark_done
    assert_nil(@list.mark_done("Go to space")) # invalid title returns nil
    @list.mark_done("Go to gym")
    assert(@todo3.done?)
  end
  
  def test_mark_all_done
    return_val = @list.mark_all_done
    assert_same(@list, return_val) # returns the calling object
    assert(@list.done?) # mutates
  end
  
  def test_mark_all_undone
    @todos.each(&:done!)
    return_val = @list.mark_all_undone
    assert_same(@list, return_val) # returns the calling object
    assert(!@list.to_a.any?(&:done?)) # mutates
  end
end