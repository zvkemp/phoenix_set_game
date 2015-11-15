ExUnit.start
ExUnit.configure(exclude: :pending)

defmodule SetGameTest do
  use ExUnit.Case
  import SetGame

  @size 81

  test "#shuffled_deck" do
    assert Enum.count(SetGame.shuffled_deck) == @size
  end

  test "#standard_deck" do
    assert Enum.count(SetGame.standard_deck) == @size
  end

  Enum.each([colors, shapes, fills, counts], fn xs ->
    test "#[attrs]#{xs |> inspect}" do
      assert Enum.count(colors) == 3
    end
  end)
end

defmodule SetGameTest.CardTest do
  use ExUnit.Case
  import SetGame
  import SetGame.Card

  @all_attrs [colors, shapes, fills, counts]
  @first Enum.map(@all_attrs, &Enum.at(&1, 0))
  @last Enum.map(@all_attrs, &Enum.at(&1, 2))

  test "#encode first" do
    assert encode(@first) == 0
  end

  test "#encode last" do
    assert encode(@last) == 80
  end

  test "#decode first" do
    assert decode(0) == @first
  end

  test "#decode last" do
    assert decode(80) == @last
  end

  test "#decode out of range" do
    assert_raise(RuntimeError, fn -> decode(90) end)
    assert_raise(RuntimeError, fn -> decode(-10) end)
  end

  test "#bits first" do
    assert bits(0) == [0, 0, 0, 0]
  end

  test "#bits last" do
    assert bits(80) == [2, 2, 2, 2]
  end

  test '#decode map' do
    %{ color: c, fill: f, count: n, shape: s } = decode_map(0)
    assert c == :blue
    assert f == :solid
    assert n == 1
    assert s == :oval
  end
end

defmodule SetGameTest.SetTest do
  use ExUnit.Case
  import SetGame.Card
  import SetGame.Set

  test "#is_set? positive" do
    cards = [
      [:blue, :oval, :solid, 3],
      [:red, :squiggle, :stripes, 2],
      [:green, :diamond, :empty, 1]
    ] |> Enum.map(&encode/1)

    assert is_set?(cards)
  end

  test "#is_set? negative" do
    cards = [
      [:blue, :oval, :stripes, 3],
      [:red, :squiggle, :stripes, 2],
      [:green, :diamond, :empty, 2]
    ] |> Enum.map(&encode/1)

    refute is_set?(cards)
  end

  test "#is_set? duplicate cards" do
    cards = [
      [:blue, :oval, :stripes, 3],
      [:blue, :oval, :stripes, 3],
      [:blue, :oval, :stripes, 3]
    ] |> Enum.map(&encode/1)

    refute is_set?(cards)
  end
end

defmodule SetGameTest.DetectorTest do
  use ExUnit.Case
  import SetGame.Detector
  @tag :pending
  @game %SetGame.Game{ displayed: [0, 1, 2, 3, 4, 5, 6, 7, 8] }

  test "#hint(game)" do
    assert hint(@game) == [0, 1, 2]
  end

  test "#hint(detector)" do
    det = SetGame.Detector.new(@game.displayed)
    assert hint(det) == [0, 1, 2]
  end
end
