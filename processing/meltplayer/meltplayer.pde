import processing.video.*; //<>//
OPC opc;
Movie content[];
int[] playlist = { 0 };


//global variables and 
float samplePointSpacing = 17.5;
int playHead = 0;
int index = 0;                      //Global index of currently playing video from content array
float t0;                           //playback time counter
float t;                            //playback time counter
boolean currentlyPlaying = false;   //flag for if a file is currently playing or not
boolean isPaused = false;           //flag for if the file is paused during playback
int contentCount = 1;               //total number of video files in the array
boolean flipVideo = false;           //toggles flip and rotate of video during playback (RAW avis seem to come in back to front and upside down - could export them in reverse I guess)



void setup()
{
  //set the player size, frame rate and so on
  size(960, 160);
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
      String fileName = str(i) + ".mov";
      content[i] = new Movie(this,fileName);
      content[i].pause();
      println("loaded: "+fileName);
  }


  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

    // Map an 8x8 grid of LEDs to the center of the window, scaled to take up most of the space

  // Six 8x8 grids side by side
  opc.ledGrid8x8(0, (11*(samplePointSpacing*4)), height/2, samplePointSpacing, 0, false);
  opc.ledGrid8x8(64, (9*(samplePointSpacing*4)), height/2, samplePointSpacing, 0, false);
  opc.ledGrid8x8(128, (7*(samplePointSpacing*4)), height/2, samplePointSpacing, 0, false);
  opc.ledGrid8x8(192, (5*(samplePointSpacing*4)), height/2,  samplePointSpacing, 0, false);
  opc.ledGrid8x8(256, (3*(samplePointSpacing*4)), height/2,  samplePointSpacing, 0, false);
  opc.ledGrid8x8(320, (1*(samplePointSpacing*4)), height/2,  samplePointSpacing, 0, false);


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

void keyPressed() {
  if (key == 'p') {
    // toggle pausing
    if (!isPaused) {
      content[0].pause();
    } else {
      content[0].play();
    }
    isPaused = !isPaused;
}

if (key == 'r') {
  //reset the currently playing file
  content[0].stop();
  currentlyPlaying = false;

}

}