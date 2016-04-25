import java.util.Timer;
import java.util.TimerTask;
import beads.*; // import the beads library

float eRadius = 85;

class BeatDetector {
  int delays = 1000;  // The delay from line generation to musci beats 
  int target_interval = 500;  // Target interval of beats, will dynamicly affect threshold

  int last_beat;
  float default_threshold = (float)1e-10;
  float cur_threshold = default_threshold;

  AudioContext ac; // create our AudioContext
  AudioContext ac2;
  Gain gain;
  Gain gain2;
  PeakDetector peakDetector;

  BeatDetector() {
    // set up the AudioContext and the master Gain object
    ac = new AudioContext();
    gain = new Gain(ac, 1, 0.1);
    ac.out.addInput(gain);

    // set up the ShortFrameSegmenter
    // this class allows us to break an audio stream into discrete chunks
    ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
    sfs.setChunkSize(2048); // how large is each chunk?
    sfs.setHopSize(441);
    sfs.addInput(ac.out); // connect the sfs to the AudioContext

    beads.FFT fft = new beads.FFT();
    PowerSpectrum ps = new PowerSpectrum();

    sfs.addListener(fft);
    fft.addListener(ps);

    // the SpectralDifference unit generator does exactly what it sounds like
    // it calculates the difference between two consecutive spectrums returned by an FFT (through a PowerSpectrum object)
    SpectralDifference sd = new SpectralDifference(ac.getSampleRate());
    ps.addListener(sd);

    // we will use the PeakDetector object to actually find our beats
    peakDetector = new PeakDetector();
    sd.addListener(peakDetector);

    // the threshold is the gain level that will trigger the beat detector - this will vary on each recording
    peakDetector.setThreshold(cur_threshold);
    peakDetector.setAlpha(0.9);
    peakDetector.addMessageListener(
      new Bead()
    {
      protected void messageReceived(Bead b)
      {
        if (millis() - last_beat > target_interval) {
          decreaseThreshold();
        } else {
          increaeThreshold();
        }

        last_beat = millis();
        scheduleDecrease();
      }
    }
    );

    ac.out.addDependent(sfs); // tell the AudioContext that it needs to update the ShortFrameSegmenter

    // Delay Gain
    ac2 = new AudioContext();
    gain2 = new Gain(ac2, 1, 1);
    TapIn delayIn = new TapIn(ac2, delays+100);
    delayIn.addInput(gain2);
    TapOut delayOut = new TapOut(ac2, delayIn, delays); 
    //Gain delayGain = new Gain(ac2, 1, 1); // the gain for our delay
    //delayGain.addInput(delayOut); // connect the delay output to the gain
    ac2.out.addInput(delayOut);

    //ac = new AudioContext();
    //gain = new Gain(ac, 1, 0.5);
    //TapIn delayIn = new TapIn(ac, delays);
    //delayIn.addInput(gain);
    //TapOut delayOut = new TapOut(ac, delayIn, delays-1000); 
    //Gain delayGain = new Gain(ac2, 1, 1); // the gain for our delay
    //delayGain.addInput(delayOut); // connect the delay output to the gain
    //ac2.out.addInput(delayGain);
  }

  void loadSong(String songPath) {
    try
    {
      SamplePlayer player = new SamplePlayer(ac, new Sample(sketchPath("") + songPath)); // load up a new SamplePlayer using an included audio file
      gain.addInput(player); // connect the SamplePlayer to the master Gain
      SamplePlayer player2 = new SamplePlayer(ac2, new Sample(sketchPath("") + songPath)); // load up a new SamplePlayer using an included audio file
      gain2.addInput(player2); // connect the SamplePlayer to the master Gain
    }
    catch(Exception e)
    {
      e.printStackTrace(); // if there is an error, print the steps that got us to that error
    }
  }

  void addListener(Bead b) {
    peakDetector.addMessageListener(b);
  }

  void increaeThreshold() {             
    if (cur_threshold < default_threshold) {
      cur_threshold = default_threshold;
    } else {
      cur_threshold = cur_threshold * 100;
    }
    peakDetector.setThreshold(cur_threshold);
    //println("increasing " + cur_threshold);
  }

  void decreaseThreshold() {
    if (cur_threshold > default_threshold) {
      cur_threshold = default_threshold;
    } else {
      cur_threshold = cur_threshold * 0.1;
    }
    peakDetector.setThreshold(cur_threshold);
    //println("decreasing " + cur_threshold);
  }

  void scheduleDecrease() {
    //println("scheduled");
    final float pre_threshold = cur_threshold;
    new Timer().schedule(new TimerTask() {
      public void run() {
        if (cur_threshold == pre_threshold) {
          //println("affecting");
          decreaseThreshold();
          scheduleDecrease();
        };
      }
    }
    , target_interval);
  }    

  void start() {
    ac.start();
    ac2.start();
  }
}

void initBeatDetector() {
  BeatDetector bd = new BeatDetector();
  bd.loadSong("Tongue.mp3");
  //bd.loadSong("Crypt.mp3");

  // Adding listener will always have this whole structure, just put your function at the place where generateLine() resides in
  bd.addListener(     
    new Bead()
  {
    protected void messageReceived(Bead b)
    {
      // Yeah, this is the place
      generateLine();
    }
  }
  );
  bd.start();
}

void drawBeatDector() {
  noStroke();
  fill(255);
  ellipse(width/2,height-100,eRadius,eRadius);  
  int dt = millis() - time;
  eRadius += (dt * 0.2);
  if (eRadius > 85) eRadius = 85;
  time += dt; 
}