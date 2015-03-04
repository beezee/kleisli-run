require 'test_helper'

class RunTest < Minitest::Test

  def sums(a, b)
    a + b
  end

  def test_completion
    s = Kleisli.run do
      a from: Success(3)
      b from: Success(4)
      sums(a, b)
    end
    assert(Success(7), s)
  end

  def test_completion_mixed_types
    s = Kleisli.run do
      a from: Success(3)
      b from: Some(4)
      sums(a, b)
    end
    assert(Success(7), s)

    s = Kleisli.run do
      a from: Some(3)
      b from: Success(4)
      sums(a, b)
    end
    assert(Some(7), s)

    s = Kleisli.run do
      a from: Right(3)
      b from: Success(4)
      c from: Some(5)
      sums(c, sums(a, b))
    end
    assert(Right(12), s)
  end

  def test_short_circuit
    s = Kleisli.run do
      a from: Some(3)
      b from: None()
      c from: Some(5)
      sums(c, sums(a, b))
    end
    assert(None(), s)

    s = Kleisli.run do
      a from: Success(3)
      b from: Failure(['nopenope'])
      g from: Failure(['heyo'])
      c from: Success(5)
      sums(c, sums(a, b))
    end
    assert(Failure(['nopenope']), s)
  end

  def test_short_circuit_mixed_types
    s = Kleisli.run do
      a from: Some(3)
      b from: Failure(['nopenope'])
      g from: None()
      c from: Success(5)
      sums(c, sums(a, b))
    end
    assert(Failure(['nopenope']), s)
  end

  def test_inline_assignment
    s = Kleisli.run do
      a from: Some(3)
      b = 4
      c from: Success(5)
      sums(c, sums(a, b))
    end
    assert(Some(12), s)

    s = Kleisli.run do
      a = Success(1)
      b = Failure(b: "no num")
      c = Failure(c: "still no num")
      d from: Success(-> x, y, z { x + y + z }) * a * b * c
      e = sums(d, 3)
    end
    assert(Failure(b: "no num", c: "still no num"), s)

    s = Kleisli.run do
      a = Success(1)
      b = Success(2)
      c = Success(3)
      d from: Success(-> x, y, z { x + y + z }) * a * b * c
      e = sums(d, 4)
    end
    assert(Success(10), s)
  end

end
