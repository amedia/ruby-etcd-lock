require 'test_helper'

class Etcd::Lock::CoordinatorTest < Minitest::Test

  def client
    @client ||= Etcd::Lock::Coordinator.new('testapp')
  end

  def test_it_can_obtain_lock_and_returns_value
    assert_equal 256, client.run('test1', ttl: 1) { 2 ** 8 }
  end

  def test_it_raises_on_existing_lock
    client.run('test2', ttl: 1) { 2 + 2 }
    assert_raises(Etcd::Lock::LockExists) do
      client.run('test2', ttl: 1) { 3 + 3 }
    end
  end

  def test_it_removes_lock_after
    client.run('test3', ttl: 2, remove: true) { 2 + 2 }
    assert_equal 6, client.run('test3', ttl: 1, remove: true) { 3 + 3 }
  end

  def test_it_lock_persists_if_block_raises
    begin
      client.run('test4', ttl: 2, remove: true) { raise "Shit happens." }
    rescue
    end
    assert_raises(Etcd::Lock::LockExists) do
      client.run('test4', ttl: 1, remove: true) { 3 + 3 }
    end
  end
end
