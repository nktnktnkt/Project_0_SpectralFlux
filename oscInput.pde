void oscEvent(OscMessage theOscMessage) {
  
   // BEGIN Euler vector messages
  // port 7601

  if (theOscMessage.checkAddrPattern("/eulerX")==true) {
    float value = theOscMessage.get(0).floatValue();
     println(value);
     ctlX = map(value,0,360,width,0);
    // someVariable = value; will assign incoming value to whatever variable you like
    //                       be sure to declare variable outside of this function.
    return;
  }

  if (theOscMessage.checkAddrPattern("/eulerY")==true) {
    float value = theOscMessage.get(0).floatValue();
    println(value);
     ctlY = map(value,-90,90,0,height);
    // someVariable = value; will assign incoming value to whatever variable you like
    //                       be sure to declare variable outside of this function.
    return;
  }

  if (theOscMessage.checkAddrPattern("/eulerZ")==true) {
    float value = theOscMessage.get(0).floatValue();
    ctlZ = map(value,-180,180,-height*.5,height*.5);
    
    println(value);
    // someVariable = value; will assign incoming value to whatever variable you like
    //                       be sure to declare variable outside of this function.
    return;
  }
  if (theOscMessage.checkAddrPattern("/rotary")==true) {
    int value = theOscMessage.get(0).intValue();
    value = value*30;
    rotoMIDI = rotoMIDI + value;
    //println(rotoMIDI);
    
    println(value);
    // someVariable = value; will assign incoming value to whatever variable you like
    //                       be sure to declare variable outside of this function.
    return;
  }
  
  //if (theOscMessage.checkAddrPattern("/IR")) {
  //  int[] value = new int[21];
  //  for(int i = 0; i < 21; i++){
  //    value[i] = theOscMessage.get(i).intValue();
  //  }
  //  value = value*30;
  //  rotoMIDI = rotoMIDI + value;
  //  println(value);
    
  //   println(value);
  //   //someVariable = value; will assign incoming value to whatever variable you like
  //                         //be sure to declare variable outside of this function.
  //  return;
  //}

  // END Euler vector messages

}
