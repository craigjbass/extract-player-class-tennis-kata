class Player
  attr_reader :name, :points

  def initialize(name)
    @name = name
    @points = 0
  end

  def won_point!
    @points += 1
  end

  def won_against?(other_player)
    return false if @points < 4
    return true if @points == 4 && other_player.points < 4

    @points - other_player.points >= 2
  end
end

class Tennis
  def initialize(player_one_name, player_two_name)
    @player_one = Player.new(player_one_name)
    @player_two = Player.new(player_two_name)
  end

  def won_point(player_name)
    player = find_player(player_name)
    player.won_point!
  end

  def score
    return 'Deuce' if deuce?
    return "Advantage #{@player_one.name}" if advantage_player_one?
    return a_win_for(the_winning_player) unless no_winner?

    side_by_side_points
  end

  private

  def deuce?
    players.map(&:points).sum == 6
  end

  def advantage_player_one?
    difference = @player_one.points - @player_two.points == 1
    at_least_deuce = players.map(&:points).reject { |p| p < 3 }.count == 2
    difference && at_least_deuce
  end

  def players
    [@player_one, @player_two]
  end

  def find_player(player_name)
    players.select { |p| p.name == player_name }
           .first
  end

  def the_winning_player
    pairs = players.zip(players.reverse)
    pairs.select do |(a, b)|
      a.won_against?(b)
    end.dig(0, 0)
  end

  def no_winner?
    the_winning_player.nil?
  end

  def a_win_for(player)
    "#{player.name} wins"
  end

  def side_by_side_points
    "#{point(@player_one.points)}-#{point(@player_two.points)}"
  end

  def point(point)
    if point == 1
      'Fifteen'
    elsif point == 2
      'Thirty'
    elsif point == 3
      'Forty'
    else
      'Love'
    end
  end
end

# rubocop:disable Metrics/BlockLength
describe Tennis do
  def expect_score(expected_score, points:)
    game = Tennis.new(
      @player_one_name,
      @player_two_name
    )

    points.each do |point|
      game.won_point(
        point == 1 ? @player_one_name : @player_two_name
      )
    end

    expect(game.score).to eq(expected_score)
  end

  before do
    @player_one_name = 'Jane'
    @player_two_name = 'Bill'
  end

  it 'scores a new game' do
    expect_score('Love-Love', points: [])
  end

  it 'scores a simple game for player one' do
    expect_score('Fifteen-Love', points: [1])
    expect_score('Thirty-Love', points: [1] * 2)
    expect_score('Forty-Love', points: [1] * 3)
    expect_score('Jane wins', points: [1] * 4)
    expect_score('Jane wins', points: [1, 2, 1, 2, 1, 2, 1, 1])
  end

  it 'can use different winner names for player one' do
    @player_one_name = 'Jack'

    expect_score('Jack wins', points: [1] * 4)
  end

  it 'scores a simple game for player two' do
    expect_score('Love-Fifteen', points: [2])
    expect_score('Love-Thirty', points: [2] * 2)
    expect_score('Love-Forty', points: [2] * 3)
    expect_score('Bill wins', points: [2] * 4)
  end

  it 'can use different winner names for player two' do
    @player_two_name = 'Jerry'

    expect_score('Jerry wins', points: [2] * 4)
  end

  it 'can score when both players have won points' do
    expect_score('Thirty-Thirty', points: [1, 2, 1, 2])
  end

  it 'can score deuce' do
    expect_score('Deuce', points: [1, 2, 1, 2, 1, 2])
  end

  it 'can score advantage for Jane' do
    expect_score('Advantage Jane', points: [1, 2, 1, 2, 1, 2, 1])
    expect_score('Advantage Jane', points: [1, 2, 1, 2, 1, 2, 1, 2, 1])
  end

  it 'can score advantage for player one with different name' do
    @player_one_name = 'Merry'
    expect_score('Advantage Merry', points: [1, 2, 1, 2, 1, 2, 1])
    expect_score('Advantage Merry', points: [1, 2, 1, 2, 1, 2, 1, 2, 1])
  end

  xit 'can score win for Bill' do
    expect_score('Advantage Bill', points: [2, 1, 2, 1, 2, 1, 2])
  end
end
# rubocop:enable Metrics/BlockLength
