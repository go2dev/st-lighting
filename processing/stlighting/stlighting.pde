import processing.video.*;
OPC opc;
Movie content[];

IntList playlist;
ArrayList<IntList> phrases;
ArrayList<IntList> answers;




//NOTES


// http requests:
//https://github.com/runemadsen/HTTP-Requests-for-Processing

//https://learn.adafruit.com/raspberry-pi-open-sound-control/interacting-with-a-web-browser

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


  //init the master playlist, answers list and phrases list
  playlist = new IntList();
  answers = new ArrayList<IntList>();
  phrases = new ArrayList<IntList>();


  //set up predetermined phrases as intLists which can be appended to things later
  //add each IntList to an array list so that they can be accsessed by index later
  //phrases holds stock phrases, answers holds magic 8 ball style answers
  answers.add(StrPlaylist("no"));  //index 0
  answers.add(StrPlaylist("yes")); //index 1
  answers.add(StrPlaylist("maybe"));
  answers.add(StrPlaylist("not sure"));
  answers.add(StrPlaylist("right here"));

  phrases.add(StrPlaylist("Run")); //index 0
  phrases.add(StrPlaylist("Right here"));
  phrases.add(StrPlaylist("help"));
  phrases.add(StrPlaylist("demagorgon"));
  phrases.add(StrPlaylist("upside down"));


  //put something in the play list so it doesn't freak out
  //playlist.append(answers.get(0));
  //playlist.append(phrases.get(3));
  playlist.append(27);
  playlist.append(phrases.get(5));
  


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


  if (currentlyPlaying==false) //<>// //<>//
  {

    //pick the next video from the playlist
    int r = playlist.get(playHead % playlist.size());

    println("currently playing video: "+r+" which is position "+(playHead % playlist.size())+"/"+(playlist.size())+" in the playlist");

    //test if we are at the end of the playlist so we know to do something else
    if ((playHead % playlist.size()) == (playlist.size()-1))
    {
      println("end of current list");
      RandomizePlaylist();
    }

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
    //stop the video from playing so it isn't looping in the background
    content[index].stop();
  }

  t  = millis()/1000;

  

}

///Takes a string a returns an integerlist of video file number references to play back the string on the wall
IntList StrPlaylist(String s)
{
  IntList stringList = new IntList();   //init a new list of integers
  s = s.toUpperCase();                  //convert the inbound string to uppercase
  //cycle through each character in the string
  for (int i = 0; i<s.length();i++)
  {
    char c = s.charAt(i);  //get the current character
    //check if it is a letter
    if (c >= 'A' && c <= 'Z') 
    {
      stringList.append(((int)s.charAt(i))-65); //add each character's ascii number minus 65 to the integer list, this is the video ref that has to play for this character
    }
    //check if the character is a space
        if (c == ' ') 
    {
      stringList.append(26); //26 is the space character reference here
    }
    //if its anything else, just discard it
  }
  return stringList;
}  

void RandomizePlaylist()
{
  int elements = (int) random(1, 6);              //select a number of elements for this play list, minimum 1
  int phrases = (int) random (1, (elements/3));   //pick a number between 1 and a third of the total number of items in this list - this is how many phrases will be shown during this play list
  int modes = elements - phrases;                 //the rest of the items in the playlist will be lighting effects modes

  //clear the current playlist
  playlist.clear();

  //drop random stuff in to the play list based on the parameters above
  for (int i = 0; i<elements;i++)
  {
    if (i<phrases)
    {
       playlist.append(phrases.get((int)random( phrases.length())));
    }
    else 
    {
      playlist.append((int) random(27, contentCount));  
    }

  }

  playlist.shuffle();

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