import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

// Box variables
float boxW = sizeOfInputArea / 2; // width of a box
float boxH = sizeOfInputArea / 3; // heigh of a box
int leftPad = 10; // the left padding of a row in a box
int topPad = 20; // the top padding of a row in a box
int margin = 15; // the margin between letters in a box
int letterPadX = 35; // the X padding within letters
int letterPadY = 15; // the Y padding within letters
int selectedBox = 0; // this helps identify which box the user has selected
String[][] alphabet = {{"a", "b", "c", "d", "e"}, {"f", "g", "h", "i", "j"},
                       {"k", "l", "m", "n", "o"}, {"p", "q", "r", "s"},
                       {"t", "u", "v", "w", "x"}, {"y", "z", " ", "<"}};

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  //noCursor();
  watch = loadImage("watchhand3smaller.png");
  //finger = loadImage("pngeggSmaller.png"); //not using this
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  
   //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!",400,200); //output
    text("Total time taken: " + (finishTime - startTime),400,220); //output
    text("Total letters entered: " + lettersEnteredTotal,400,240); //output
    text("Total letters expected: " + lettersExpectedTotal,400,260); //output
    text("Total errors entered: " + errorsTotal,400,280); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm,400,300); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors,1,3),400,320); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty,400,340);
    text("WPM w/ penalty: " + (wpm-penalty),400,360); //yes, minus, because higher WPM is better
    return;
  }
  
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    if(selectedBox == 0){
      drawRectangles();
    } else {
      drawFullBox();
    }
  }
 
  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}

/**
*  _______________________
* |   1   |   2   |   3   |
* |-------|-------|-------|
* |   4   |   5   |   6   |
*  -----------------------
*/
void drawFullBox(){
  float x = width/2;
  float y = height/2;
  
  //background
  fill(255);
  rect(x-sizeOfInputArea/2, y-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea);
  
  textSize(30);
  fill(128);
  stroke(10);
  rect(x-sizeOfInputArea/2, y-sizeOfInputArea/2, 40, 15);
  noStroke();
  fill(255);
  text("\u2190", x-sizeOfInputArea/2 + 5, y-sizeOfInputArea/2 + 15);
  fill(0);
  textAlign(CENTER);
  if(selectedBox == 1){
    text("A", x - letterPadX, y - letterPadY); 
    text("B", x, y - letterPadY);
    text("C", x + letterPadX, y - letterPadY);
    text("D", x - letterPadX, y + letterPadY);
    text("E", x, y + letterPadY);
  } else if(selectedBox == 2){
    text("F", x - letterPadX, y - letterPadY); 
    text("G", x, y - letterPadY);
    text("H", x + letterPadX, y - letterPadY);
    text("I", x - letterPadX, y + letterPadY);
    text("J", x, y + letterPadY);
  } else if(selectedBox == 3){
    text("K", x - letterPadX, y - letterPadY); 
    text("L", x, y - letterPadY);
    text("M", x + letterPadX, y - letterPadY);
    text("N", x - letterPadX, y + letterPadY);
    text("O", x, y + letterPadY);
  } else if(selectedBox == 4){
    text("P", x - letterPadX, y - letterPadY); 
    text("Q", x, y - letterPadY);
    text("R", x + letterPadX, y - letterPadY);
    text("S", x - letterPadX, y + letterPadY);
  } else if(selectedBox == 5){
    text("T", x - letterPadX, y - letterPadY); 
    text("U", x, y - letterPadY);
    text("V", x + letterPadX, y - letterPadY);
    text("W", x - letterPadX, y + letterPadY);
    text("X", x, y + letterPadY);
  } else if(selectedBox == 6){
    text("Y", x - letterPadX, y - letterPadY); 
    text("Z", x, y - letterPadY);
    text("_", x + letterPadX, y - letterPadY);
    text("<", x - letterPadX, y + letterPadY);
  }
  textSize(20);
}

// draw all the rectangles & letters on the watch
/**
*  _______________
* |   1   |   2   |
* | abcde | fghij |
* |-------|-------|
* |   3   |   4   |
* | klmno | pqrs  |
* |-------|-------|
* |   5   |   6   |
* | tuvwx | yz_<  |
*  ---------------
*/
void drawRectangles(){
    float x = width/2;
    float y = height/2;
    
    //background
    fill(255);
    rect(x-sizeOfInputArea/2, y-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea);
    
    stroke(0);
    
    // draw the 6 boxes
    //==== ROW 1 === \\
    //BOX 1
    y -= boxW;
    rect(x-boxW, y, boxW, boxH);
    drawRowOfLetters("A B C", x-boxW, y);
    drawRowOfLetters("D E", x-boxW, y+margin);
    
    //BOX 2
    rect(x,      y, boxW, boxH);
    drawRowOfLetters("F G H", x, y);
    drawRowOfLetters("I J", x, y+margin);
    
    //==== ROW 2 ==== \\
    //BOX 3 
    y += boxH;
    rect(x-boxW, y, boxW, boxH);
    drawRowOfLetters("K L M", x-boxW, y);
    drawRowOfLetters("N O", x-boxW, y+margin);
    
    //BOX 4
    rect(x,      y, boxW, boxH);
    drawRowOfLetters("P Q R", x, y);
    drawRowOfLetters("S", x, y + margin);
    
    // ==== ROW 3 ==== \\
    //BOX 5
    y += boxH;
    rect(x-boxW, y, boxW, boxH);
    drawRowOfLetters("T U V", x-boxW, y);
    drawRowOfLetters("W X", x-boxW, y+margin);
    
    //BOX 6
    rect(x,      y, boxW, boxH);
    drawRowOfLetters("Y Z _", x, y);
    drawRowOfLetters("<", x, y+margin);
    
    noStroke();
}

// draw a row of letters (specific for drawRectangle function)
void drawRowOfLetters(String letters, float x, float y){
  textSize(15);
  fill(0);
  text(letters, x + leftPad, y + topPad);
  fill(255);
  textSize(20);
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
void mousePressed()
{
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  
  /**
  * - use nextTrial() to go submit a letter an move on 
  * - currentTyped is the string we want to use for final submission
  */
  
  // this activates the drawing functions that display a single box
  // can only view a box when (1) the timer has already started and (2) when not already in the box state
  if(startTime != 0){
    // back at the page with all the rectangles
    if(selectedBox == 0){
      // at home page and selected a box
      selectedBox = findBoxClicked();  
    } else {
      // Inside a box
      String letter = findLetterClicked();
      if(letter.equals("")){
        // did not click a letter
        if(clickedBack()){
          // clicked back arrow
          selectedBox = 0;
        }
      }
      else{
        if(letter.equals("<")){
          // if deleted
          if(currentTyped.length() > 0){
            currentTyped = currentTyped.substring(0, currentTyped.length()-1); 
          }
        } else {
          currentTyped += letter;   
        }
        selectedBox = 0;
      }
    }
  }
}

boolean clickedBack(){
  float x = width/2;
  float y = height/2;
  return mouseX >= x-sizeOfInputArea/2 && mouseX <= x-sizeOfInputArea/2 + 40 && mouseY >= y-sizeOfInputArea/2 && mouseY <= y-sizeOfInputArea/2+15;// y-sizeOfInputArea/2 + 15);
}
String findLetterClicked(){
  float x = width/2;
  float y = height/2;
  String[] row = alphabet[selectedBox-1];
  
  // first row
  if(mouseY >= y - letterPadY - 25 && mouseY <= y - letterPadY + 5){
    // letter #1
    if(mouseX >= x - letterPadX - 15 && mouseX <= x - letterPadX + 15){
      return row[0]; 
    }
    // letter #2
    if(mouseX >= x - 15 && mouseX <= x  + 15){
      return row[1]; 
    }
    // letter #3
    if(mouseX >= x + letterPadX - 15 && mouseX <= x + letterPadX + 15){
      return row[2]; 
    }
  }
  // second row
  if(mouseY >= y + letterPadY - 25 && mouseY <= y + letterPadY + 5){
    // letter #4
    if(mouseX >= x - letterPadX - 15 && mouseX <= x - letterPadX + 15 && row.length > 3){
      return row[3]; 
    }
    // letter #5
    if(mouseX >= x - 15 && mouseX <= x  + 15 && row.length > 4){
      return row[4]; 
    }
  }
  return "";
}

int findBoxClicked(){
  float x = width/2;
  float y = height/2;
  // column 1
  if(mouseX >= x-boxW && mouseX <= x){
    //box 1
    y -= boxW;
    if(mouseY >= y && mouseY <= y + boxH){
      return 1;
    }
    //box 3
    y += boxH;
    if(mouseY >= y && mouseY <= y + boxH){
      return 3;
    }
    //box 5
    y += boxH;
    if(mouseY >= y && mouseY <= y + boxH){
      return 5;
    }
  }
  else if(mouseX >= x && mouseX <= x+boxW){
    //box 2
    y -= boxW;
    if(mouseY >= y && mouseY <= y + boxH){
      return 2;
    }
    //box 4
    y += boxH;
    if(mouseY >= y && mouseY <= y + boxH){
      return 4;
    }
    //box 6
    y += boxH;
    if(mouseY >= y && mouseY <= y + boxH){
      return 6;
    }
  }
  return 0;
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger,52,341);
  if (mousePressed)
     fill(0);
  else
     fill(255);
  ellipse(0,0,5,5);

  popMatrix();
  }
  

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
