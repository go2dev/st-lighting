import processing.video.*; //<>//
OPC opc;
PImage dot;
boolean show = true;


//global variables and 
float samplePointSpacing = 17.5;


void setup()
{
  //set the player size, frame rate and so on
  size(960, 160);
  frameRate (60);
  background(0);  //background 0 for black so start up doesn't cause a strange flash


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

  // Load a sample image
  dot = loadImage("dot.png");

}


void draw()
{

 background(0);

  // Draw the image, centered at the mouse location
  float dotSize = height;
  if(show==true){
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
  }
   //<>//

}

void keyPressed() {
  if (key == 'p') {
   //toggle image showing
    show = !show;
}



}