import processing.video.*;
OPC opc;
Movie content[];

//global variables and constants
int index = 0;                      //Global index of currently playing video from content array
float t0;                           //playback time counter
float t;                            //playback time counter
boolean currentlyPlaying = false;   //flag for if a file is currently playing or not
int contentCount = 5;               //total number of video files in the array



void setup()
{
  //set the player size, frame rate and so on
  size(800, 200);
  frameRate (60);
  background(0);  //background 0 for black so start up doesn't cause a strange flash

  //set up the video object, populate it with video in the data folder so we can manipulate it later
  content = new  Movie[contentCount];

  //can this be done in a loop? maybe if the filenames are sensible
  // content[0] = new Movie(this,"comp1.avi");
  // content[1] = new Movie(this, "comp2.avi");
  // content[2] = new Movie(this, "comp3.avi");

  //load videos from the data folder, assume they are named as intenger numbers starting at 0
  //make sure all the videos are paused
  for (int i = 0; i < contentCount; ++i) 
  {
      String fileName = str(i) + ".avi";
      content[i] = new Movie(this,fileName);
      content[i].pause();
      println("loaded: "+fileName);
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

  if (currentlyPlaying==false) //<>//
  {
    //pick a number at random
    int r = (int) random(content.length);
    println("currently playing: "+r);
    //reset that video and start playing it
    content[r].jump(0);
    content[r].play();
    //set the control index to this number
    index = r;
    //set the counter to the current time for tracking what is playing
    t0 = millis()/1000;
    //set currentlyPlaying to true
    currentlyPlaying=true;
  }

   if (content[index].available() ) 
    {
      content[index].read();
    }

  image(content[index], 0, 0);
 
  if (t > content[index].duration() + t0) {
    println("finished! "+index);
    //if playing has finished, toggle the bool
    currentlyPlaying=false;
  }
 
  t  = millis()/1000;

  

}
 
/*void keyPressed() {
  if (key == 'a') {
    content[0].jump(0);
    content[0].play();
    index = 0;
    t0 = millis()/1000;
  }
 
  if (key == 's') {
    content[1].jump(0);
    content[1].play();
    index = 1;
    t0 = millis()/1000;
  }
  if (key == 'd') {
    content[2].jump(0);
    content[2].play();
    index = 2;
    t0 = millis()/1000;
  }*/