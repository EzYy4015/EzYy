require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

#Constant variables
SCREEN_WIDTH = 1900
SCREEN_HEIGHT = 1000

#Game Window
class GameWindow < Gosu::Window

  def initialize
      #Variables will be assigned here
      super(SCREEN_WIDTH, SCREEN_HEIGHT)
      self.caption = "Galaxy Game"
      #Background picture
      @background = Gosu::Image.new('Icons/back.png')
      #Picture in GameOver screen
      @planepic = Gosu::Image.new('Icons/planepic.png')
      #Player picture
      @player = Jet.new
      #Array use to display enemies
      @enemy = Array.new
      @enemy1 = Array.new
      @enemy2 = Array.new
      @enemy3 = Array.new
      #This is used as a timer to generate enemy
      @plusenemy = 0
      #To show whether my game is running
      @run= true
      #To show player's lives
      @live = Gosu::Font.new(50)
      #To show player's points
      @point = Gosu::Font.new(50)
      #Audio for exploding and shooting
      @missile_sound = Gosu::Song.new("Audio/MissileSound.mp3")
      @boomaudio = Gosu::Song.new("Audio/Explosion.mp3")
  end

  def update

    #If my game runs, it will allow the enemies to move
    if @run
      @enemy.each { |enemy| enemy.move }
      @enemy1.each { |enemy| enemy.move }
      @enemy2.each { |enemy| enemy.move }
      @enemy3.each { |enemy| enemy.move }
      #If the player collides with the enemy, it will play an explosion audio and resets the coordinates of the enemy
      if @player.explode? @enemy
        #Play explosion music
        @boomaudio.play
        #Stops the program from running
        @run = false
        #Resets enemy's coordinates
        @enemy.each { |enemy| enemy.dontmove }
      #For the second type of enemy
      elsif @player.explode? @enemy1
        @boomaudio.play
        @run = false
        @enemy1.each { |enemyy| enemyy.dontmove }
      #For the third type of enemy
      elsif @player.explode? @enemy2
        @boomaudio.play
        @run = false
        @enemy2.each { |enemyyy| enemyyy.dontmove }
      #For the fourth type of enemy
      elsif @player.explode? @enemy3
        @boomaudio.play
        @run = false
        @enemy3.each { |enemyyyy| enemyyyy.dontmove }
      else
        run_game
      end
    end

    #This is written to allow player's resurrection by pressing keybutton"r" after being hit by enemies
    #This statement also runs under the condition when the player's live is more than zero
    if @run == false and button_down? Gosu::Button::KbR and @player.lives > 0
      @run = true
      #Allows enemy to move again
      @enemy.each { |enemy| enemy.move }
      @enemy1.each { |enemy| enemy.move }
      @enemy2.each { |enemy| enemy.move }
      @enemy3.each { |enemy| enemy.move }
    end

    #If the ability of the player hits the enemy, it will be remove from the window displayed
    if @player.bullet_hit? @enemy
      #Enemy will be removed from the window
      @enemy.each {|enemy| enemy.dontdraw }
    elsif  @player.bullet_hit2? @enemy1
      @enemy1.each {|enemy| enemy.dontdraw }
    elsif  @player.bullet_hit3? @enemy2
      @enemy2.each {|enemy| enemy.dontdraw }
    elsif   @player.bullet_hit4? @enemy3
      @enemy3.each {|enemy| enemy.dontdraw }
    end

    #This is where the player's movement and ability gets updated
    #Player moves left
    if Gosu.button_down? Gosu::Button::KbLeft
      @player.move_left
    end
    #Player moves right
    if Gosu.button_down? Gosu::Button::KbRight
      @player.move_right
    end
    #Player moves up
    if Gosu.button_down? Gosu::Button::KbUp
      @player.move_up
    end
    #Player moves down
    if Gosu.button_down? Gosu::Button::KbDown
      @player.move_down
    end
    #This detects whether the user presses the SpaceBar to trigger its ability
    if Gosu.button_down? Gosu::Button::KbSpace
      if @player.lives > 0
        #Player uses ability
        @player.shoot
        #The ability audio will be played
        @missile_sound.play
      elsif @run == false
        @player.dontshoot
      end
    end

    #To make sure ability is functionable
    @player.update

    #This is the enemy generator used to produce different enemies as time passes
    #Enemies are pushed into the array under different circumstances
    @plusenemy = @plusenemy + 0.5
    if (@plusenemy == 2)
      @enemy.push(generate_enemy)
    elsif (@plusenemy == 100)
			@enemy1.push(generate_enemy2)
    elsif (@plusenemy == 150)
      @enemy2.push(generate_enemy3)
    elsif (@plusenemy == 200)
      @enemy3.push(generate_enemy4)
    end

  end

  #This ensures the abilities will be updated after run_game is called
  def run_game
    @player.update
  end

  #Background, player, enemies, lives' text, points' text, GameOver interface are all drawn here
  def draw
    @background.draw_rot(950.5, 500, ZOrder::BACKGROUND)
    @player.draw
    @enemy.each  {|enemy| enemy.draw}
    @enemy1.each {|enemy| enemy.draw}
    @enemy2.each {|enemy| enemy.draw}
    @enemy3.each {|enemy| enemy.draw}
    @live.draw_text("Lives: #{@player.lives}", 10, 10, 1.0, 1.0, 1.0, 0xffffffff)
    @point.draw_text("Points: #{@player.score}", 1700, 10, 1.0, 1.0, 1.0, 0xffffffff)

    #If player's live equals zero, the GameOver interface will be drawn
    if @player.lives == 0
      @background.draw_rot(950.5, 500, ZOrder::TOP)
      @planepic.draw_rot(550, 510, ZOrder::TOP)

    end
  end

  #Methods of changing the types of enemies in the game
  def generate_enemy
  Target.new("Icons/enemy.png")
  end
  def generate_enemy2
  Target2.new("Icons/enemy2.png")
  end
  def generate_enemy3
  Target3.new("Icons/enemy3.png")
  end
  def generate_enemy4
  Target4.new("Icons/enemy4.png")
  end

  #Press "Esc" button to exit this game
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

#Player's class
class Jet

  #Reads instance vaiables assigned
  attr_reader :move_left, :move_right, :move_up, :move_down, :lives, :score, :x, :y, :m, :n, :alive, :enemyalive, :total

  #Variables are assigned here
  def initialize
    #PLayer's and ability's coordinates
    @x = @m = 900
    @y = @n = 900
    #Image of the player, ability, explosion and enemies
    @plane = Gosu::Image.new('Icons/plane1.png')
    @boom = Gosu::Image.new('Icons/explosion.png')
    @bullet = Gosu::Image.new('Icons/bullet.png')
    @enemy = Gosu::Image.new('Icons/enemy.png')
    #Explosion's boolean value
    @explode = false
    #Player's life value
    @lives = 3
    #Player's initial score value
    @score = 0
    #Using ability's boolean value
    @shooting = false
    #Enemy's existence boolean value
    @alive = false
    #Enemy's existence boolean value 2
    @enemyalive = true
    #GAME OVER and total points statement in Game Over interface
    @theend = Gosu::Font.new(100)
    @total = Gosu::Font.new(80)
  end

  #Whether player uses ability
  def shoot
    @shooting = true
  end

  def dontshoot
    @shooting = false
  end

  #Ability's movement
  def update
    if @shooting
        @n = @n - 10
        if @n < 0
            @shooting = false
        end
    else
        @m = @x
        @n = @y
    end
  end

  #PLayer's movement
  #Player moves left
  def move_left
    @x = @x - 10
    if @x < 0
      @x = 0
    end
  end
  #Player moves right
  def move_right
    @x = @x + 10
    if @x >  SCREEN_WIDTH-200
       @x =  SCREEN_WIDTH-200
    end
  end
  #Player moves up
  def move_up
    @y = @y - 10
    if @y < 100
      @y = 100
    end
  end
  #Player moves down
  def move_down
    @y = @y + 10
    if @y>  SCREEN_HEIGHT - 100
       @y = SCREEN_HEIGHT - 100
    end
  end

  #Draw images of explosion, player, ability and enemy
  def draw

     #If player explodes, draw explosion
     if @explode
       @boom.draw_rot(@x+100, @y, ZOrder::TOP)
     else
       @plane.draw_rot(@x+100, @y, ZOrder::TOP)
       @bullet.draw_rot(@m+100, @n, ZOrder::MIDDLE)
     end

     #Draw enemy once the game started
     if @alive and @enemyalive
       @enemy.draw_rot(@m, @n-200, ZOrder::MIDDLE)
     end

     #If lives equals zero, Game Over text will be drawn, together with the total points the player archieved
     if @lives == 0
       @theend.draw_text("GAME OVER", 695, 430, 3.0, 1.0, 1.0, 0xffffffff)
       @total.draw_text("Total Score: #{self.score}", 730, 530, 3.0, 1.0, 1.0, 0xffffffff)
     end
   end

   #Determine whether the player explodes under circumstances set
   def explode? (enemies)
     @explode = enemies.any? {|enemyy| Gosu::distance(@x, @y, enemyy.a, enemyy.b) < 140}
     #If player explodes, deduct its live points by one
     if @explode
       @lives = @lives -1
     end
     @explode
     end

   #Determine whether the enemy explodes under circumstances set
   def bullet_hit? (enemies)
     @alive = enemies.any? {|enemyy| Gosu::distance(@m, @n, enemyy.a, enemyy.b) < 100}
     #If enemy explodes, player gets one score point
     if @alive
       @score = @score +1
       @enemyalive = false
     end
     @alive
   end
   def bullet_hit2? (enemies)
     @alive = enemies.any? {|enemyy| Gosu::distance(@m, @n, enemyy.a, enemyy.b) < 100}
     #If enemy explodes, player gets two score points
     if @alive
       @score = @score +2
       @enemyalive = false
     end
     @alive
   end
   def bullet_hit3? (enemies)
     @alive = enemies.any? {|enemyy| Gosu::distance(@m, @n, enemyy.a, enemyy.b) < 100}
     #If enemy explodes, player gets three score points
     if @alive
       @score = @score +3
       @enemyalive = false
     end
     @alive
   end
   def bullet_hit4? (enemies)
     @alive = enemies.any? {|enemyy| Gosu::distance(@m, @n, enemyy.a, enemyy.b) < 100}
     #If enemy explodes, player gets four score points
     if @alive
       @score = @score +4
       @enemyalive = false
     end
     @alive
   end
end

#First enemy's class (with the slowest speed with one point)
class Target

    #Reads instance vaiables assigned
    attr_reader :a, :b

    #Variables assigned here, (image) is passed to GameWindow
    def initialize(image)
        #Random coordinates for enemy
        @a = rand(1800)
        @b = 100
        #Enemy image
        @enemy = Gosu::Image.new(image);
    end

    def update
    end

    #Draw enemy
    def draw
       @enemy.draw_rot(@a, @b, ZOrder::MIDDLE, center_x = 0.0, center_y = 0.0)
    end

    #Enemy's movement
    def move
      @b = @b + 10
      #If the enemy goes beyond the screen, it will randomize the x-coordinate
      if @b>  SCREEN_HEIGHT - 100
         @b = 100
         @a = rand(100..1700)
       end
    end

    #Ensure the enemy is waiting outside the screen with its x-coordinate randomized so it does not interfere with the running program
    def dontmove
      @b = -200
      @a = rand(100..1700)
    end

    #Ensure the enemy is removed so it does not interfere with the running program yet randomize its x-coordinate
    def dontdraw
      @b = -200
      @a = rand(100..1700)
    end
end

#Second enemy's class (with moderate speed and two points)
class Target2

    #Reads instance vaiables assigned
    attr_reader :a, :b

    #Variables assigned here, (image) is passed to GameWindow
    def initialize(image)
        #Random coordinates for enemy
        @a = rand(1800)
        @b = 100
        #Enemy image
        @enemy = Gosu::Image.new(image);
    end

    def update
    end

    #Draw enemy
    def draw
       @enemy.draw_rot(@a, @b, ZOrder::MIDDLE, center_x = 0.0, center_y = 0.0)
    end

    #Enemy's movement
    def move
      @b = @b + 15
      #If the enemy goes beyond the screen, it will randomize the x-coordinate
      if @b>  SCREEN_HEIGHT - 100
         @b = 100
         @a = rand(100..1700)
      end
    end

    #Ensure the enemy is waiting outside the screen with its x-coordinate randomized so it does not interfere with the running program
    def dontmove
      @b = -200
      @a = rand(100..1700)
    end

    #Ensure the enemy is removed so it does not interfere with the running program yet randomize its x-coordinate
    def dontdraw
      @b = -200
      @a = rand(100..1700)
    end
end

#Third enemy's class (with more faster speed and three points)
class Target3

  #Reads instance vaiables assigned
  attr_reader :a, :b

  #Variables assigned here, (image) is passed to GameWindow
  def initialize(image)
      #Random coordinates for enemy
      @a = rand(1800)
      @b = 100
      #Enemy image
      @enemy = Gosu::Image.new(image);
  end

  def update
  end

  #Draw enemy
  def draw
     @enemy.draw_rot(@a, @b, ZOrder::MIDDLE, center_x = 0.0, center_y = 0.0)
  end

  #Enemy's movement
  def move
    @b = @b + 17
    #If the enemy goes beyond the screen, it will randomize the x-coordinate
    if @b>  SCREEN_HEIGHT - 100
       @b = 100
       @a = rand(100..1700)
    end
  end

  #Ensure the enemy is waiting outside the screen with its x-coordinate randomized so it does not interfere with the running program
  def dontmove
    @b = -200
    @a = rand(100..1700)
  end

  #Ensure the enemy is removed so it does not interfere with the running program yet randomize its x-coordinate
  def dontdraw
    @b = -200
    @a = rand(100..1700)
  end
end

#Fourth enemy's class (with the fastest speed and four points)
class Target4

  #Reads instance vaiables assigned
  attr_reader :a, :b

  #Variables assigned here, (image) is passed to GameWindow
  def initialize(image)
      @a = rand(1800)
      @b = 100
      #Enemy image
      @enemy = Gosu::Image.new(image);
  end

  def update
  end

  #Draw enemy
  def draw
     @enemy.draw_rot(@a, @b, ZOrder::MIDDLE, center_x = 0.0, center_y = 0.0)
  end

  #Enemy's movement
  def move
    @b = @b + 20
    #If the enemy goes beyond the screen, it will randomize the x-coordinate
    if @b>  SCREEN_HEIGHT - 100
       @b = 100
       @a = rand(100..1700)
     end
  end

  #Ensure the enemy is waiting outside the screen with its x-coordinate randomized so it does not interfere with the running program
  def dontmove
    @b = -200
    @a = rand(100..1700)
  end

  #Ensure the enemy is removed so it does not interfere with the running program yet randomize its x-coordinate
  def dontdraw
    @b = -200
    @a = rand(100..1700)
  end

end

#Display the GameWindow class
GameWindow.new.show if __FILE__ == $0

#Allow users to create and store their points earned
def main
  #Create a new txt file
  scorefile = File.new("YourScore.txt", "w")
  #Write the score inside this file
  scorefile = File.new("YourScore.txt", "r")
  #This will be shown in the Command Prompt interface
  puts "Your Score History: "
    while(scorefile.eof == false)
     myscore = scorefile.gets
     puts myscore
  end
end

main
