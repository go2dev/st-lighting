import processing.video.*;
OPC opc;
Movie content[];
int[] playlist = { 27,26,7,4,11,11,14,26,22,14,17,11,3 };

//NOTES
//can we use array lists for playback management or even maybe IntList for better speed.

// getting to and from numbers with chars
  //char c[] = {key};
  //String s = new String(c);
  //String u = s.toUpperCase();
  //char cu = u.charAt(0);
  //println(((int)cu)-65);

//do we need to stop a video playing after its done to stop it using memory/looping forever in the background?

//------

//global variables and constants
int playHead = 0;
int index = 0;                      //Global index of currently playing video from content array
float t0;                           //playback time counter
float t;                            //playback time counter
boolean currentlyPlaying = false;   //flag for if a file is currently playing or not
int contentCount = 28;              //total number of video files in the array
boolean flipVideo = true;           //toggles flip and rotate of video during playback (RAW avis seem to come in back to front and upside down - could export them in reverse I guess)



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
      String fileName = nf(i,2) + ".avi";
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

  if(flipVideo=true)
  {
    translate(width/2,height/2);
    imageMode(CENTER);
    rotate(PI);
    scale(-1,1);
  }


  if (currentlyPlaying==false) //<>//
  {
    //pick the next video from the playlist
    int r = playlist[(playHead % playlist.length)];
    println("currently playing video: "+r+" which is position "+(playHead % playlist.length)+" in the playlist");
    //reset that video and start playing it
    content[r].jump(0);
    content[r].play();
    //set the control index to this number
    index = r;
    //set the counter to the current time for tracking what is playing
    t0 = millis()/1000;
    //set currentlyPlaying to true
    currentlyPlaying=true;
    //increment the playHead counter to move to the next item in the playlist
    playHead++;
  }

    //what does this bit actually do? Load the next frame for display maybe? Should probably read the API docs...
   if (content[index].available() ) 
    {
      content[index].read();
    }

  //put the video (frame) on the screen
  image(content[index], 0, 0,width,height);
 
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