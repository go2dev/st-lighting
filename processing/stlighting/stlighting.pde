import processing.video.*;
OPC opc;
Movie content[];

//global variables and constants
int index = 0;    //Global index of currently playing video from content array
float t0;         //playback time counter
float t;          //playback time counter



void setup()
{
  //set the player size, frame rate and so on
  size(800, 200);
  frameRate (60);

  //set up the video object, populate it with video in the data folder so we can manipulate it later
  content = new  Movie[3];

  //can this be done in a loop?
  content[0] = new Movie(this,"comp1.avi");
  content[1] = new Movie(this, "comp2.avi");
  content[2] = new Movie(this, "comp3.avi");

  //make sure all the videos are paused
  for (int i = 0; i < content.length; ++i) 
  {
      content[i].pause();
  }


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
   if (content[index].available() ) {
    content[index].read();
  }
  image(content[index], 0, 0);
 
  if (t > content[index].duration() + t0) {
    println("finished! "+index);
  }
 
  t  = millis()/1000;
}
 
void keyPressed() {
  if (key == 'a') {
    content[0].play();
    index = 0;
    t0 = millis()/1000;
  }
 
  if (key == 's') {
    content[1].play();
    index = 1;
    t0 = millis()/1000;
  }
  if (key == 'd') {
    content[2].play();
    index = 2;
    t0 = millis()/1000;
  }

}