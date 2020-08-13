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


  At any point, instead of a single character guess you can type 'save'
  to save your game and quit.
  
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
        unless load_saved_game
          puts "\n"
          puts "There are no saved games. You'll have to start a new one."
          initialize_new_game
        end
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

  def load_saved_game
    saved_games = get_saved_games
    if saved_games == []
      false
    else
      puts 'Type the index of the save to load it'
      puts "\n"
      saved_games.each_with_index do |game, index|
        puts "#{index + 1}: #{game['word_progress'].join(' ')}, #{game['num_incorrect_guesses']}/6 incorrect guesses"
        puts "\n"
      end
      loop do
        print 'Pick save: '
        answer = gets.chomp.to_i
        case answer
        when 0
          puts 'Invalid input, try again.'
        else
          if !saved_games[answer - 1].nil?
            chosen_game = saved_games[answer - 1]
            @word = chosen_game['word']
            @word_split = chosen_game['word_split']
            @word_progress = chosen_game['word_progress']
            @num_incorrect_guesses = chosen_game['num_incorrect_guesses']
            @word_guessed = chosen_game['word_guessed']
            @incorrect_guesses = chosen_game['incorrect_guesses']
            @guessed_already = chosen_game['guessed_already']
            return true
          else
            puts 'Invalid input, try again.'
          end
        end
      end
    end
  end

  def save_game
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    saved_games = get_saved_games

    this_game = {
      'word' => @word,
      'word_split' => @word_split,
      'word_progress' => @word_progress,
      'num_incorrect_guesses' => @num_incorrect_guesses,
      'word_guessed' => @word_guessed,
      'incorrect_guesses' => @incorrect_guesses,
      'guessed_already' => @guessed_already
    }

    saved_games.push(this_game)
    serialized = Marshal.dump(saved_games)
    File.open('saved_games/saved_games.txt', 'w') do |file|
      file.puts serialized
    end
  end

  def get_saved_games
    if File.exist?('saved_games/saved_games.txt')
      saved_game_data = File.read('saved_games/saved_games.txt')
      Marshal.load(saved_game_data)
    else
      []
    end
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
      if guess == 'save'
        return guess
      end
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
    if guess == 'save'
      save_game
      puts 'Game saved. Goodbye!'
      puts "\n"
      exit
    end
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