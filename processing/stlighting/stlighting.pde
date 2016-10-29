import processing.video.*;
import java.util.Collections;


OPC opc;
Movie content[];

IntList playlist;
IntList dmg;
ArrayList<IntList> displayModeGroups;
ArrayList<IntList> phrases;
ArrayList<IntList> answers;




//NOTES


// http requests:
//https://github.com/runemadsen/HTTP-Requests-for-Processing

//https://learn.adafruit.com/raspberry-pi-open-sound-control/interacting-with-a-web-browser

//need to add standard flicker at the start of all messages

//------

//global variables and constants
int playHead = 0;
int index = 0;                      //Global index of currently playing video from content array
float t0;                           //playback time counter
float t;                            //playback time counter
boolean currentlyPlaying = false;   //flag for if a file is currently playing or not
final int contentCount = 34;       //total number of video files in the array
boolean flipVideo = true;           //toggles flip and rotate of video during playback (RAW avis seem to come in back to front and upside down - could export them in reverse I guess)

//effects index - connects effect names with numbers for easy use later
final int dm_allOffShort = 26;
final int dm_allOnTransition = 27;
final int dm_allOnStatic = 28;       //All lights on for 10 seconds
final int dm_preMessageFlicker = 29;
final int dm_altFlash = 30;
final int dm_chaser = 31;
final int dm_chaserReverse = 32;
final int dm_randomFlash = 33;



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


  //init the master playlist, answers list and phrases list, display mode groups list
  playlist = new IntList();
  answers = new ArrayList<IntList>();
  phrases = new ArrayList<IntList>();
  displayModeGroups = new ArrayList<IntList>();
  dmg = new IntList();  //temp intlist used later when populating the list of lists


  //set up predetermined phrases as intLists which can be appended to things later
  //add each IntList to an array list so that they can be accsessed by index later
  //phrases holds stock phrases, answers holds magic 8 ball style answers
  //displayModeGroups holds sets of xmas lights effects that have to be shown together
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

  dmg = new IntList(dm_allOnTransition,dm_allOnStatic,dm_allOnStatic,dm_allOnStatic); //lights on, stay on for 30 seconds -- index0
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_allOnTransition,dm_allOnStatic,dm_allOnStatic,dm_allOnStatic,dm_allOnStatic,dm_allOnStatic,dm_allOnStatic); //lights on, stay on for 60 seconds 
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_chaser); //chaser 10 seconds
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_chaser,dm_chaser,dm_chaser); //chaser 30 seconds
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_randomFlash);
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_randomFlash,dm_randomFlash,dm_randomFlash);
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_chaserReverse);
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_chaserReverse,dm_chaserReverse,dm_chaserReverse);
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_altFlash);
  displayModeGroups.add(dmg); 

  dmg = new IntList(dm_altFlash,dm_altFlash,dm_altFlash);
  displayModeGroups.add(dmg); 


  //put something in the play list so it doesn't freak out
  RandomizePlaylist();

    


}

void movieEvent(Movie m)
{
  m.read ();
}

void draw()
{

  if(flipVideo==true)
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

    //test if we are at the end of the playlist, make a new playlist and reset the playhead
    if ((playHead % playlist.size()) == (playlist.size()-1))
    {
      println("end of current list");
      RandomizePlaylist();
      playHead = 0;
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
  s = " "+s;                            //put a space at the start of the string for a pause

  stringList.append(dm_preMessageFlicker);  //make the flicker the first thing in the message

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
      stringList.append(dm_allOffShort); //26 is the space character reference here
    }
    //if its anything else, just discard it
  }
  return stringList;
}  

void RandomizePlaylist()
{
  int elements = (int) random(2, 6);              //select a number of elements for this play list, minimum 1 //<>//
  int wallMessages = (int) random (1, (elements/3));   //pick a number between 1 and a third of the total number of items in this list - this is how many phrases will be shown during this play list

  ArrayList<IntList> temp = new ArrayList<IntList>(); //holds groups of video sets which can be shuffled later without disrupting the internal order of each preset
  IntList innerList = new IntList();  //holds inner int list when unwinding the nested lists


  //for the number of elements we have
  for (int i = 0; i<elements;i++)
  {
    int r = 0;
    int len = 0;
    //if i is less than the number of phrases required, pick a phrase at random
    if (i < wallMessages)
    {
      len = phrases.size();
      r = (int) random (0,len);
      temp.add(phrases.get(r));

    }
    //otherwise pick something from the display modes list at random
    else
    {
      len = displayModeGroups.size();
      r = (int) random (0,len);
      temp.add(displayModeGroups.get(r));
    }
  }


  //randomize the playback order
  Collections.shuffle(temp);


  //clear the current global playlist
  playlist = new IntList();

  println("all of temp");
  println(temp);
  println("temp by loop");

  //for each each int list in the array list
  for (int k = 0; k<temp.size();k++)
  {
    //extract a single int list
    innerList = new IntList();
    innerList.append(temp.get(k));
    //check if this list is empty or not
    if(innerList.size() > 0)
    {
      //if there is something there add the set to the main playlist
      playlist.append(innerList);
      println(innerList);
    }
  }

  println("New random playlist generated");
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