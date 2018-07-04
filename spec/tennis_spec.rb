class Tennis
  def initialize(player_one_name, player_two_name)
    @player_one_name = player_one_name
    @player_two_name = player_two_name
    @point = 0
    @point2 = 0
  end

  def won_point(player_name)
    if @player_one_name == player_name
      @point += 1
    else
      @point2 += 1
    end
  end

  def score
    return win(@player_one_name) if player_one_wins?
    return win(@player_two_name) if player_two_wins?

    side_by_side_points
  end

  private

  def player_one_wins?
    @point == 4
  end

  def player_two_wins?
    @point2 == 4
  end

  def win(player_name)
    "#{player_name} wins"
  end

  def side_by_side_points
    "#{point(@point)}-#{point(@point2)}"
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
end
# rubocop:enable Metrics/BlockLength
