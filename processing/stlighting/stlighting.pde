OPC opc;
PImage dot;

int col;
color[] colourarray = new color[4];



void setup()
{
  size(800, 200);

  // Load a sample image
  dot = loadImage("color-dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 50-LED strip to the center of the window
  //opc.ledStrip(index, count, x, y, spacing, angle, reversed)
  opc.ledStrip(0, 50, width/2, height/4, width / 55, 0, false);
  
  colourarray[0] = color(255,0,0);
  colourarray[1] = color(0,255,0);
  colourarray[2] = color(0,0,255);
  colourarray[3] = color(0,255,255);
}

void draw()
{
  background(0);

  // Draw the image, centered at the mouse location
  //float dotSize = width * 0.2;
  //image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
  
  //Set the rectangle drawing mode to be define by the centre point and 1/2 the width and height
  rectMode(RADIUS); 
  
  for (int i=0;i<50;i++)
  {
    col = colourarray[i%4];
    fill(col);
    rect(55+(i*(width/55)),height/4,(width/55)/2,(width/55)/2);
     fill(random(255));
     ellipse(mouseX,mouseY, 100,100);


  }
}