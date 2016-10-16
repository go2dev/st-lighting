import processing.video.*;
OPC opc;
Movie video;

//global variables and constants



void setup()
{
  //set the player size, frame rate and so on
  size(800, 200);
  frameRate (60);

  //set up the video object
  video = new Movie(this, "comp1.avi");
  video.loop();

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 50-LED strip to the center of the window
  //opc.ledStrip(index, count, x, y, spacing, angle, reversed)
  opc.ledStrip(0, 50, width/2, height/4, width / 55, 0, false);

}

void movieEvent(Movie m)
{
  m.read ();
}

void draw()
{
  image(video,0,0,width,height);

}