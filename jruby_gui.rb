#encoding: utf-8

include Java

import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.geom.Ellipse2D
import java.awt.event.ActionListener
import javax.swing.JFrame
import javax.swing.JPanel
import javax.swing.KeyStroke
import javax.swing.AbstractAction

class PauseAction < AbstractAction
  def initialize(fastreader)
    super()
    @fastreader = fastreader
  end
  def actionPerformed(e)
    @fastreader.pause = !@fastreader.pause
  end
end

class RewindAction < AbstractAction
  def initialize(fastreader)
    super()
    @fastreader = fastreader
  end
  def actionPerformed(e)
    @fastreader.wordcounter -= 2
    while @fastreader.wordcounter > 0 && @fastreader.get_word !~ /\.$/
      @fastreader.wordcounter -= 1
    end
    @fastreader.wordcounter += 1
  end
end

class FastReader < JPanel
    attr_accessor :pause, :wordcounter

    def get_word
      @words[@wordcounter]
    end

    def initialize(*args)
        super(*args)
        @wordcounter = 0
        @words = File.read(ARGV[0]).lines.map{|x| x.split(/\s+/)}.flatten
        @word = "Press Enter"
        @wpm = 600
        self.getInputMap().put(KeyStroke.getKeyStroke("ENTER"), "pause")
        self.getActionMap().put("pause", PauseAction.new(self))
        self.getInputMap().put(KeyStroke.getKeyStroke("SPACE"), "replay")
        self.getActionMap().put("replay", RewindAction.new(self))
        @pause = true
        @runner = Thread.new do
          sentence_length = 0
          loop do
            if @pause
              sleep 0.1
              next
            end
            @word = get_word
            self.repaint
            @wordcounter += 1
            sleep (60.0/@wpm)*time_factor(@word, sentence_length)
            if @word =~ /\./
              sentence_length = 0
            else
              sentence_length += 1
            end
          end
        end
    end

    def paintComponent g
        super
        self.drawWord g
    end

    def hl_index(word)
      return case word.length
        when 1      then    0
        when 2..5   then    1
        when 6..9   then    2
        when 10..13 then    3
        else 4
      end
    end

    def time_factor(word, sentence_length)
      mult = 1
      mult *= 1.6 if word.length > 13
      mult *= 1.3 if word.length > 7 && word.length <=13
      mult *= 1.3 if word.length < 4
      mult *= 1.3 unless word =~ /^[a-zäüößÄÜÖß]+$/i
      mult *= 1.1 if word =~ /^[A-Z]+$/
      if word =~/[;:."?!]/
        mult *= 3.3 if sentence_length > 22
        mult *= 2.2 if sentence_length > 11 && sentence_length <= 22
      end

      return mult
    end

    def drawWord g
        rh = RenderingHints.new RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON
        rh.put RenderingHints::KEY_RENDERING, RenderingHints::VALUE_RENDER_QUALITY
        g.setRenderingHints rh

        g.setFont Font.new "Ubuntu Mono", Font::BOLD, 26
        metrics = g.getFontMetrics
        string  = @word
        i = hl_index(string)
        prefix  = string[0...i]
        hl      = string[i..i]
        postfix = string[i+1..-1]
        w = metrics.stringWidth(prefix)
        offset = 90
        g.drawString prefix, offset-w, 30
        g.setColor(Color::RED);
        g.drawString hl, offset, 30
        g.setColor(Color::BLACK);
        g.drawString postfix, offset+metrics.stringWidth(hl), 30
    end
end

class Example < JFrame

    def initialize
        super "FastReader"
        initUI
    end

    def initUI
        reader = FastReader.new
        self.getContentPane.add reader

        self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
        self.setSize 400, 60
        self.setLocationRelativeTo nil
        self.setVisible true
    end
end

Example.new
