require 'test_helper'

class Etcd::Lock::CoordinatorTest < Minitest::Test

  def client
    @client ||= Etcd::Lock::Coordinator.new('testapp')
  end

  def test_it_can_obtain_lock_and_returns_value
    assert_equal 256, client.run_with_lock('test1', 1) { 2 ** 8 }
  end

  def test_it_raises_on_existing_lock
    client.run_with_lock('test2', 1) { 2 + 2 }
    assert_raises(Etcd::Lock::LockExists) do
      client.run_with_lock('test2', 1) { 3 + 3 }
    end
  end

  def test_it_removes_lock_after
    client.run_with_lock('test3', 10, remove: true) { 2 + 2 }
    assert_equal 6, client.run_with_lock('test3', 1, remove: true) { 3 + 3 }
  end
end
