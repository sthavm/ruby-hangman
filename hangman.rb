require_relative 'constants'

class Game
  def initialize; end

  def play
    display_welcome_message
    new_or_saved_game
    case game_loop
    when 0
      puts "\n"
      puts "You couldn't guess the word. It was #{@word.red}. Poor Linguus :("
    when 1
      puts "\n"
      puts "You guessed the word! It was #{@word.green}. Linguus is saved!"
    end
    puts "\n"
  end


  private
  def choose_random_word
    words = File.readlines('dictionary.txt')
    words.sample.chomp
  end

  def display_welcome_message
    puts <<-HEREDOC
===============================================================================================
                                            HANGMAN
===============================================================================================

  The town poet Linguus Verbi has been caught trying to steal a word 
  from the fearsome magistrate Diss Dain. He has been sentenced to 
  death by quantum-dislocated-hanging!

  He is doomed unless you can guess the word he was trying to steal.
  His fate now rests in your hands. Godspeed!
      
    HEREDOC
  end

  def new_or_saved_game
    puts 'Press (1) to start a new game'
    puts 'Press (2) to load a saved game'
    loop do
      case gets.chomp.to_i
      when 1
        initialize_new_game
        break
      when 2
        load_saved_game
        break
      else
        puts 'Invalid input'
      end
    end
  end

  def initialize_new_game
    @word = choose_random_word
    @word_split = @word.split('')
    @word_progress = Array.new(@word.length, '_')
    @num_incorrect_guesses = 0
    @word_guessed = false
    @incorrect_guesses = []
    @guessed_already = []
  end

  def game_loop
    until @num_incorrect_guesses == 6
      puts "Incorrect guesses: #{@num_incorrect_guesses}/6"
      display_art
      puts @word_progress.join(' ')
      puts "\n"
      puts "Incorrect guesses: #{@incorrect_guesses.join(' ')}"
      puts "\n"
      guess = get_guess
      evaluate_guess(guess)
      if win?
        @word_guessed = true
        break
      end
    end
    if @word_guessed
      1
    else
      display_art
      0
    end
  end

  def display_art
    puts ASCII_FOR_TRIES[@num_incorrect_guesses]
    puts "\n"
  end

  def get_guess
    print 'Type your guess (a single lowercase character): '
    loop do
      guess = gets.chomp
      if guess.length == 1
        if guess.ord >= 97 && guess.ord <= 122
          if @guessed_already.include?(guess)
            puts 'You guessed that already. Pick a different character.'
            print 'Try again: '
            next
          end
          @guessed_already.push(guess)
          return guess
        end
      end
      puts 'Invalid input. Only single lowercase characters allowed.'
      print 'Try again: '
    end
  end

  def evaluate_guess(guess)
    if @word_split.include?(guess)
      @word_split.each_with_index do |char, idx|
        if char == guess
          @word_progress[idx] = char
        end
      end
    else
      @incorrect_guesses.push(guess.red)
      @num_incorrect_guesses += 1
    end
  end

  def win?
    @word_split == @word_progress
  end
end

=begin

"hangman yay"
press 1 to start new game
press 2 to load a saved game



=end