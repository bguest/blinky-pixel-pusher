/*
 * Reads Color String From File
 */
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher;
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand;

import java.util.*;

DeviceRegistry registry;

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    println("Registry changed!");
    if (updatedDevice != null) {
      println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
}

TestObserver testObserver;
//BufferedReader reader;
String line;

void setup() {

  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  colorMode(RGB, 255);
  frameRate(10);
  prepareExitHandler();
}

void draw() {

  color[] clr = getColors();

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setExtraDelay(0);
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);

    List<Strip> strips = registry.getStrips();

    int numColors = clr.length;

    for (Strip strip : strips) {
      int num_pix = strip.getLength();
      int clrNum = 0;
      for (int pixNum = 0; pixNum < num_pix; pixNum++){
        //println("clrNum:"+clrNum);
        strip.setPixel(clr[clrNum], pixNum);
        clrNum++;
        if(clrNum >= numColors){
          clrNum = 0;
        }
      }
    }
  }
}

private color[] getColors(){

  String lines[] = loadStrings("blinky.txt");
  color[] colors = new color[lines.length];

  for(int i=0; i < lines.length; i++){
    String[] pieces = split(lines[i], ',');
    if(pieces.length < 3){
      colors[i] = color(0,0,0);
      continue;
    }
    int r = int(pieces[0]);
    int g = int(pieces[1]);
    int b = int(pieces[2]);

    colors[i] =  color(g,r,b);
    //print("r:"+r+" g:"+g+" b:"+b);
  }

  return colors;
}





private void prepareExitHandler () {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {

      System.out.println("Shutdown hook running");

      List<Strip> strips = registry.getStrips();
      for (Strip strip : strips) {
        for (int i=0; i<strip.getLength(); i++)
          strip.setPixel(#000000, i);
      }
      for (int i=0; i<100000; i++)
        Thread.yield();
    }
  }
  ));
}
