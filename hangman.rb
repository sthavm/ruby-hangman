require 'constants'

class Game
  def initialize(tries = 0)
    @tries = tries
  end

  def choose_random_word
    words = File.readlines('dictionary.txt')
    @word = words.sample
  end
  
end